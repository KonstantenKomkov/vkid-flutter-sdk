import 'package:flutter/material.dart';
import 'package:one_tap_rendering/rendering_screen.dart';

void main() => runApp(
  MaterialApp(
    theme: ThemeData(platform: TargetPlatform.android, useMaterial3: true),
    home: const RenderingScreen(),
  ),
);
