import 'package:flutter/material.dart';
import 'package:flutter3/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter3/app/modules/auth/service_auth.dart';
import 'package:flutter3/app/modules/qr/controllers/qr_controller.dart';
import 'package:flutter3/app/modules/qr/views/qr_scanner_view.dart';
import 'package:flutter3/app/modules/retrait/controllers/retrait_controller.dart';
import 'package:flutter3/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:flutter3/app/utils/email_service.dart';
import 'package:get/get.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import './app/modules/firestore/service_firestore.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
    webProvider: ReCaptchaV3Provider('6Ld8oIQqAAAAADOmD3JkZg7PDvV4BUKcVr_R4i3I'),
  );
Get.put(EmailService());
Get.put(FireStoreService());


Get.put(AuthService());
Get.put(TransactionController());
Get.put(RetraitController());
Get.put(QrController());
Get.put(QrScannerView());
 await GetStorage.init();
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
