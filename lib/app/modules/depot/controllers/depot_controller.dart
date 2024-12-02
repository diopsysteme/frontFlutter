import 'package:flutter3/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DepotController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final isLoading = false.obs;
  final isPhoneEnabled = true.obs;

  // Propriété pour stocker le numéro initial
  final String? initialPhone;
final TransactionController transactionController = Get.find();
  DepotController({this.initialPhone}) {
    if (initialPhone != null) {
      phoneController.text = initialPhone!;
      isPhoneEnabled.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    super.onClose();
  }

  // Effectuer le dépôt
  Future<void> handleDepot() async {
    if (formKey.currentState!.validate()) {
      final montant = double.tryParse(amountController.text);
      final receiverPhone = phoneController.text;

      if (montant == null || montant <= 0) {
        Get.snackbar('Erreur', 'Veuillez saisir un montant valide.');
        return;
      }

      isLoading.value = true;

      try {
        await transactionController.performDepot(montant, receiverPhone);
        formKey.currentState?.reset();
        if (isPhoneEnabled.value) {
          phoneController.clear();
        }
        amountController.clear();
        Get.toNamed("/home");
      } catch (e) {
        Get.snackbar('Erreur', 'Impossible d\'effectuer le dépôt : $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Afficher le dialogue de confirmation
  void showConfirmationDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Confirmation de dépôt',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet, size: 50, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'Montant: ${amountController.text} FCFA',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Numéro: ${phoneController.text}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      radius: 15,
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Annuler'),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          handleDepot();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Confirmer'),
      ),
    );
  }
}
