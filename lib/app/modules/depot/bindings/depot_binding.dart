import 'package:get/get.dart';

import '../controllers/depot_controller.dart';

class DepotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DepotController>(
      () => DepotController(),
    );
  }
}
