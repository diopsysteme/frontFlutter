import 'package:flutter/material.dart';
import 'package:flutter3/app/data/models/user_model.dart';
import 'package:flutter3/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter3/app/modules/auth/service_auth.dart';
import 'package:flutter3/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../app/modules/firestore/service_firestore.dart';


mixin TransactionMixin {
  final AuthService auth = Get.find();
  final TransactionController fireStoreService = Get.find();

  Future<Map<String, List<Map<String, dynamic>>>> validateContactsInFirestore(
      Map<String, dynamic> requestPayload) async {
    final List<Map<String, dynamic>> good = [];
    final List<Map<String, dynamic>> errors = [];

    try {
      final contacts = requestPayload["contacts"] ;
      for (final contact in contacts) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('telephone', isEqualTo: contact)
            .get();

        if (querySnapshot.docs.isEmpty) {
          errors.add({"telephone": contact, "reason": "Utilisateur introuvable"});
        } else {
          final userDoc = querySnapshot.docs.first;
          final userData = userDoc.data();

          good.add({
            "phone": contact,
            "user": {
              "id": userDoc.id,
              "nom": userData['nom'],
              "telephone": userData['telephone'],
              "solde": userData['solde'],
              "code": userData['code'],
              "mail": userData['mail'],
              'type': userData['type'],
              
            },
          });
        }
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la validation des contacts '+e.toString());
      developer.log('Validation error', error: e);
    }
 Get.snackbar('Erreur', 'Erreur lors de la validation des contacts '+errors.toString());
    return {"good": good, "errors": errors};
  }

  void displayErrorContacts(List<Map<String, dynamic>> errorContacts) {
    if (errorContacts.isEmpty) {
      Get.snackbar('Info', 'Tous les contacts sont valides');
      return;
    }

    final errorMessages = errorContacts
        .map((error) => "Contact: ${error['phone']}, Raison: ${error['reason']}")
        .join('\n');

    Get.dialog(
      AlertDialog(
        title: const Text('Erreurs trouvées'),
        content: Text(errorMessages),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

Future<void> processValidTransactions(
    List<Map<String, dynamic>> goodContacts,
    String sendUnit,
    double montant) async {
  try {
    // Récupérer l'utilisateur expéditeur depuis auth
    final senderData = auth.currentUser.value;

    if (senderData == null) {
      throw 'Utilisateur expéditeur introuvable';
    }

    developer.log(senderData.nom);

    for (final contact in goodContacts) {
      // Extraire les informations de la Map
      final receiverData = contact['user']; // C'est une Map<String, dynamic>

      if (receiverData is Map<String, dynamic>) {
        // Vérifier que receiverData contient un utilisateur valide
        final receiver = User2.fromMap(receiverData['id'],receiverData); // Conversion en User2

        // Effectuer la transaction
        await fireStoreService.performTransaction(
          sender: senderData,
          receiver: receiver,
          montant: montant,
          type: "TRANSFERT",
        );
      } else {
        throw 'Les données de l’utilisateur destinataire sont invalides';
      }
    }

    Get.snackbar('Succès', 'Transactions effectuées avec succès');
  } catch (e) {
    Get.snackbar('Erreur', 'Erreur lors de l’exécution des transactions');
    developer.log('Transaction processing error', error: e);
  }
}


}
