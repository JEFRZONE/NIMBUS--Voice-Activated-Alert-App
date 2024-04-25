import 'package:flutter/material.dart';
class CustomizePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        title: Text('Customize'),
      ),
      body: Center(
        child: Text('This is the Customize page'),
      ),
    );
  }
}