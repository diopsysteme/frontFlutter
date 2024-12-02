import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsListWidget extends StatelessWidget {
  final List<Contact> contacts;
  final Set<dynamic> selectedContacts;
  final Function(Contact) onContactToggle;
  final bool isLoading;
  final TextEditingController searchController;

  const ContactsListWidget({
    super.key,
    required this.contacts,
    required this.selectedContacts,
    required this.onContactToggle,
    required this.isLoading,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight, // Utiliser la hauteur maximale disponible
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxHeight: double.infinity,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un contact',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : contacts.isEmpty
                          ? const Center(child: Text('Aucun contact trouvé'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: contacts.length,
                              itemBuilder: (context, index) {
                                final contact = contacts[index];
                                final isSelected = selectedContacts.contains(contact);
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[700],
                                    child: Text(
                                      contact.displayName[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(contact.displayName),
                                  subtitle: Text(
                                    contact.phones.isNotEmpty
                                        ? contact.phones.first.number
                                        : 'Pas de numéro',
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      onContactToggle(contact);
                                    },
                                  ),
                                  onTap: () => onContactToggle(contact),
                                );
                              },
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