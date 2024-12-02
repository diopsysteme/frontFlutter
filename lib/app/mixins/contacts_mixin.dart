import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

mixin ContactsLoadingMixin<T extends StatefulWidget> on State<T> {
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;

  List<Contact> get allContacts => _allContacts;
  List<Contact> get filteredContacts => _filteredContacts;
  bool get isLoading => _isLoading;

  Future<void> loadContacts() async {
    if (await FlutterContacts.requestPermission()) {
      try {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          sorted: true,
        );
        setState(() {
          _allContacts = contacts.where((contact) => 
            contact.phones.isNotEmpty
          ).toList();
          _filteredContacts = _allContacts;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading contacts: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      showPermissionDeniedDialog();
    }
  }

  void filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts
            .where((contact) {
              final name = contact.displayName.toLowerCase();
              final number = contact.phones.isNotEmpty 
                  ? contact.phones.first.number.toLowerCase() 
                  : '';
              final lowercaseQuery = query.toLowerCase();
              return name.contains(lowercaseQuery) || 
                     number.contains(lowercaseQuery);
            })
            .toList();
      }
    });
  }

  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission requise'),
        content: const Text(
          'L\'accès aux contacts est nécessaire pour utiliser cette fonctionnalité.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Paramètres'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}