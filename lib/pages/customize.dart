import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyPhrase {
  String phrase;

  EmergencyPhrase(this.phrase);

  Map<String, dynamic> toMap() {
    return {
      'phrase': phrase,
    };
  }
}

class Register extends StatefulWidget {
  const Register({Key? key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _spokenPhrase = '';
  String _enteredPhrase = '';

  bool _showMicrophoneButton = false;
  bool _phrasesMatch = false;
  bool _showUpdateButton = false;

  void _savePhrase(String phrase) async {
    await FirebaseFirestore.instance.collection('Phrase').add(
      EmergencyPhrase(phrase).toMap(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phrase updated successfully.'),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restart the App to reflect the changes'),
      ),
    );
  }

  void _deletePhrase(String id) async {
    await FirebaseFirestore.instance.collection('Phrase').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phrase deleted successfully.'),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restart the App to reflect the changes'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xfff7f6fb),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/nimbus1.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'Phrase Updation',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Update your emergency Phrase",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 28,
              ),
              if (_showMicrophoneButton)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {
                          // Start listening for speech when microphone button is pressed
                          startListening();
                        },
                      ),
                      const SizedBox(width: 10), // Add spacing between the icon and text
                      const Text(
                        'Speak the phrase verbally',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10), // Add spacing before the text field
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your emergency phrase',
                        hintStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        // Compare the entered text with the spoken phrase when text changes
                        setState(() {
                          _enteredPhrase = value;
                          _phrasesMatch = _enteredPhrase.trim().toLowerCase() == _spokenPhrase.trim().toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showMicrophoneButton = true;
                          });
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Text(
                            'Add text phrase',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_phrasesMatch && _showUpdateButton)
                Column(
                  children: [
                    SizedBox(height: 10), // Display the update button if phrases match and the button is enabled
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          _savePhrase(_spokenPhrase);
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Update',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              const Text(
                'Saved Phrases',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Phrase').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final phrases = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: phrases.length,
                        itemBuilder: (context, index) {
                          final phrase = phrases[index].data() as Map<String, dynamic>;
                          final id = phrases[index].id;
                          return ListTile(
                            title: Text(phrase['phrase'] ?? 'No Phrase'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deletePhrase(id);
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startListening() async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _spokenPhrase = result.recognizedWords;
              // Check if the spoken phrase matches the entered text
              _phrasesMatch = _enteredPhrase.trim().toLowerCase() == _spokenPhrase.trim().toLowerCase();
              // Enable the update button when the phrases match
              _showUpdateButton = _phrasesMatch;
            });
            // Print the recognized text to the terminal
            print('Recognized Text: $_spokenPhrase');
          },
        );
      }
    }
  }
}
