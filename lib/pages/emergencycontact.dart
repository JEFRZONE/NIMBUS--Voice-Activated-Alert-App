
// lib/screens/emergency_contact_page.dart
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyContactPage extends StatefulWidget {
  @override
  _EmergencyContactPageState createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  List<Contact> _emergencyContacts = [];

   @override
  void initState() {
    super.initState();
    _requestContactsPermission(); // Request permission when the widget is initialized
  }

  Future<void> _requestContactsPermission() async {
    final PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus == PermissionStatus.granted) {
      // Permission granted, you can now access contacts
    } else {
      // Permission denied, handle it accordingly
    }
  }

  Future<void> _openContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    if (contacts.isNotEmpty) {
      // Open device contacts
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

      // Add selected contact to emergency contacts list
      if (selectedContact != null) {
        setState(() {
          _emergencyContacts.add(selectedContact);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        title: Text('Emergency Contact'),
      ),
      body: ListView.builder(
        itemCount: _emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = _emergencyContacts[index];
          return ListTile(
            title: Text(contact.displayName ?? ''),
            subtitle: Text(contact.phones?.isNotEmpty == true
    ? contact.phones!.first.value ?? 'No phone number available'
    : 'No phone number available'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openContacts,
        child: Icon(Icons.add),
      ),
    );
  }
}