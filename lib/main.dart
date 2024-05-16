import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_3/Onboarding/onboarding_view.dart';
import 'package:flutter_application_3/home.dart';
import 'package:flutter_application_3/pages/background_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  List<String> phrases = await fetchPhrasesFromFirestore(); 
  // Fetch phrases from Firestore
  await BackgroundService.initializeService(phrases);
  
  

  runApp(MyApp());
}


final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({Key? key, this.onboarding = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 20, 102, 197)),
        useMaterial3: true,
      ),
      home: onboarding ? HomePage() : const OnboardingView(),
    );
  }
}

Future<List<String>> fetchPhrasesFromFirestore() async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('Phrase').get();
    List<String> phrases = querySnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['phrase'].toString()).toList();
    print('Passed phrases: $phrases');
    return phrases;
  } catch (e) {
    print('Error fetching phrases: $e');
    return [];
  }
}
