// This service acts as a temporary backend to store the user's selected contacts.
class ContactStorageService {
  // Private constructor to ensure only one instance is created
  ContactStorageService._privateConstructor();

  // The single, static instance of the service
  static final ContactStorageService instance = ContactStorageService._privateConstructor();

  // The list that holds the contacts. It now starts empty.
  final List<Map<String, String>> _contacts = [];

  // A method to get the current list of contacts
  List<Map<String, String>> getContacts() {
    return _contacts;
  }

  // A method to add a new contact to the list
  void addContact(String name, String number) {
    // Check for duplicates before adding to prevent the same contact from being added twice
    if (!_contacts.any((contact) => contact['phone'] == number)) {
      _contacts.add({'name': name, 'phone': number});
    }
  }

  // A method to remove a contact from the list at a specific index
  void removeContact(int index) {
    if (index >= 0 && index < _contacts.length) {
      _contacts.removeAt(index);
    }
  }
}
