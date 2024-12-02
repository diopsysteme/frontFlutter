import 'package:get/get.dart';

import '../controllers/user_actions_controller.dart';

class UserActionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserActionsController>(
      () => UserActionsController(),
    );
  }
}
