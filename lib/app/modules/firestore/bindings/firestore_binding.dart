import 'package:get/get.dart';

import '../controllers/firestore_controller.dart';

class FirestoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirestoreController>(
      () => FirestoreController(),
    );
  }
}
