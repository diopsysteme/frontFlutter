import 'package:flutter3/app/modules/schedule/schedule/schedule_page.dart';
import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/depot/bindings/depot_binding.dart';
import '../modules/depot/views/depot_view.dart';
import '../modules/firestore/bindings/firestore_binding.dart';
import '../modules/firestore/views/firestore_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/qr/bindings/qr_binding.dart';
import '../modules/qr/views/qr_scanner_view.dart';
import '../modules/qr/views/qr_view.dart';
import '../modules/retrait/bindings/retrait_binding.dart';
import '../modules/retrait/views/retrait_view.dart';
import '../modules/schedule/bindings/schedule_binding.dart';
import '../modules/schedule/views/schedule_view.dart';
import '../modules/transaction/bindings/transaction_binding.dart';
import '../modules/transaction/views/transaction_view.dart';
import '../modules/transfert/bindings/transfert_binding.dart';
import '../modules/transfert/views/transfert_view.dart';
import '../modules/user_actions/bindings/user_actions_binding.dart';
import '../modules/user_actions/views/user_actions_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.AUTH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () =>  HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.FIRESTORE,
      page: () => const FirestoreView(),
      binding: FirestoreBinding(),
    ),
    GetPage(
      name: _Paths.TRANSACTION,
      page: () =>  TransactionView(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: _Paths.TRANSFERT,
      page: () => const TransfertView(sendUnit: "TRANSFERT"),
      binding: TransfertBinding(),
    ),
    // Mise à jour de la route Depot
    GetPage(
      name: _Paths.DEPOT,
      page: () => const DepotView(),
      binding: DepotBinding(),
    ),
    // Mise à jour de la route Retrait
    GetPage(
      name: _Paths.RETRAIT,
      page: () => const RetraitView(),
      binding: RetraitBinding(),
    ),
    GetPage(
      name: _Paths.SCHEDULE,
      page: () => const SchedulePage(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: _Paths.QR,
      page: () => const QrView(),
      binding: QrBinding(),
    ),
    GetPage(
      name: _Paths.QR_SCANNER,
      page: () => const QrScannerView(),
    ),
    GetPage(
      name: _Paths.USER_ACTIONS,
      page: () => UserActionsView(userData: Get.arguments),
      binding: UserActionsBinding(),
    ),
  ];
}
