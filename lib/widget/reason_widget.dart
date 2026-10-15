import 'package:flutter/material.dart';
import 'package:point_of_sales/utils/app_utils.dart';

class CustomInputDialog extends StatefulWidget {
  final Function(String)? onSave;
  final VoidCallback? onCancel;

  CustomInputDialog({this.onSave, this.onCancel});

  @override
  _CustomInputDialogState createState() => _CustomInputDialogState();
}

class _CustomInputDialogState extends State<CustomInputDialog> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Reason"),
      content: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(hintText: "Input reason..."),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text("Save"),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            backgroundColor:
                WidgetStateProperty.all<Color>(Styles.primaryColor),
          ),
          onPressed: () {
            String text = _textEditingController.text.trim();
            widget.onSave?.call(text);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
