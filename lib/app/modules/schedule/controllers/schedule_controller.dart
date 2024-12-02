import 'package:flutter3/app/modules/auth/service_auth.dart';
import 'package:flutter3/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../firestore/service_firestore.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/schedule.dart';
import 'package:get_storage/get_storage.dart';
class ScheduleController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FireStoreService fireStoreService = Get.find();
  final AuthService authService = Get.find();
 final TransactionController transactionController = Get.find();

  var selectedContacts = <Contact>[].obs;
  var filteredContacts = <Contact>[].obs;
  var isLoading = true.obs;
  var selectedType = "TRANSFERT".obs;
  var selectedFrequency = "DAILY".obs;
  var customInterval = 1.obs;
final RxList<Map<String, dynamic>> _filteredTransfers = <Map<String, dynamic>>[].obs;
List<Map<String, dynamic>> get filteredTransfers => _filteredTransfers;

  final frequencyOptions = ['DAILY', 'WEEKLY', 'MONTHLY', 'EVERY_X_DAYS'];
  final RxList<Map<String, dynamic>> _scheduledTransfers = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get scheduledTransfers => _scheduledTransfers;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
    fetchSchedulesByConnectedUser();
    _filteredTransfers.bindStream(_scheduledTransfers.stream);
  }
void filterTransfers(String query) {
  if (query.isEmpty) {
    // Réinitialiser la liste filtrée à la liste complète
    _filteredTransfers.value = _scheduledTransfers;
  } else {
    _filteredTransfers.value = _scheduledTransfers.where((transfer) {
      final contacts = (transfer['contacts'] as List).join(', ').toLowerCase();
      final type = transfer['type'].toString().toLowerCase();
      return contacts.contains(query.toLowerCase()) ||
          type.contains(query.toLowerCase());
    }).toList();
  }
}
  Future<void> loadContacts() async {
    isLoading.value = true;
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      filteredContacts.assignAll(contacts);
    }
    isLoading.value = false;
  }

void filterContacts(String query) {
  if (query.isEmpty) {
    filteredContacts.value = filteredContacts.toList();
  } else {
    filteredContacts.value = filteredContacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
  }
  print("Filtered Contacts: ${filteredContacts.length} items");
}


  void selectContact(Contact contact) {
    if (!selectedContacts.contains(contact)) {
      selectedContacts.add(contact);
    }
  }

  void removeContact(Contact contact) {
    selectedContacts.remove(contact);
  }

