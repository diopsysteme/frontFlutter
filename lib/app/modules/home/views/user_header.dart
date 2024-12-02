import 'package:flutter/material.dart';
import 'package:flutter3/app/modules/auth/service_auth.dart';
import 'package:flutter3/app/modules/firestore/service_firestore.dart';
import 'package:flutter3/app/modules/retrait/controllers/retrait_controller.dart';
import 'package:flutter3/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:flutter3/app/utils/email_service.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  // Fonction pour afficher la boîte de dialogue de confirmation
  void _showLogoutDialog(BuildContext context, AuthService auth,TransactionController transactionController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                // transactionController.dispose();
                 transactionController.setNull();
                await auth.signOut();
                Navigator.pop(context); // Ferme la boîte de dialogue
                Get.offAllNamed('/auth'); // Redirige vers la page de connexion
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Get.find();
    var user = auth.currentUser.value!;
final TransactionController transactionController = Get.find();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello,', style: TextStyle(fontSize: 14)),
                  Text(
                    user != null ? '${user.nom} ${user.prenom}' : 'Guest User',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: null,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: null,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context, auth,transactionController),
                tooltip: 'Déconnexion',
              ),
            ],
          ),
        ],
      ),
    );
  }
}