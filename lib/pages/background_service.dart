import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service/flutter_background_service.dart'
    show AndroidConfiguration, FlutterBackgroundService, IosConfiguration, ServiceInstance;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {

  static bool _speechEnabled = false;
  static String _lastWords = "Say something";

  static final SpeechToText _speechToText = SpeechToText();
  static List<String>? _phrases;

  static Future<void> initializeService(List<String>? phrases) async {
    // Save phrases to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (phrases != null) {
      await prefs.setStringList('phrases', phrases);
    }
    _phrases = prefs.getStringList('phrases');
    
    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    await FlutterBackgroundService().startService();
  }

  static bool onIosBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    print('FLUTTER BACKGROUND FETCH');
    return true;
  }

  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) async {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _phrases = prefs.getStringList('phrases');

    _initSpeech();

    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "My App Service",
          content: "Updated at ${DateTime.now()}",
        );
      }

      if (_speechEnabled) {
        _startListening();
      }

      print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
          "last_message": _lastWords,
        },
      );
    });
  }

  static Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  static void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  static void _stopListening() async {
    await _speechToText.stop();
  }

  static String serverIp = '192.168.218.190'; // Replace with your PC's IP address
  static int serverPort = 12345;

  static Future<void> triggerPythonScript() async {
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

  static Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    var flutterTts = FlutterTts();
    _lastWords = result.recognizedWords.trim().toString().toLowerCase();
    print('Recognized words: $_lastWords');
    print('Passed phrases: $_phrases');

    try {
      if (_phrases != null) {
        print('Starting comparison');
        bool phraseMatched = false;
        for (String phrase in _phrases!) {
          print('last words: $_lastWords');
          print('phrases: $phrase');
          if (_lastWords.trim().toLowerCase().contains(phrase.trim().toLowerCase())) {
            phraseMatched = true;
            break;
          }
        }
        if (phraseMatched) {
          print('Phrase matched!');
          triggerPythonScript();
          flutterTts.speak("We are sending help");
        } else if (_lastWords.contains('stop')) {
          _stopListening();
          flutterTts.speak("Stopped");
        }
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }
}
