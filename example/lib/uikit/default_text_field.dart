import 'package:flutter/material.dart';

class DefaultTextField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  const DefaultTextField(this.hintText, this.onChanged, {super.key});

  @override
  State<DefaultTextField> createState() => DefaultTextFieldState();
}

class DefaultTextFieldState extends State<DefaultTextField> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String getText() {
    return controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: widget.hintText,
        ),
        onChanged: (value) => widget.onChanged(value),
      ),
    );
  }
}
