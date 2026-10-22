import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Virtual Display replaces its surface on resume. Cover the empty texture with
/// the last visible frame until Android has submitted a frame to the new surface.
class OneTapResumeFrame extends StatefulWidget {
  const OneTapResumeFrame({
    super.key,
    required this.awaitSurfaceFrame,
    required this.child,
  });

  final Future<void> Function(RenderRepaintBoundary boundary) awaitSurfaceFrame;
  final Widget child;

  @override
  State<OneTapResumeFrame> createState() => _OneTapResumeFrameState();
}

class _OneTapResumeFrameState extends State<OneTapResumeFrame>
    with WidgetsBindingObserver {
  final GlobalKey _boundaryKey = GlobalKey();
  ui.Image? _frame;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _generation++;
      if (_frame != null) return;
      final RenderObject? renderObject = _boundaryKey.currentContext
          ?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary ||
          !renderObject.hasSize ||
          renderObject.size.isEmpty ||
          renderObject.debugNeedsPaint) {
        return;
      }
      try {
        final ui.Image frame = renderObject.toImageSync(
          pixelRatio: View.of(context).devicePixelRatio,
        );
        setState(() => _frame = frame);
      } on Object catch (error, stack) {
        // A view that has not painted yet has no frame to preserve.
        debugPrint('VK ID: could not preserve One Tap frame: $error\n$stack');
      }
    } else if (state == AppLifecycleState.resumed && _frame != null) {
      unawaited(_restoreLiveView(++_generation));
    }
  }

  Future<void> _restoreLiveView(int generation) async {
    try {
      // A bounded fallback also handles older native plugin binaries and views
      // removed while the Activity was in the background.
      final RenderObject? boundary = _boundaryKey.currentContext
          ?.findRenderObject();
      if (boundary is RenderRepaintBoundary) {
        await widget
            .awaitSurfaceFrame(boundary)
            .timeout(const Duration(seconds: 3));
      }
      // Frame commit precedes texture consumption on Flutter's raster thread.
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;
    } on Object catch (error, stack) {
      debugPrint('VK ID: One Tap frame acknowledgement failed: $error\n$stack');
    }
    if (!mounted || generation != _generation) return;
    final ui.Image? frame = _frame;
    setState(() => _frame = null);
    // RawImage must stop referencing the image before its handle is released.
    WidgetsBinding.instance.addPostFrameCallback((_) => frame?.dispose());
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: <Widget>[
      Opacity(
        opacity: _frame == null ? 1 : 0,
        alwaysIncludeSemantics: true,
        child: RepaintBoundary(key: _boundaryKey, child: widget.child),
      ),
      if (_frame != null)
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: RawImage(image: _frame, fit: BoxFit.fill),
            ),
          ),
        ),
    ],
  );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    _frame?.dispose();
    super.dispose();
  }
}
