import 'package:get/get.dart';
import '../../auth/service_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
class AuthController extends GetxController {
final AuthService _authService = Get.find<AuthService>();

  var isOtpSent = false.obs;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  
  var isLoading = false.obs;

  void loginWithPhoneAndCode() async {
    isLoading.value = true;
    try {
      final success = await _authService.loginWithPhoneAndCode(
        phoneController.text, 
        codeController.text
      );
      if (success) {
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Erreur', 'Numéro ou code incorrect v');
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  void signInWithGoogle() async {
    isLoading.value = true;
    await _authService.signInWithGoogle();
   
  }

  void signInWithFacebook() async {
    isLoading.value = true;
    await _authService.signInWithFacebook();
  }

  void navigateToSignUp() {
    Get.toNamed('/sign-up');
  }

  void signOut() async {
    await _authService.signOut();
    Get.offAllNamed('/login'); 
  }
  

  @override
  void onInit() {
    super.onInit();
  }

}
