import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Android frame commit does not guarantee that Flutter has acquired the new
/// buffer yet. A small raster readback both acquires it and checks for the empty
/// black/transparent placeholder used during Virtual Display surface replacement.
abstract final class OneTapTextureFrame {
  static Future<void> waitUntilReady(RenderRepaintBoundary boundary) async {
    final Stopwatch elapsed = Stopwatch()..start();
    while (boundary.attached && elapsed.elapsedMilliseconds < 750) {
      if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
      if (!boundary.attached || boundary.size.isEmpty) return;
      final ui.Image image = await boundary.toImage(
        pixelRatio: 32 / boundary.size.width,
      );
      try {
        final ByteData? data = await image.toByteData();
        if (data != null) {
          for (int offset = 0; offset < data.lengthInBytes; offset += 4) {
            if (data.getUint8(offset + 3) > 0 &&
                (data.getUint8(offset) > 8 ||
                    data.getUint8(offset + 1) > 8 ||
                    data.getUint8(offset + 2) > 8)) {
              return;
            }
          }
        }
      } finally {
        image.dispose();
      }
    }
  }
}
