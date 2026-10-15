import 'package:flutter/material.dart';

class ToastManager {
  static OverlayEntry?
      _currentOverlayEntry; // Add a "?" to indicate it can be null

  static void displayToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height *
            0.8, // Adjust the vertical position as needed
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    _currentOverlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      if (_currentOverlayEntry != null) {
        _currentOverlayEntry!.remove();
        _currentOverlayEntry = null;
      }
    });
  }
}
