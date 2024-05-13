import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Emergency Contacts",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EmergencyContactPage(),
    );
  }
}

class ContactInfo {
  String displayName;
  String phoneNumber;

  ContactInfo(this.displayName, this.phoneNumber);

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'phoneNumber': phoneNumber,
    };
  }
}

class EmergencyContactPage extends StatefulWidget {
  @override
  _EmergencyContactPageState createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _saveContact(String name, String phoneNumber) async {
    await FirebaseFirestore.instance.collection('Contacts').add(
      ContactInfo(name, phoneNumber).toMap(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact saved successfully.'),
      ),
    );
  }

  void _deleteContact(String id) async {
    await FirebaseFirestore.instance.collection('Contacts').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact deleted successfully.'),
      ),
    );
  }

  Future<void> _pickContact() async {
    final Contact? contact = await ContactsService.openDeviceContactPicker();

    if (contact != null) {
      _nameController.text = contact.displayName ?? '';
      _phoneNumberController.text = contact.phones?.first.value ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Contact Name',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickContact,
              child: Text('Pick from Contacts'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                String name = _nameController.text.trim();
                String phoneNumber = _phoneNumberController.text.trim();

                if (name.isNotEmpty && phoneNumber.isNotEmpty) {
                  _saveContact(name, phoneNumber);
                  _nameController.clear();
                  _phoneNumberController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter both contact name and phone number or pick from contacts.'),
                    ),
                  );
                }
              },
              child: Text('Save Contact'),
            ),
            SizedBox(height: 20),
            Text(
              'Saved Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Contacts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final contacts = snapshot.data!.docs;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index].data() as Map<String, dynamic>;
                        final id = contacts[index].id;
                        return ListTile(
                          title: Text(contact['displayName'] ?? 'No Name'),
                          subtitle: Text(contact['phoneNumber'] ?? 'No Phone Number'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteContact(id);
                            },
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
