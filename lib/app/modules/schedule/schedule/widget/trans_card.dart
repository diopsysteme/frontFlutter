import 'package:flutter/material.dart';

class TransferCard extends StatelessWidget {
  final String id;
  final String contacts;
  final double montant;
  final String type;
  final bool active;
  final String frequency;
  final Function(String) onDelete;
  final Function(String) onDeactivate;
  final Function(String) onActivate; // Ajouté pour gérer l'activation

  const TransferCard({
    super.key,
    required this.id,
    required this.contacts,
    required this.montant,
    required this.type,
    required this.active,
    required this.frequency,
    required this.onDelete,
    required this.onDeactivate,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  radius: 25,
                  child: Icon(
                    type == 'DEPOT' ? Icons.attach_money : Icons.send,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$type vers ${contacts.isEmpty ? 'Non spécifié' : contacts}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fréquence: $frequency',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${montant.toStringAsFixed(2)} XOF',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: active ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        active ? 'Actif' : 'Inactif',
                        style: TextStyle(
                          color: active ? Colors.green.shade700 : Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (active)
                  TextButton.icon(
                    onPressed: () => onDeactivate(id),
                    icon: const Icon(Icons.pause, color: Colors.orange),
                    label: const Text(
                      'Désactiver',
                      style: TextStyle(color: Colors.orange),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => onActivate(id),
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    label: const Text(
                      'Activer',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => onDelete(id),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
