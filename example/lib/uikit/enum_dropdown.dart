import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk_example/uikit/default_dropdown.dart';

class EnumDropdown<T extends Enum> extends DefaultDropdown {
  final ValueChanged<T?> onValueChanged;
  EnumDropdown(T? defaultDropdownValue, List<T> dropdownValues,
      this.onValueChanged, String hint,
      {super.key})
      : super(
          defaultDropdownValue?.name,
          dropdownValues.map((item) => item.name).toList(),
          (value) => onValueChanged(
              dropdownValues.firstWhereOrNull((item) => item.name == value)),
          hint,
        );
}
