import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/retrait_controller.dart';

class RetraitView extends GetView<RetraitController> {
  const RetraitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérer le numéro de téléphone des arguments
    final phone = Get.arguments as String?;
    print("Numéro de téléphone reçu : $phone");

    // Obtenir le contrôleur
    final controller = Get.find<RetraitController>();

    // Initialiser le champ téléphonique si un numéro est fourni
    if (phone != null) {
      controller.phoneController.text = phone;
      controller.isPhoneEnabled.value = false; // Désactiver le champ
    }else{
controller.phoneController.text = "";
 controller.isPhoneEnabled.value = true;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        title: const Text('Retrait'),
        centerTitle: true,
      ),
      body: Container(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Effectuer un retrait',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Champ pour le numéro de téléphone
                            Obx(() => TextFormField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  enabled: controller.isPhoneEnabled.value,
                                  decoration: InputDecoration(
                                    labelText: 'Numéro de téléphone',
                                    prefixIcon: const Icon(Icons.phone),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    filled: true,
                                    fillColor: controller.isPhoneEnabled.value
                                        ? Colors.grey[50]
                                        : Colors.grey[200],
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer un numéro';
                                    }
                                    return null;
                                  },
                                )),
                            const SizedBox(height: 20),

                            // Champ pour le montant
                            TextFormField(
                              controller: controller.amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Montant',
                                prefixIcon: const Icon(Icons.attach_money),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un montant';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Montant invalide';
                                }
                                return null;
                              },
                            ),

                            // Code de validation (si nécessaire)
                            Obx(
                              () => controller.showValidationCode.value
                                  ? Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          controller: controller.codeController,
                                          decoration: InputDecoration(
                                            labelText: 'Code de validation',
                                            prefixIcon: const Icon(Icons.lock),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer le code';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),

                            const SizedBox(height: 30),

                            // Bouton pour continuer ou valider
                            Obx(() => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () {
                                          if (controller.formKey.currentState!
                                              .validate()) {
                                            if (!controller
                                                .showValidationCode.value) {
                                              controller.initiateWithdrawal(
                                                phone: controller
                                                    .phoneController.text,
                                                amount: double.parse(controller
                                                    .amountController.text),
                                                onShowValidationCode: () {},
                                              );
                                            } else {
                                              controller.validateWithdrawal(
                                                code: controller
                                                    .codeController.text,
                                                onSuccess: () {
                                                  Get.snackbar(
                                                    'Succès',
                                                    'Retrait effectué avec succès!',
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        Colors.green,
                                                    colorText: Colors.white,
                                                  );
                                                  Get.back();
                                                },
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: controller.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : Text(
                                          controller.showValidationCode.value
                                              ? 'Valider'
                                              : 'Continuer',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
