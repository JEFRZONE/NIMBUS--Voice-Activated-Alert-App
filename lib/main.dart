import 'package:flutter/material.dart';
import 'package:flutter_application_3/Onboarding/onboarding_view.dart';
import 'package:flutter_application_3/home.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final onboarding = false;

  runApp( MyApp(onboarding: onboarding));
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 20, 102, 197)),
        useMaterial3: true,
      ),
      home: onboarding?  HomePage() : const OnboardingView(),
    );
  }
}