/// Fonction pour soumettre la création d'un transfert planifié
void submitScheduledTransfer() {
  if (formKey.currentState!.validate()) {
    // Appel de la validation et création du transfert planifié
    validateAndCreateScheduledTransfer();
  } else {
    Get.snackbar(
      'Erreur',
      'Veuillez remplir correctement tous les champs.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

/// Création d'un transfert planifié avec validation préalable des contacts
Future<void> createScheduledTransfer(List<Map<String, dynamic>> validContacts) async {
  final userId = authService.currentUser.value?.id;
  if (userId == null) {
    Get.snackbar('Erreur', 'Utilisateur non connecté.');
    return;
  }

  // Construire les données pour la création
  final scheduledTransfer = ScheduledTransferRequestDTO(
    contacts: validContacts.map((contact) => contact['phone'] as String).toList(),
    montant: double.tryParse(amountController.text) ?? 0.0,
    type: selectedType.value,
    frequency: selectedFrequency.value,
    intervalDays: selectedFrequency.value == 'EVERY_X_DAYS' ? customInterval.value : 0,
    userId: userId,
  );

  try {
    // Sauvegarde dans Firestore
    final createdTransfer = await fireStoreService.create2(
      'scheduled_transfers',
      scheduledTransfer.toJson(),
    );

    // Mise à jour locale après création réussie
    _scheduledTransfers.add({...scheduledTransfer.toJson(), 'id': createdTransfer.id});
    Get.snackbar(
      'Succès',
      'Transfert planifié avec succès!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (error) {
    Get.snackbar(
      'Erreur',
      'Une erreur s\'est produite lors de la création.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}


/// Fonction de validation et création du transfert planifié
Future<void> validateAndCreateScheduledTransfer() async {
  if (!formKey.currentState!.validate()) return;

  // Préparer les données des contacts
  final contactPhones = selectedContacts
      .map((contact) =>
          contact.phones.isNotEmpty ? contact.phones.first.number : '')
      .toList();

  // Création de la charge utile pour la validation
  final requestPayload = {"contacts": contactPhones};

  isLoading.value = true;

  // Validation des contacts dans Firestore
  final validationResults = await transactionController.validateContactsInFirestore(requestPayload);

  // Gestion des erreurs
  final List<Map<String, dynamic>> errorContacts = validationResults['errors'] ?? [];
  if (errorContacts.isNotEmpty) {
    // Si des erreurs sont présentes, afficher un message mais continuer
    transactionController.displayErrorContacts(errorContacts);
  }

  // Passer aux étapes suivantes si des contacts valides sont trouvés
  final List<Map<String, dynamic>> validContacts = validationResults['good'] ?? [];
 Get.snackbar(
      'Erreur',
      'Aucun contact valide trouvé pour le transfert.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  // Vérifier si des contacts valides sont trouvés avant de créer un transfert
  if (validContacts.isNotEmpty) {
    Get.snackbar(
      'Erreur',
      'Un contact trouve ',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[50],
      colorText: Colors.white,
    );
    await createScheduledTransfer(validContacts);
  } else {
    Get.snackbar(
      'Erreur',
      'Aucun contact valide trouvé pour le transfert.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  isLoading.value = false;
}


  /// Récupération des transferts planifiés par utilisateur connecté
Future<void> fetchSchedulesByConnectedUser() async {
  try {
    var userId = authService.currentUser.value?.id;
    if (userId != null) {
      // Utiliser la méthode optimisée getWhere
      final schedules = await fireStoreService.getWhere(
        'scheduled_transfers',
        'userId',
        isEqualTo: userId,
      );
print(schedules.toString());
      _scheduledTransfers.value = schedules;
    } else {
      print('Utilisateur non connecté.');
    }
  } catch (e) {
    print('Erreur lors de la récupération des transferts planifiés : $e');
  }
}

  Future<void> deactivateSchedule(String scheduleId) async {
  try {
    await fireStoreService.update(
      'scheduled_transfers',
      scheduleId,
      {'active': false},
    );

    // Mise à jour locale des deux listes observables
    final index = _scheduledTransfers.indexWhere((schedule) => schedule['id'] == scheduleId);
    if (index != -1) {
      _scheduledTransfers[index] = {
        ..._scheduledTransfers[index],
        'active': false,
      };
      _scheduledTransfers.refresh();
      
      // Mise à jour de la liste filtrée également
      final filteredIndex = _filteredTransfers.indexWhere((schedule) => schedule['id'] == scheduleId);
      if (filteredIndex != -1) {
        _filteredTransfers[filteredIndex] = {
          ..._filteredTransfers[filteredIndex],
          'active': false,
        };
        _filteredTransfers.refresh();
      }
    }

    Get.snackbar(
      'Succès',
      'Transfert désactivé avec succès.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Une erreur s\'est produite lors de la désactivation.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

Future<void> activateSchedule(String scheduleId) async {
  try {
    await fireStoreService.update(
      'scheduled_transfers',
      scheduleId,
      {'active': true},
    );

    // Mise à jour locale des deux listes observables
    final index = _scheduledTransfers.indexWhere((schedule) => schedule['id'] == scheduleId);
    if (index != -1) {
      _scheduledTransfers[index] = {
        ..._scheduledTransfers[index],
        'active': true,
      };
      _scheduledTransfers.refresh();
      
      // Mise à jour de la liste filtrée également
      final filteredIndex = _filteredTransfers.indexWhere((schedule) => schedule['id'] == scheduleId);
      if (filteredIndex != -1) {
        _filteredTransfers[filteredIndex] = {
          ..._filteredTransfers[filteredIndex],
          'active': true,
        };
        _filteredTransfers.refresh();
      }
    }

    Get.snackbar(
      'Succès',
      'Transfert réactivé avec succès.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Une erreur s\'est produite lors de la réactivation.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

  /// Annulation d'un transfert planifié
 Future<void> cancelScheduledTransfer(String scheduleId) async {
  try {
    await fireStoreService.delete('scheduled_transfers', scheduleId);
    
    // Supprimer directement des listes observables
    _scheduledTransfers.removeWhere((schedule) => schedule['id'] == scheduleId);
    _filteredTransfers.removeWhere((schedule) => schedule['id'] == scheduleId);
    
    Get.snackbar(
      'Succès',
      'Transfert planifié annulé avec succès.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Une erreur s\'est produite lors de l\'annulation.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
  @override
  void onClose() {
    amountController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
