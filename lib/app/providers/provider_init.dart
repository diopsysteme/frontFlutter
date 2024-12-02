import 'package:get/get.dart';
import '../modules/firestore/service_firestore.dart';

class DataProvider extends GetxController {
  final FireStoreService fireStoreService = Get.find();

  final Rx<Map<String, dynamic>?> _user = Rx<Map<String, dynamic>?>(null);
  final RxList<Map<String, dynamic>> _transactions = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _scheduledTransfers = <Map<String, dynamic>>[].obs;

  Map<String, dynamic>? get user => _user.value;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get scheduledTransfers => _scheduledTransfers;

  Future<void> fetchTransactions() async {
    try {
      _transactions.value = await fireStoreService.get('transactions');
    } catch (e) {
      print('Erreur : $e');
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    try {
      await fireStoreService.create('transactions', transaction);
      _transactions.insert(0, transaction);
    } catch (e) {
      print('Erreur : $e');
    }
  }

  Future<void> removeTransaction(String transactionId) async {
    try {
      await fireStoreService.delete('transactions', transactionId);
      _transactions.removeWhere((t) => t['id'] == transactionId);
    } catch (e) {
      print('Erreur : $e');
    }
  }

  Future<void> getUser(String email) async {
    try {
      final fetchedUser = await fireStoreService.getUserByEmail(email);
      if (fetchedUser != null) {
        _user.value = fetchedUser.toMap();
      } else {
        print('Utilisateur introuvable.');
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
    }
  }

  Future<void> updateUser(Map<String, dynamic> updatedUser) async {
    try {
      if (_user.value != null && _user.value!['id'] != null) {
        await fireStoreService.update('users', _user.value!['id'], updatedUser);
        _user.value = updatedUser;
      } else {
        print('Utilisateur non défini ou ID manquant.');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur : $e');
    }
  }
}