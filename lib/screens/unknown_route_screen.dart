import 'package:flutter/material.dart';

class UnknownRouteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Not Found'),
      ),
      body: Center(
        child: Text('The requested page could not be found.'),
      ),
    );
  }
}