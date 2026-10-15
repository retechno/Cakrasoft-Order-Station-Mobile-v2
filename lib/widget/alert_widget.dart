import 'package:flutter/material.dart';

class AlertWidget extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget>? actions;

  const AlertWidget({
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: actions ??
          [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
    );
  }
}
