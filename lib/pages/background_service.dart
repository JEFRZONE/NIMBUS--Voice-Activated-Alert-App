import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart'
    show
        AndroidConfiguration,
        FlutterBackgroundService,
        IosConfiguration,
        ServiceInstance;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

final service = FlutterBackgroundService();

Future<void> initializeService() async {
  _initSpeech();
  await service.configure(
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
  await service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');
  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  _initSpeech();

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

  Timer.periodic(const Duration(minutes: 1), (timer) async {
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

final SpeechToText _speechToText = SpeechToText();
bool _speechEnabled = false;
String _lastWords = "Say something";

void _initSpeech() async {
  _speechEnabled = await _speechToText.initialize();
}

void _startListening() async {
  await _speechToText.listen(onResult: _onSpeechResult);
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
