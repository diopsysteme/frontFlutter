import 'package:flutter/material.dart';
import '../../../data/models/favorite_contact.dart';
class FavoritesSectionWidget extends StatelessWidget {
  final List<FavoriteContact> favorites;
  final Set<dynamic> selectedContacts;
  final Function(dynamic) onContactToggle;

  const FavoritesSectionWidget({
    super.key,
    required this.favorites,
    required this.selectedContacts,
    required this.onContactToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Favoris',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final contact = favorites[index];
                final isSelected = selectedContacts.contains(contact);
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () => onContactToggle(contact),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: isSelected ? Colors.green : Colors.white,
                          child: Text(
                            contact.name[0],
                            style: TextStyle(
                              fontSize: 24,
                              color: isSelected ? Colors.white : Colors.blue[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contact.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}