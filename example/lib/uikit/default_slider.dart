import 'package:flutter/material.dart';

class DefaultSlider extends StatefulWidget {
  final double defaultValue;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onChanged;
  const DefaultSlider(
      {required this.defaultValue,
      required this.minValue,
      required this.maxValue,
      required this.onChanged,
      super.key});

  @override
  State<DefaultSlider> createState() => _DefaultSliderState();
}

class _DefaultSliderState extends State<DefaultSlider> {
  double _currentSliderValue = 20;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentSliderValue,
      max: widget.maxValue,
      min: widget.minValue,
      label: _currentSliderValue.round().toString(),
      onChanged: (double value) {
        setState(() {
          _currentSliderValue = value;
          widget.onChanged(value);
        });
      },
    );
  }
}
