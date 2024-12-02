import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/firestore_controller.dart';

class FirestoreView extends GetView<FirestoreController> {
  const FirestoreView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FirestoreView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'FirestoreView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
