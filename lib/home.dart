import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:convert';
import 'package:geocoding/geocoding.dart'; // Import for reverse geocoding
import 'package:geolocator/geolocator.dart';
import 'pages/customize.dart';
import 'pages/emergencycontact.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import for text-to-speech
import 'package:speech_to_text/speech_recognition_result.dart'; // Import for speech recognition result
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  String _currentLocation = 'Locating...';
  String _cityName = ''; // Add state variable for city name
  

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        forceAndroidLocationManager: true,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _currentLocation =
              '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
          _cityName = placemark.locality ?? 'Unknown';
        });
        await _saveLocation(position.latitude, position.longitude);
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

 Future<void> _saveLocation(double latitude, double longitude) async {
  try {
    // Query the collection to get the document ID of the existing location
    QuerySnapshot snapshot = await _firestore.collection('Location').get();
    snapshot.docs.forEach((doc) async {
      await _firestore.collection('Location').doc(doc.id).delete();
    });

    // Add the new location
    GeoPoint location = GeoPoint(latitude, longitude);
    await _firestore.collection('Location').add({
      'Address': location,
      
    });
    print('Location saved successfully: $latitude, $longitude');
  } catch (e) {
    print('Error saving location: $e');
  }
}

  final String serverIp = '192.168.1.12'; // Replace with your PC's IP address
  final int serverPort = 12345;
  Future<void> triggerPythonScript() async {
    try {
      Socket socket = await Socket.connect(serverIp, serverPort);
      print('Connected to server');
      socket.write('Run Python Script');
      await socket.flush();
      socket.close();
    } catch (e) {
      print('Error connecting to server: $e');
    }
  }

  void _navigateToEmergencyContactPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyContactPage()),
    );
  }


  void _navigateToCustomizePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }
bool _isListening = false; // Add a flag to track if voice recognition is active

void _triggerVoiceRecognition() {
  if (!_isListening) {
    _startListening(); // Start voice recognition only if not already listening
  } else {
    _stopListening(); // Stop voice recognition if already listening
  }
}

void _startListening() async {
  setState(() {
    _isListening = true; // Set the flag to indicate that voice recognition is active
  });
  await _speechToText.listen(
    onResult: _onSpeechResult,
    listenFor: Duration(seconds: 0), // Listen indefinitely until stopped
  );
}

void _stopListening() async {
  setState(() {
    _isListening = false; // Set the flag to indicate that voice recognition is inactive
  });
  await _speechToText.stop();
}

  void _onSpeechResult(SpeechRecognitionResult result) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      
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
                              _cityName.isNotEmpty
                                  ? '$_cityName'
                                  : _currentLocation,
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
                      onTap:
                          _triggerVoiceRecognition, // Start voice recognition when mic button is tapped
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
                    triggerPythonScript();
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 50),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                            _navigateToEmergencyContactPage(
                                                context);
                                          },
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            _navigateToEmergencyContactPage(
                                                context);
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
                                          _navigateToEmergencyContactPage(
                                              context);
                                        },
                                        child: Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[600],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  _navigateToEmergencyContactPage(
                                                      context);
                                                },
                                                icon: Icon(Icons.add_alert,
                                                    color: Colors.white),
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
                                          _navigateToEmergencyContactPage(
                                              context);
                                        },
                                        child: Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[600],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  _navigateToEmergencyContactPage(
                                                      context);
                                                },
                                                icon: Icon(Icons.edit,
                                                    color: Colors.white),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 50),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  _navigateToCustomizePage(
                                                      context);
                                                },
                                                icon: Icon(Icons.mic,
                                                    color: Colors.white),
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
