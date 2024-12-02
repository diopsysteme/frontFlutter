import 'package:flutter3/app/data/models/user_model.dart';
import 'package:flutter3/app/modules/auth/service_auth.dart';
import 'package:flutter3/app/modules/firestore/service_firestore.dart';
import 'package:flutter3/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
class RetraitController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final codeController = TextEditingController();
  final FireStoreService service = Get.find();
  final TransactionController cont = Get.find();
  final AuthService auth = Get.find();
  
  final isPhoneEnabled = true.obs;
  final showValidationCode = false.obs;
  final isLoading = false.obs;
  final userToWithdraw = Rxn<User2>();

  RetraitController({String? initialPhone}) {
    try {
       
    final phone = initialPhone ?? Get.arguments as String?;
    if (phone != null && phone.isNotEmpty) {
      print('Phone: $phone');
      phoneController.text = phone;
      isPhoneEnabled.value = false;
      print("ddddddddddddddddddddddddkkskskkskkskkskjdhhjieoeeoeoe");
    } else {
      print('Phone is null or empty');
    }
  } catch (e) {
    print('Error in RetraitController constructor: $e');
  }
  }
@override
  void onInit() {
    super.onInit();
    // Get the phone number from arguments or parameters
    final phone = Get.arguments as String?;
    print("PHONE BDBBDBDBBD $phone");
    if (phone != null && phone.isNotEmpty) {
      phoneController.text = phone;
      isPhoneEnabled.value = false;
    }
  }
  // Rest of the controller implementation remains the same...
  
  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    codeController.dispose();
    _resetForm();
    super.onClose();
  }

  void _resetForm() {
    if (isPhoneEnabled.value) {
      phoneController.clear();
    }
    amountController.clear();
    codeController.clear();
    showValidationCode.value = false;
    userToWithdraw.value = null;
  }
 

  Future<void> initiateWithdrawal({
    required String phone,
    required double amount,
    required VoidCallback onShowValidationCode,
  }) async {
    try {
      isLoading.value = true;
      
      // Récupérer le distributeur connecté
      final distributor = auth.currentUser.value;
      if (distributor == null) {
        Get.snackbar('Erreur', 'Distributeur non connecté');
        return;
      }

      // Vérifier si le client existe
      final client = await service.getUserByPhone(phone);
      if (client == null) {
        Get.snackbar('Erreur', 'Client non trouvé');
        return;
      }

      // Vérifier le solde du client
      if (client.solde < amount) {
        Get.snackbar('Erreur', 'Solde du client insuffisant');
        return;
      }

      // Stocker le client pour l'utiliser lors de la validation
      userToWithdraw.value = client;

      // Envoyer le code par email au client
      await service.sendValidationCode(client.mail);

      // Afficher la partie validation
      showValidationCode.value = true;
      onShowValidationCode();

    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateWithdrawal({
    required String code,
    required VoidCallback onSuccess,
  }) async {
    try {
      isLoading.value = true;

      // Vérifier si on a bien le client et le distributeur
      final distributor = auth.currentUser.value;
      final client = userToWithdraw.value;

      if (distributor == null || client == null) {
        Get.snackbar('Erreur', 'Informations manquantes');
        return;
      }

      // Vérifier le code envoyé au client
      final isValid = await service.verifyCode(client.mail, code);
      if (!isValid) {
        Get.snackbar('Erreur', 'Code invalide ou expiré');
        return;
      }

      // Effectuer la transaction de retrait
      final amount = double.parse(amountController.text);
      await cont.performTransaction(
        sender: distributor,  // Le client est le sender car on retire de son compte
        receiver: client,  // Le distributeur est le receiver
        montant: amount,
        type: "RETRAIT"
      );

      // Réinitialiser les champs et états
      _resetForm();
      
      onSuccess();
      Get.snackbar('Succès', 'Retrait effectué avec succès');
Get.toNamed("/home");
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }




}
