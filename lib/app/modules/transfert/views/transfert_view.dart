import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './amount_input_widget.dart';
import './favorites_section_widget.dart';
import './contacts_list_widget.dart';
import '../controllers/transfert_controller.dart';

class TransfertView extends GetView<TransfertController> {
  final String sendUnit;

  const TransfertView({super.key, required this.sendUnit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        title: Text('Envoi de $sendUnit'),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[700]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AmountInputWidget(
                  controller: controller.amountController,
                  formKey: controller.formKey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Obx(() {
                  return FavoritesSectionWidget(
                    favorites: controller.favoriteContacts.toList(),
                    selectedContacts: controller.selectedContacts.toSet(),
                    onContactToggle: controller.toggleContact,
                  );
                }),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Obx(() => ContactsListWidget(
                        contacts: controller.filteredContacts.toList(),
                        selectedContacts: controller.selectedContacts.toSet(),
                        onContactToggle: controller.toggleContact,
                        isLoading: controller.isLoading.value,
                        searchController: controller.searchController,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(
        () => controller.selectedContacts.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  if (controller.formKey.currentState!.validate()) {
                    controller.confirmTransaction(sendUnit);
                  }
                },
                icon: const Icon(Icons.send),
                label: Text('Envoyer (${controller.selectedContacts.length})'),
                backgroundColor: Colors.blue[700],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
