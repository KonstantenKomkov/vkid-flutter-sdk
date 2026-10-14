import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';

class RenderingScreen extends StatefulWidget {
  const RenderingScreen({super.key});

  @override
  State<RenderingScreen> createState() => _RenderingScreenState();
}

class _RenderingScreenState extends State<RenderingScreen> {
  OneTapAndroidCompositionMode _mode =
      OneTapAndroidCompositionMode.textureLayer;
  int _generation = 0;

  void _onModeChanged(Set<OneTapAndroidCompositionMode> modes) {
    setState(() => _mode = modes.single);
  }

  void _onRecreate() => setState(() => _generation++);

  void _onAuth(OneTapOAuth? provider, AuthData data) {}

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('One Tap rendering')),
    body: Column(
      children: <Widget>[
        SegmentedButton<OneTapAndroidCompositionMode>(
          segments: const <ButtonSegment<OneTapAndroidCompositionMode>>[
            ButtonSegment(
              value: OneTapAndroidCompositionMode.textureLayer,
              label: Text('TLHC'),
            ),
            ButtonSegment(
              value: OneTapAndroidCompositionMode.hybrid,
              label: Text('HC'),
            ),
            ButtonSegment(
              value: OneTapAndroidCompositionMode.virtualDisplay,
              label: Text('VD'),
            ),
          ],
          selected: <OneTapAndroidCompositionMode>{_mode},
          onSelectionChanged: _onModeChanged,
        ),
        TextButton(
          onPressed: _onRecreate,
          child: const Text('Recreate button'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Wait for the avatar. Pull down at the top, then scroll '
            'the buttons off-screen and back. Authentication taps are disabled.',
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FilledButton(
                  onPressed: _onRecreate,
                  child: const Text('Flutter reference / recreate'),
                ),
                const SizedBox(height: 12),
                AbsorbPointer(
                  child: OneTap(
                    key: ValueKey<String>('${_mode.name}_$_generation'),
                    androidCompositionMode: _mode,
                    style: const OneTapStyle(size: OneTapSize.large48),
                    signInToAnotherAccountButtonEnabled: false,
                    onAuth: _onAuth,
                  ),
                ),
                const SizedBox(height: 1400),
                const Text('Scroll back to the top.'),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
