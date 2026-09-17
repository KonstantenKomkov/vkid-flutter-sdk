import 'package:flutter/material.dart';

class DefaultDropdown extends StatefulWidget {
  final String? defaultDropdownValue;
  final List<String?> dropdownValues;
  final ValueChanged<String?> onChanged;
  final String hint;
  const DefaultDropdown(
      this.defaultDropdownValue, this.dropdownValues, this.onChanged, this.hint,
      {super.key});

  @override
  State<DefaultDropdown> createState() => _DefaultDropdownState();
}

class _DefaultDropdownState extends State<DefaultDropdown> {
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.defaultDropdownValue;
  }

  List<String?> _items(String? defaultItem, List<String?> items) {
    final newItems = items.toSet();
    newItems.add(defaultItem ?? "null");
    return newItems.toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      onChanged: (String? value) {
        setState(() {
          if (value == "null") {
            dropdownValue = null;
          } else {
            dropdownValue = value!;
          }
          widget.onChanged(value);
        });
      },
      hint: Text(
        widget.hint,
        style: const TextStyle(color: Colors.grey),
        textAlign: TextAlign.end,
      ),
      items: _items(widget.defaultDropdownValue, widget.dropdownValues)
          .map<DropdownMenuItem<String>>((String? value) {
        return DropdownMenuItem<String>(
          value: value ?? "null",
          child: Text(value ?? "null"),
        );
      }).toList(),
    );
  }
}
