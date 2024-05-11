import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart' show AndroidConfiguration, FlutterBackgroundService, IosConfiguration, ServiceInstance;
import 'package:flutter/material.dart';
import 'background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeService();

  runApp(const Voicetrigger());
}

class Voicetrigger extends StatefulWidget {
  const Voicetrigger({Key? key}) : super(key: key);

  @override
  State<Voicetrigger> createState() => _VoicetriggerState();
}

class _VoicetriggerState extends State<Voicetrigger> {
  String text = "Stop Service";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Voice Bot"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<Map<String, dynamic>?>(
                stream: FlutterBackgroundService().on('update'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final data = snapshot.data!;
                  String? lastMessage = data["last_message"];
                  DateTime? date = DateTime.tryParse(data["current_date"]);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(lastMessage ?? 'Unknown'),
                      Text(date.toString()),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  FlutterBackgroundService().invoke("setAsForeground");
                },
                child: const Text("Foreground Mode"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  print('start');
                  FlutterBackgroundService().invoke("setAsBackground");
                },
                child: const Text("Background Mode"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final service = FlutterBackgroundService();
                  var isRunning = await service.isRunning();
                  if (isRunning) {
                    service.invoke("stopService");
                  } else {
                    service.startService();
                  }
                  setState(() {
                    text = isRunning ? 'Start Service' : 'Stop Service';
                  });
                },
                child: Text(text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
