import 'package:flutter/material.dart';

class RecentAlertsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        title: Text('Recent Alerts'),
      ),
      body: Center(
        child: Text('This is the Recent Alerts page'),
      ),
    );
  }
}