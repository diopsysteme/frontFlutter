import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter3/app/data/models/user_model.dart';
import 'package:flutter3/app/modules/auth/service_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../firestore/service_firestore.dart';
import '../../../data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class TransactionController extends GetxController {
  final FireStoreService fireStoreService = Get.find();
  final AuthService authService = Get.find();
  final RxList<Transactions> _transactions = <Transactions>[].obs;
  List<Transactions> get transactions => _transactions;

  final box = GetStorage();
final isLoading = false.obs;
void setNull(){
  _transactions.clear();

}
  void startLoading() {
    isLoading.value = true;
  }

  void stopLoading() {
    isLoading.value = false;
  }
Future<Map<String, List<Map<String, dynamic>>>> validateContactsInFirestore(
        Map<String, dynamic> requestPayload) async {
      final List<Map<String, dynamic>> good = [];
      final List<Map<String, dynamic>> errors = [];

      try {
        final contacts = requestPayload["contacts"] as List<String>;
        for (final contact in contacts) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('telephone', isEqualTo: contact)
              .get();

          if (querySnapshot.docs.isEmpty) {
            errors.add({"phone": contact, "reason": "Utilisateur introuvable"});
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
        Get.snackbar('Erreur',  'Erreur lors de la validation des contacts'+e.toString());
      }

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
    // Récupérer l'utilisateur expéditeur depfirstRebuildSenderfirstRebuildSenderuis auth
    final senderData = authService.currentUser.value;

    if (senderData == null) {
      throw 'Utilisateur expéditeur introuvable';
    }

    print(senderData.nom);

    for (final contact in goodContacts) {
      // Extraire les informations de la Map
      final receiverData = contact['user']; // C'est une Map<String, dynamic>

      if (receiverData is Map<String, dynamic>) {
        // Vérifier que receiverData contient un utilisateur valide
        final receiver = User2.fromMap(receiverData['id'],receiverData); // Conversion en User2

        // Effectuer la transaction
        await performTransaction(
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
Future<void> performDepot(double montant, String receiverPhone) async {
    try {
      // Récupérer le sender depuis AuthService
      final sender = authService.currentUser.value;

      if (sender == null) {
        Get.snackbar('Erreur', 'Utilisateur non authentifié');
        return;
      }

      // Récupérer le receiver depuis Firestore
      final receiver = await fireStoreService.getUserByPhone(receiverPhone);

      if (receiver == null) {
        Get.snackbar('Erreur', 'Receveur introuvable');
        return;
      }

      // Effectuer le dépôt
      await performTransaction(
        sender: sender,
        receiver: receiver,
        montant: montant,
        type: "DEPOT",
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de réaliser le dépôt : $e');
    }
  }

Future performTransaction({
  required User2 sender,
  required User2 receiver,
  required double montant,
  required String type,
  String motif = "Transaction normale",
  double frais = 0.0,
}) async {
  var soldeS = sender.solde;
  var soldeR = receiver.solde;
  
  print(sender.toMap());
  print(receiver.toMap());
  
  try {
    // Vérification du solde suffisant
    if (sender.solde < montant + frais) {
      await handleFailedTransaction(
        sender: sender,
        receiver: receiver,
        montant: montant,
        type: type,
        frais: frais,
        motif: "Solde insuffisant",
      );
      return;
    }

    // Vérification des plafonds
    if ((type == "TRANSFERT" || type == "DEPOT") &&
        await checkMonthlyTransactionsLimit(receiver)) {
      await handleFailedTransaction(
        sender: sender,
        receiver: receiver,
        montant: montant,
        type: type,
        frais: frais,
        motif: "Plafond atteint pour le receiver",
      );
      return;
    } else if (type == "RETRAIT" &&
               await checkMonthlyTransactionsLimit(sender)) {
      await handleFailedTransaction(
        sender: sender,
        receiver: receiver,
        montant: montant,
        type: type,
        frais: frais,
        motif: "Plafond atteint pour le sender",
      );
      return;
    }

    // Exécution de la transaction selon le type
    switch (type) {
      case "TRANSFERT":
        await fireStoreService.updateUserBalance(sender.id, sender.solde - (montant + frais));
        await fireStoreService.updateUserBalance(receiver.id, receiver.solde + montant);
        soldeS -= (montant + frais);
        soldeR += montant;
        break;
      case "RETRAIT":
        await fireStoreService.updateUserBalance(sender.id, sender.solde + montant);
        soldeS += montant;
        break;
      case "DEPOT":
        await fireStoreService.updateUserBalance(sender.id, sender.solde - (montant + frais));
        await fireStoreService.updateUserBalance(receiver.id, receiver.solde + montant);
        soldeS -= (montant + frais);
        soldeR += montant;
        break;
      default:
        Get.snackbar('Erreur', 'Type de transaction invalide');
        return;
    }

    // Créer et sauvegarder la transaction réussie
    final transaction = Transactions(
      id: '',
      idSender: sender.id,
      idReceiver: receiver.id,
      montant: montant,
      type: type,
      frais: frais,
      date: DateTime.now(),
      soldeSender: soldeS,
      soldeReceiver: soldeR,
      statut: "SUCCESS",
      motif: motif,
    );
    await saveTransaction(transaction);
authService.updateUserBalance(soldeS);
    // Notifications et redirection
    Get.snackbar('Succès', '$type effectué avec succès');
    Get.offNamed("/home");

  } catch (e) {
    // Gestion des erreurs générales
    Get.snackbar('Erreur', e.toString());
    print('Erreur lors de la transaction : $e');
  }
}

Future<void> handleFailedTransaction({
  required User2 sender,
  required User2 receiver,
  required double montant,
  required String type,
  required double frais,
  required String motif,
}) async {
  final failedTransaction = Transactions(
    id: '',
    idSender: sender.id,
    idReceiver: receiver.id,
    montant: montant,
    type: type,
    frais: frais,
    date: DateTime.now(),
    soldeSender: sender.solde,
    soldeReceiver: receiver.solde,
    statut: "FAILED",
    motif: motif,
  );
  await saveTransaction(failedTransaction);
  Get.snackbar('Erreur', 'Transaction échouée : $motif');
}

Future<void> fetchTransactionsByConnectedUser() async {
    // startLoading();
    print("iciciciciciciciciciciicicicicicicicici");
     print( authService.currentUser.value!.toMap());
        stopLoading();
        if( !_transactions.value.isEmpty){

          return;
        }

        print("heyyyyyyy nouveau compte new loginskdksjdkjskd skjdksjdkjs skjdksjdkjs skjdksjdkskjd skjdksjdkjs skjdksdjsj ");
    try {
      final userId =authService.currentUser.value!.id;
      print( authService.currentUser.value!.toMap());
        _transactions.value = await fireStoreService.getTransactionsByUser(userId);
       
      
    } catch (e) {
      print('Erreur lors de la récupération des transactions : $e');
    }
  }

Future<void> cancelTransaction(Transactions transaction1) async {
  try {
    // Rechercher la transaction à annuler
    final transaction = _transactions.firstWhereOrNull((t) => t.id == transaction1.id);

    if (transaction == null) {
      print('Transaction introuvable.');
      return;
    }
    // Vérifier si plus de 30 minutes se sont écoulées
    if (DateTime.now().difference(transaction.date).inMinutes > 30 && authService.currentUser.value!.type=="client") {
      print('La transaction ne peut plus être annulée (plus de 30 minutes écoulées).');
      return;
    }

    // Vérifier le solde du destinataire
    final otherUserId = transaction.idReceiver;
    final otherUser = await fireStoreService.getUserById(otherUserId);
    final initiator  = await fireStoreService.getUserById(transaction.idSender);
    if (otherUser != null && otherUser.solde >= transaction.montant) {
      // Mettre à jour les soldes des utilisateurs
      await fireStoreService.updateUserBalance(otherUserId, otherUser.solde - transaction.montant);
      await fireStoreService.updateUserBalance(transaction.idSender, initiator!.solde+ transaction.montant);
      if(authService.currentUser.value!.id == initiator.id){
print("mann leuhh ");
       authService.updateUserBalance(authService.currentUser.value!.solde + transaction.montant);
      }
      print(" after  mann leuhh ");
      final updatedTransaction = transaction.copyWith(statut: "ANNULE");
      await fireStoreService.update('transactions', transaction1.id, updatedTransaction.toMap());
      final index = _transactions.indexWhere((t) => t.id == transaction1.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
      }

      print('Transaction annulée avec succès.');
    } else {
      print('Le solde de l\'autre utilisateur est insuffisant.');
    }
  } catch (e) {
    print('Erreur lors de l\'annulation de la transaction : $e');
  }
}

Future<void> addTR(Transactions transaction) async {
    try {
      _transactions.insert(0, transaction);
      print('Transaction sauvegardée avec succès.');
    } catch (e) {
      print('Erreur lors de la sauvegarde de la transaction : $e');
    }
  }
  Future<void> saveTransaction(Transactions transaction) async {
    try {
     var tr = await fireStoreService.addTransaction(transaction);
     developer.log(tr.toString());
      _transactions.insert(0, tr);
      print('Transaction sauvegardée avec succès.');
    } catch (e) {
      print('Erreur lors de la sauvegarde de la transaction : $e');
    }
  }
  @override
  void onInit() {
    super.onInit();
    // fetchTransactionsByConnectedUser();
  }
  @override
void onReady() {
  super.onReady();
  // fetchTransactionsByConnectedUser();
}
Future<bool> checkMonthlyTransactionsLimit(User2 user) async {
    try {
      List<Transactions> userTransactions = await fireStoreService.getTransactionsByUser(user.id);
      
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      
      double monthlySum = 0.0;
      
      for (var transaction in userTransactions) {
        if (transaction.date.isAfter(firstDayOfMonth) && 
            transaction.date.isBefore(lastDayOfMonth) &&
            transaction.statut != "FAILED") {
          
          if (transaction.type == "RETRAIT" || transaction.type == "DEPOT") {
            monthlySum += transaction.montant;
          }
        }
      }
      
      print('Somme mensuelle des transactions: $monthlySum');
      print('Plafond utilisateur: ${user.plafond}');
      
      bool isOverLimit = monthlySum >= user.plafond;
      
      if (isOverLimit) {
        Get.snackbar(
          'Attention',
          'Vous avez atteint votre plafond mensuel de ${user.plafond}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      
      return isOverLimit;
      
    } catch (e) {
      print('Erreur lors de la vérification du plafond: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de vérifier le plafond des transactions',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

Future<double> getRemainingAmount(User2 user) async {
    try {
      List<Transactions> userTransactions = await fireStoreService.getTransactionsByUser(user.id);
      
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      
      double monthlySum = 0.0;
      
      for (var transaction in userTransactions) {
        if (transaction.date.isAfter(firstDayOfMonth) && 
            transaction.date.isBefore(lastDayOfMonth) &&
            transaction.statut != "FAILED") {
          if (transaction.type == "RETRAIT" || transaction.type == "DEPOT") {
            monthlySum += transaction.montant;
          }
        }
      }
      
      return user.plafond - monthlySum;
    } catch (e) {
      print('Erreur lors du calcul du montant restant: $e');
      return 0.0;
    }
  }
}
