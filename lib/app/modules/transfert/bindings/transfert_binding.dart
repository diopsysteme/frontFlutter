import 'package:get/get.dart';

import '../controllers/transfert_controller.dart';

class TransfertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransfertController>(
      () => TransfertController(),
    );
  }
}
