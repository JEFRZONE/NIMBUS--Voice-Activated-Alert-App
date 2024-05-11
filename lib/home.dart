import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_3/pages/Voicetrigger.dart';
import 'package:geocoding/geocoding.dart'; // Import for reverse geocoding
import 'package:geolocator/geolocator.dart';
import 'pages/notification.dart';
import 'pages/settings.dart';
import 'pages/customize.dart';
import 'pages/emergencycontact.dart';
import 'pages/recentalerts.dart';
import 'pages/profile.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import for text-to-speech
import 'package:speech_to_text/speech_recognition_result.dart'; // Import for speech recognition result
import 'package:speech_to_text/speech_to_text.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
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

  

 
  void _triggerVoiceRecognition() {
  _startListening(); // Start voice recognition
}

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: 0), // Listen for a minute
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    var flutterTts = FlutterTts();
    _lastWords = result.recognizedWords.toString().toLowerCase();

    if (_lastWords.contains("hello") || _lastWords.contains('help')) {
      flutterTts.speak("We are sending help");
    } else if (_lastWords.contains('stop')) {
      _stopListening();
      flutterTts.speak("Stopped");
    }
  }


  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch location on app launch
     
    _initSpeech(); // Initialize speech recognition
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize(); // Initialize speech recognition
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
      MaterialPageRoute(builder: (context) => Register()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'), // Added profile entry
        ],
        onTap: (index) {
          // Handle navigation based on the tapped index
          if (index == 0) {
            // Navigate to home page
          } else if (index == 1) {
            // Navigate to profile page
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ProfilePage()));
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
                    GestureDetector(
                     onTap: _triggerVoiceRecognition, // Start voice recognition when mic button is tapped
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(200),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
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
                                            _navigateToEmergencyContactPage(context);
                                          },
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            _navigateToEmergencyContactPage(context);
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
                                          _navigateToEmergencyContactPage(context);
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
                                                  _navigateToEmergencyContactPage(context);
                                                },
                                                icon: Icon(Icons.add_alert, color: Colors.white),
                                              ),
                                              SizedBox(height: 8),
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
                                          _navigateToEmergencyContactPage(context);
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
                                                  _navigateToEmergencyContactPage(context);
                                                },
                                                icon: Icon(Icons.edit, color: Colors.white),
                                              ),
                                              SizedBox(height: 8),
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
                    SizedBox(height: 20),
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
                                            _navigateToRecentAlertsPage(context);
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
                                          _navigateToRecentAlertsPage(context);
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
                                                  _navigateToRecentAlertsPage(context);
                                                },
                                                icon: Icon(Icons.notifications_active, color: Colors.white),
                                              ),
                                              SizedBox(height: 8),
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
                                          _navigateToRecentAlertsPage(context);
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
                                                  _navigateToRecentAlertsPage(context);
                                                },
                                                icon: Icon(Icons.history, color: Colors.white),
                                              ),
                                              SizedBox(height: 8),
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
                    SizedBox(height: 20),
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
                                            _navigateToSettingsPage(context);
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
                                          _navigateToSettingsPage(context);
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
                                                  _navigateToSettingsPage(context);
                                                },
                                                icon: Icon(Icons.settings, color: Colors.white),
                                              ),
                                              SizedBox(height: 10),
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
                    SizedBox(height: 20),
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
                                            _navigateToCustomizePage(context);
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
                                          _navigateToCustomizePage(context);
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
                                                  _navigateToCustomizePage(context);
                                                },
                                                icon: Icon(Icons.mic, color: Colors.white),
                                              ),
                                              SizedBox(height: 8),
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
                                          _navigateToCustomizePage(context);
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
                                                  _navigateToCustomizePage(context);
                                                },
                                                icon: Icon(Icons.local_hospital, color: Colors.white),
                                              ),
                                              SizedBox(height: 8),
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