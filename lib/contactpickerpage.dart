import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

// This is the new, custom screen for picking multiple contacts.
class ContactPickerPage extends StatefulWidget {
  const ContactPickerPage({super.key});

  @override
  State<ContactPickerPage> createState() => _ContactPickerPageState();
}

class _ContactPickerPageState extends State<ContactPickerPage> {
  List<Contact>? _contacts;
  bool _isLoading = true;
  final List<Contact> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      try {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        if(mounted) {
           setState(() {
            _contacts = contacts;
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching contacts: $e");
         if(mounted) {
           setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
       if(mounted) {
           setState(() {
            _isLoading = false;
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contacts'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts == null || _contacts!.isEmpty
              ? const Center(child: Text('No contacts found or permission denied.'))
              : ListView.builder(
                  itemCount: _contacts!.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts![index];
                    final isSelected = _selectedContacts.contains(contact);
                    return CheckboxListTile(
                      title: Text(contact.displayName),
                      subtitle: Text(contact.phones.isNotEmpty ? contact.phones.first.number : 'No number'),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedContacts.add(contact);
                          } else {
                            _selectedContacts.remove(contact);
                          }
                        });
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // When done, pop the screen and return the list of selected contacts
          Navigator.of(context).pop(_selectedContacts);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.check),
      ),
    );
  }
}
