import 'package:flutter/material.dart';
import 'package:my_delivery_app/screens/address_capture_screen.dart';

class LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          strokeWidth: 6.0,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }
}