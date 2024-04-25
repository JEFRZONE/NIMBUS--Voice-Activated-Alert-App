import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart'; // Import for reverse geocoding
import 'package:geolocator/geolocator.dart';
import 'pages/notification.dart';
import 'pages/settings.dart';
import 'pages/customize.dart';
import 'pages/emergencycontact.dart';
import 'pages/recentalerts.dart';
import 'pages/profile.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentLocation = 'Locating...';
  String _cityName = ''; // Add state variable for city name

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        forceAndroidLocationManager: true,
      );

      // Reverse geocoding to get city name
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _currentLocation =
              '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
          _cityName = placemark.locality ?? 'Unknown'; // Handle cases where locality is unavailable
        });
      } else {
        setState(() {
          _currentLocation = 'Location error';
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Locations error';
      });
    }
  }

  void _navigateToNotificationsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsPage()),
    );
  }

  void _navigateToEmergencyContactPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyContactPage()),
    );
  }

  void _navigateToRecentAlertsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecentAlertsPage()),
    );
  }

  void _navigateToSettingsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  void _navigateToCustomizePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomizePage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch location on app launch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      bottomNavigationBar: BottomNavigationBar(backgroundColor: Colors.blue,selectedItemColor: Colors.white,
        items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), // Added profile entry
  ],
  onTap: (index) {
    // Handle navigation based on the tapped index
    if (index == 0) {
      // Navigate to home page
    } else if (index == 1) {
      // Navigate to profile page
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
    }
  },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '   Hi, Jefrin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8, height: 8),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.location_on),
                              color: Colors.white,
                              onPressed: _getCurrentLocation,
                            ),
                            SizedBox(width: 1),
                            Text(
                              _cityName.isNotEmpty ? '$_cityName' : _currentLocation,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue[100],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blue[100],
                    ),
                    hintText: 'Search...',
                    filled: true,
                    fillColor: Colors.blue[50],
                    contentPadding: EdgeInsets.all(12),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    _navigateToNotificationsPage(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(200),
                    ),
                    padding: EdgeInsets.all(100),
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
                SizedBox(height: 70),
                Column(
                  children: [
                    // Emergency Contact Tile
                    GestureDetector(
                      onTap: () {
                        _navigateToEmergencyContactPage(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Emergency Contacts',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _navigateToEmergencyContactPage(context); // Navigate to add emergency contact page
                                            },
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () {
                                              _navigateToEmergencyContactPage(context); // Navigate to update emergency contact page
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _navigateToEmergencyContactPage(context); // Navigate to add emergency contact page
                                          },
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[600],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _navigateToEmergencyContactPage(context); // Navigate to update emergency contact page
                                                  },
                                                  icon: Icon(Icons.add_alert, color: Colors.white),
                                                ),
                                                SizedBox(height: 8), // Adjust spacing between icon and text
                                                Text(
                                                  'Add Emergency \n Contact',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  ),
                                                ],
                                              ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _navigateToEmergencyContactPage(context); // Navigate to update emergency contact page
                                          },
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[600],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _navigateToEmergencyContactPage(context); // Navigate to update emergency contact page
                                                  },
                                                  icon: Icon(Icons.edit, color: Colors.white),
                                                ),
                                                SizedBox(height: 8), // Adjust spacing between icon and text
                                                Text(
                                                  'Update Emergency \n Contact',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                    ),
                    SizedBox(height: 20), // Added space between tiles
                    // Recent Alerts Tile
                    GestureDetector(
                      onTap: () {
                        _navigateToRecentAlertsPage(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Alerts',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _navigateToRecentAlertsPage(context); // Navigate to add emergency contact page
                                            },
                                            child: Icon(
                                              Icons.notifications,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _navigateToRecentAlertsPage(context);// Navigate to add emergency contact page
                                          },
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[600],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _navigateToRecentAlertsPage(context); // Navigate to update emergency contact page
                                                  },
                                                  icon: Icon(Icons.notifications_active, color: Colors.white),
                                                ),
                                                SizedBox(height: 8), // Adjust spacing between icon and text
                                                Text(
                                                  'Current alerts',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  ),
                                                ],
                                              ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _navigateToRecentAlertsPage(context);// Navigate to update emergency contact page
                                          },
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[600],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _navigateToRecentAlertsPage(context); // Navigate to update emergency contact page
                                                  },
                                                  icon: Icon(Icons.history, color: Colors.white),
                                                ),
                                                SizedBox(height: 8), // Adjust spacing between icon and text
                                                Text(
                                                  'Recent Alerts',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ),
                    SizedBox(height: 20), // Added space between tiles
                    // Settings Tile
                    GestureDetector(
                      onTap: () {
                        _navigateToSettingsPage(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Settings',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                             _navigateToSettingsPage(context);; // Navigate to add emergency contact page
                                            },
                                            child: Icon(
                                              Icons.settings,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _navigateToSettingsPage(context);// Navigate to add emergency contact page
                                          },
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[600],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _navigateToSettingsPage(context); // Navigate to update emergency contact page
                                                  },
                                                  icon: Icon(Icons.settings, color: Colors.white),
                                                ),
                                                SizedBox(height: 10), // Adjust spacing between icon and text
                                                Text(
                                                  'Settings',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  ),
                                                ],
                                              ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ),
                    SizedBox(height: 20), // Added space between tiles
                    // Customize Tile
                    GestureDetector(
                      onTap: () {
                        _navigateToCustomizePage(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Customize',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _navigateToCustomizePage(context); // Navigate to add emergency contact page
                                            },
                                            child: Icon(
                                              Icons.format_paint,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _navigateToCustomizePage(context);// Navigate to add emergency contact page
                                          },
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[600],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _navigateToCustomizePage(context); // Navigate to update emergency contact page
                                                  },
                                                  icon: Icon(Icons.mic, color: Colors.white),
                                                ),
                                                SizedBox(height: 8), // Adjust spacing between icon and text
                                                Text(
                                                  'Update Phrase',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  ),
                                                ],
                                              ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _navigateToCustomizePage(context);// Navigate to update emergency contact page
                                          },
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[600],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _navigateToCustomizePage(context); // Navigate to update emergency contact page
                                                  },
                                                  icon: Icon(Icons.local_hospital, color: Colors.white),
                                                ),
                                                SizedBox(height: 8), // Adjust spacing between icon and text
                                                Text(
                                                  'Medical Records',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
