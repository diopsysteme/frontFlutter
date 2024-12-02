import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/depot_controller.dart';

class DepotView extends GetView<DepotController> {
  final String? initialPhone;

  const DepotView({Key? key, this.initialPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialisation du contrôleur avec le numéro de téléphone (si fourni)
    final controller = Get.put(
      DepotController(initialPhone: initialPhone ?? Get.arguments as String?),
      tag: initialPhone ?? (Get.arguments as String?) ?? 'default',
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        title: const Text('Dépôt d\'argent'),
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
          child: Form(
            key: controller.formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Obx(() => TextFormField(
                                controller: controller.phoneController,
                                enabled: controller.isPhoneEnabled.value,
                                decoration: InputDecoration(
                                  labelText: 'Numéro de téléphone',
                                  prefixIcon: const Icon(Icons.phone),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: controller.isPhoneEnabled.value
                                      ? Colors.grey[50]
                                      : Colors.grey[200],
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer un numéro de téléphone';
                                  }
                                  if (value.length < 9) {
                                    return 'Le numéro doit contenir au moins 10 chiffres';
                                  }
                                  return null;
                                },
                              )),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.amountController,
                            decoration: InputDecoration(
                              labelText: 'Montant (FCFA)',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un montant';
                              }
                              final amount = int.tryParse(value);
                              if (amount == null || amount < 100) {
                                return 'Le montant minimum est de 100 FCFA';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (controller.formKey.currentState!.validate()) {
                                controller.showConfirmationDialog(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Effectuer le dépôt',
                              style: TextStyle(fontSize: 18),
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
