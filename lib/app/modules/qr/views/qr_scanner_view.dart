import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/qr_controller.dart';

class QrScannerView extends GetView<QrController> {
  const QrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    // Écouter les changements de route pour réinitialiser
    ever(Get.routing.current as RxString, (_) {
      controller.resetAllStates();
      if (Get.currentRoute == '/qr') {
        controller.resetAllStates();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[700],
      ),
      body: Stack(
        children: [
          // QR Scanner
          Obx(() => controller.isScanning.value
              ? MobileScanner(
                  controller: controller.scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                        controller.onQrCodeScanned(barcode.rawValue!);
                      }
                    }
                  },
                )
              : const SizedBox()),

          // Overlay design
          _buildScannerOverlay(),

          // Loading Indicator
          Obx(() => controller.isLoading.value
              ? _buildLoadingIndicator()
              : const SizedBox()),
        ],
      ),
    );
  }

  // Overlay for scanner
  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Placez le QR code dans le cadre',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Loading indicator
  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}