import 'dart:io';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class EmergencyContactPage extends StatefulWidget {
  @override
  _EmergencyContactPageState createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  List<Contact> _emergencyContacts = [];
  late String _csvFilePath;

  @override
  void initState() {
    super.initState();
    _requestContactsPermission();
    _initCsvFile();
  }

  Future<void> _requestContactsPermission() async {
    final PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus != PermissionStatus.granted) {
      // Handle permission denied
    }
  }

  Future<void> _initCsvFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    _csvFilePath = '${directory.path}/emergency_contacts.csv';
    // Create the CSV file if it doesn't exist
    if (!File(_csvFilePath).existsSync()) {
      File(_csvFilePath).createSync();
    }
  }

  Future<void> _openContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    if (contacts.isNotEmpty) {
      Contact? selectedContact = await showDialog<Contact>(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text('Select Contact'),
          children: contacts.map((contact) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, contact),
              child: ListTile(
                title: Text(contact.displayName ?? ''),
                subtitle: Text(contact.phones?.isNotEmpty == true
                    ? contact.phones!.first.value ?? 'No phone number available'
                    : 'No phone number available'),
              ),
            );
          }).toList(),
        ),
      );

      if (selectedContact != null) {
        setState(() {
          _emergencyContacts.add(selectedContact);
          _saveContactsToCsv(); // Save the selected contact to CSV
        });
      }
    }
  }

  Future<void> _saveContactsToCsv() async {
    List<List<dynamic>> rows = [];
    for (var contact in _emergencyContacts) {
      String displayName = contact.displayName ?? '';
      String phoneNumber = contact.phones?.isNotEmpty == true
          ? contact.phones!.first.value ?? ''
          : '';
      rows.add([displayName, phoneNumber]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    File(_csvFilePath).writeAsStringSync(csv, mode: FileMode.write);
  }

  Future<List<List<dynamic>>> _loadContactsFromCsv() async {
    try {
      String csvString = await File(_csvFilePath).readAsString();
      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);
      return rowsAsListOfValues;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        title: Text('Emergency Contact'),
      ),
      body: FutureBuilder<List<List<dynamic>>>(
        future: _loadContactsFromCsv(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading contacts'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No emergency contacts added yet'));
          } else {
            List<List<dynamic>> contactsData = snapshot.data!;
            return ListView.builder(
              itemCount: contactsData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(contactsData[index][0] ?? ''),
                  subtitle: Text(contactsData[index][1] ?? ''),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openContacts,
        child: Icon(Icons.add),
      ),
    );
  }
}
