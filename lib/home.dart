import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentAlerts = 9;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 252, 246, 189),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Current Alerts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$_currentAlerts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                children: [
                  _buildGridItem('Bank Jn, Aluva', Icons.location_on),
                  _buildGridItem('Emergency', Icons.emergency),
                  _buildGridItem('Contacts', Icons.contacts),
                  _buildGridItem('Trigger Alert', Icons.notifications_active),
                  _buildGridItem('D', Icons.done),
                  _buildGridItem('Recent', Icons.history),
                  _buildGridItem('Settings', Icons.settings),
                  _buildGridItem('Alerts', Icons.notifications),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(String text, IconData icon) {
    return GridTile(
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            // Add functionality here
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: const Color.fromARGB(255, 252, 246, 189),
                ),
                SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}