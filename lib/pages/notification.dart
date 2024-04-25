// lib/screens/notifications_page.dart
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Center(
        child: Text('This is the notifications page'),
      ),
    );
  }
}
