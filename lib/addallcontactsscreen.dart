import 'package:ammu_app/contactpickerpage.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // Required for the blur effect
import 'package:flutter_contacts/flutter_contacts.dart';
import 'contact_storage_service.dart';

class AddAllContactsScreen extends StatefulWidget {
  const AddAllContactsScreen({super.key});

  @override
  State<AddAllContactsScreen> createState() => _AddAllContactsScreenState();
}

class _AddAllContactsScreenState extends State<AddAllContactsScreen> {
  late List<Map<String, String>> _contacts;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contacts = ContactStorageService.instance.getContacts();
  }

  void _refreshContacts() {
    setState(() {
      _contacts = ContactStorageService.instance.getContacts();
    });
  }

  void _removeContact(int index) {
    ContactStorageService.instance.removeContact(index);
    _refreshContacts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact removed successfully!')),
    );
  }

  void _addNewContact(String name, String number) {
    ContactStorageService.instance.addContact(name, number);
    _refreshContacts();
  }

  Future<void> _pickMultipleContacts() async {
    final List<Contact>? selectedContacts = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactPickerPage()),
    );

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      int addedCount = 0;
      for (final contact in selectedContacts) {
        if (contact.phones.isNotEmpty) {
          final String phoneNumber = contact.phones.first.number;
          _addNewContact(contact.displayName, phoneNumber);
          addedCount++;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$addedCount contact(s) added!')),
        );
      }
    } else {
      debugPrint("No contacts were selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add All Contacts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            color: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      contact['name']!.isNotEmpty ? contact['name']![0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          contact['phone']!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _removeContact(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text("Add Contact"),
              content: const Text("How would you like to add a contact?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _showManualAddDialog();
                  },
                  child: const Text("Manually"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _pickMultipleContacts();
                  },
                  child: const Text("From My Contacts"),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Future<void> _showManualAddDialog() async {
    _nameController.clear();
    _numberController.clear();
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            contentPadding: const EdgeInsets.all(24.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Number',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.isNotEmpty && _numberController.text.isNotEmpty) {
                          _addNewContact(_nameController.text, _numberController.text);
                          Navigator.of(dialogContext).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter both name and number.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
