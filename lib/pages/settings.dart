import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('This is the Settings page'),
      ),
    );
  }
}
