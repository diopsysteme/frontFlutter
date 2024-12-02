import 'package:get/get.dart';

import '../controllers/retrait_controller.dart';

class RetraitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RetraitController>(
      () => RetraitController(),
    );
  }
}
