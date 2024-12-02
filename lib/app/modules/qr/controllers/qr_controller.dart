import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter3/app/modules/firestore/service_firestore.dart';

class QrController extends GetxController {
  late MobileScannerController scannerController;
  var scannedData = ''.obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var isScanning = true.obs;
  var isProcessing = false.obs;
  final FireStoreService fireStoreService = Get.find();

  @override
  void onInit() {
    super.onInit();
    initializeScanner();
  }

  @override
  void onReady() {
    super.onReady();
    resetAllStates();
  }

  Future<void> resetAllStates() async {
    isProcessing.value = false;
    isScanning.value = true;
    scannedData.value = '';
    isLoading.value = false;
    error.value = '';
    await cleanupScanner();
    initializeScanner();
  }

  Future<void> cleanupScanner() async {
    try {
      await scannerController.stop();
       scannerController.dispose();
    } catch (e) {
      debugPrint('Erreur lors du nettoyage du scanner: $e');
    }
  }

  void initializeScanner() {
    try {
      scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        formats: [BarcodeFormat.qrCode],
      );
      // Démarrer explicitement le scanner
      scannerController.start();
    } catch (e) {
      error.value = 'Erreur d\'initialisation de la caméra: $e';
      Get.snackbar(
        'Erreur',
        'Impossible d\'initialiser la caméra',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> onQrCodeScanned(String number) async {
    if (isProcessing.value || isLoading.value) return;
    
    isProcessing.value = true;
    isLoading.value = true;
    isScanning.value = false;
    
    try {
      // Arrêter temporairement le scanner
      await scannerController.stop();
      
      final userData = await fireStoreService.getUserByPhone(number);
      if (userData != null) {
        scannedData.value = number; // Pour afficher le dialogue
        await Future.delayed(const Duration(seconds: 2)); // Délai pour montrer le dialogue
        await Get.toNamed('/user-actions', arguments: userData);
        await resetAllStates();
      } else {
        Get.snackbar(
          'Utilisateur non trouvé',
          'Aucun utilisateur trouvé avec ce numéro',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        await resetAllStates();
      }
    } catch (e) {
      error.value = 'Erreur lors de la recherche: $e';
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la recherche',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      await resetAllStates();
    } finally {
      isLoading.value = false;
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    cleanupScanner();
    super.onClose();
  }
}