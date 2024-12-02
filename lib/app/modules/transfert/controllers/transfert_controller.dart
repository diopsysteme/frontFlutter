import 'package:flutter/material.dart';
import 'package:flutter3/app/modules/firestore/service_firestore.dart';
import 'package:flutter3/utils/mixing_trans.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../data/models/favorite_contact.dart';
import 'dart:developer' as developer;
class TransfertController extends GetxController with TransactionMixin {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final searchController = TextEditingController();
  
  // Make these RxList and RxSet instead of wrapping lists/sets with .obs
  final RxList<Contact> contacts = <Contact>[].obs;
  final RxList<Contact> filteredContacts = <Contact>[].obs;
  final RxSet<dynamic> selectedContacts = <dynamic>{}.obs;
  final RxBool isLoading = true.obs;
  
  // Make favorite contacts observable
  final RxList<FavoriteContact> favoriteContacts = <FavoriteContact>[
    FavoriteContact(id: '1', name: 'Marie', phone: '776561537', isFavorite: true),
    FavoriteContact(id: '2', name: 'Paul', phone: '+225 0123456789', isFavorite: true),
    FavoriteContact(id: '3', name: 'Sophie', phone: '+225 0744556677', isFavorite: true),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
    
  }

  Future<void> loadContacts() async {
    isLoading.value = true;
    try {
      if (await FlutterContacts.requestPermission()) {
        final loadedContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
        contacts.assignAll(loadedContacts);
        filteredContacts.assignAll(loadedContacts);
      }
    } catch (e) {
      developer.log('Error loading contacts', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  void filterContacts(String query) {
    if (query.isEmpty) {
      filteredContacts.assignAll(contacts);
    } else {
      final filtered = contacts.where((contact) {
        final name = contact.displayName.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
      filteredContacts.assignAll(filtered);
    }
  }

  void toggleContact(dynamic contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
  }
Future<void> confirmTransaction(String sendUnit) async {
  try {
    final contactNumbers = selectedContacts.map((contact) {
      if (contact is Contact) {
        return contact.phones.isNotEmpty ? contact.phones.first.number : null;
      } else if (contact is FavoriteContact) {
        return contact.phone;
      }
      return null;
    }).where((number) => number != null).toList();

    final requestPayload = {
      "contacts": contactNumbers,
      "montant": double.parse(amountController.text),
      "type": "TRANSFERT",
    };

    final validationResults = await validateContactsInFirestore(requestPayload);
    final goodContacts = validationResults["good"]!;
    final errorContacts = validationResults["errors"]!;
developer.log(validationResults.toString());
    if (errorContacts.isNotEmpty) {
      displayErrorContacts(errorContacts);
    }

    if (goodContacts.isNotEmpty) {
      await processValidTransactions(
        goodContacts,
        sendUnit,
        double.parse(amountController.text),
      );
      Get.toNamed("/home");

    }
  } catch (e) {
    developer.log('Transaction error', error: e);
    Get.snackbar('Erreur', 'Une erreur s\'est produite');
  }
}


  @override
  void onClose() {
    amountController.dispose();
    searchController.dispose();
    super.onClose();
  }
}