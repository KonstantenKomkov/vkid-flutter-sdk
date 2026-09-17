import 'package:flutter/material.dart';

class DefaultCheckbox extends StatefulWidget {
  final bool defaultValue;
  final ValueChanged<bool> onChanged;
  final String label;
  const DefaultCheckbox(
      {required this.defaultValue,
      required this.onChanged,
      required this.label,
      super.key});

  @override
  State<DefaultCheckbox> createState() => _DefaultCheckboxState();
}

class _DefaultCheckboxState extends State<DefaultCheckbox> {
  String label = "";
  bool isChecked = false;
  ValueChanged<bool> onChanged = (value) => value;

  @override
  void initState() {
    super.initState();
    label = widget.label;
    isChecked = widget.defaultValue;
    onChanged = widget.onChanged;
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Row(children: [
      Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith(getColor),
        value: isChecked,
        onChanged: (bool? value) {
          setState(() {
            isChecked = value!;
            onChanged(value);
          });
        },
      ),
      Text(label),
    ]);
  }
}
