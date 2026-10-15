import 'package:flutter/material.dart';
import 'package:point_of_sales/utils/app_utils.dart';

class CustomDropdown extends StatelessWidget {
  final List items;
  final String label;
  final dynamic dropdownValue;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.label,
    this.dropdownValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField(
            isExpanded: true,
            decoration: InputDecoration(
                labelText: label,
                enabled: false,
                labelStyle: Styles.textStyle,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0)),
            initialValue: dropdownValue?.value,
            onChanged: (newValue) {
              dropdownValue?.value = newValue!;
            },
            items: items.map((map) {
              return DropdownMenuItem<String>(
                value: map.code,
                child: Text(map.name,
                    style: const TextStyle(height: 0.0, fontSize: 12)),
              );
            }).toList()),
      ],
    );
  }
}
