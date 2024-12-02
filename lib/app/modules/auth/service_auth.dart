import 'package:flutter3/app/modules/qr/controllers/qr_controller.dart';
import 'package:flutter3/app/modules/qr/views/qr_scanner_view.dart';
import 'package:flutter3/app/modules/retrait/controllers/retrait_controller.dart';
import 'package:flutter3/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:flutter3/app/utils/email_service.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../firestore/service_firestore.dart';
import 'dart:async'; // Import nécessaire pour Completer
import 'package:get_storage/get_storage.dart';
class AuthService extends GetxService{
 final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxBool isLoading = false.obs;
  final RxBool isOtpSent = false.obs;
  final RxString verificationId = ''.obs;
  final FireStoreService _fireStoreService = FireStoreService();
  final box = GetStorage(); // Instance de GetStorage

  Future<void> onInit() async {
    super.onInit();
    // loadUserFromStorage();
  }

 final Rxn<User2> currentUser = Rxn<User2>(); // Observable user
  
  // Définir si l'utilisateur est connecté
  bool get isLoggedIn => currentUser.value != null;
void updateUserBalance(double newBalance) {
  print("before update user balance");
  if (currentUser.value != null) {
    print("after update user balance");
    // Mettre à jour le solde de l'utilisateur
    currentUser.value!.solde= newBalance;
    var newUser = currentUser.value;
    setUser(newUser);
    // Sauvegarder les changements dans le stockage
    saveUserToStorage();
  } else {
    Get.snackbar('Erreur', 'Aucun utilisateur connecté');
  }
}

  // Met à jour les informations de l'utilisateur
  void setUser(User2? user) {
    
    currentUser.value = user;
    saveUserToStorage();
  }

  void clearUser() {
    currentUser.value = null;
     GetStorage().remove('user');
     box.remove('user');
      GetStorage().erase();
      box.erase();
  }

  void saveUserToStorage() {
    
      GetStorage().write('user', currentUser.value!.toMap());
    
  }

  void loadUserFromStorage() {
    final userData = currentUser.value;
    
  }

 Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      Get.snackbar('Erreur', 'Authentification échouée');
      return;
    }

    final userEmail = firebaseUser.email ?? '';
    var existingUser = await _fireStoreService.getUserByEmail(userEmail);

    if (existingUser == null) {
      final newUser = await _showUserDetailsDialog(
        name: firebaseUser.displayName ?? '',
        email: userEmail,
      );
      if (newUser == null) {
        await _auth.signOut();
        Get.snackbar('Erreur', 'Informations manquantes pour l’enregistrement');
        return;
      }
       existingUser=newUser;

      await _fireStoreService.addUser(newUser);
      Get.snackbar('Succès', 'Utilisateur enregistré avec succès');
    }
    User2 user2 = User2(
      id: existingUser.id,
      nom: existingUser.nom,
      prenom: existingUser.prenom,
      telephone: existingUser.telephone, 
      mail: existingUser.mail,
      type: existingUser.type, 
      solde: 0.0, 
      code: existingUser.code, 
      plafond: existingUser.plafond
    );
    // GetStorage().write('user', currentUser.value!.toMap());
    setUser(user2);

    Get.snackbar('Succès', 'Connexion réussie');
    Get.offAllNamed('/home');
  } catch (e) {
    Get.snackbar('Erreur', 'Connexion Google impossible: $e');
  }
}


  User2? getCurrentUser() {
    var userData = box.read('user');
    if (userData != null) {
      return User2.fromMap(userData['id'], userData);
    }
    return null;
  }
Future<void> signOut() async {
  try {
    // Déconnexion des services
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();

    // Suppression des données locales
    box.remove('user'); 
    currentUser.value = null;
    clearUser();

    // Suppression des services et contrôleurs enregistrés

    // Notification utilisateur
    Get.snackbar(
      'Déconnexion réussie',
      'À bientôt 👋',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.greenAccent,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  } catch (e) {
    // Gestion des erreurs
    Get.snackbar(
      'Erreur de déconnexion',
      'Une erreur est survenue. Veuillez réessayer.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
    debugPrint('Erreur lors de la déconnexion : $e');
  }
}



  // Future<void> signInWithGoogle() async {
  //   try {
  //     // Connexion via Google
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) return; // L'utilisateur a annulé

  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // Authentification Firebase
  //     final UserCredential userCredential = await _auth.signInWithCredential(credential);
  //     final User? firebaseUser = userCredential.user;

  //     if (firebaseUser == null) {
  //       Get.snackbar('Erreur', 'Authentification échouée');
  //       return;
  //     }

  //     // Vérification si l'utilisateur existe déjà dans Firestore
  //     final userEmail = firebaseUser.email ?? '';
  //     final existingUser = await _fireStoreService.getUserByEmail(userEmail);

  //     if (existingUser == null) {
  //       // Collecter les données supplémentaires de l'utilisateur
  //       final newUser = await _showUserDetailsDialog(
  //         name: firebaseUser.displayName ?? '',
  //         email: userEmail,
  //       );

  //       if (newUser == null) {
  //         await _auth.signOut();
  //         Get.snackbar('Erreur', 'Informations manquantes pour l’enregistrement');
  //         return;
  //       }

  //       // Ajouter le nouvel utilisateur à Firestore
  //       await _fireStoreService.addUser(newUser);
  //       Get.snackbar('Succès', 'Utilisateur enregistré avec succès');
  //     }

  //     // Connexion réussie
  //     Get.snackbar('Succès', 'Connexion réussie');
  //     Get.offAllNamed('/home');
  //   } catch (e) {
  //     Get.snackbar('Erreur', 'Connexion Google impossible: $e');
  //   }
  // }

  Future<User2?> _showUserDetailsDialog({required String name, required String email}) async {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final Completer<User2?> completer = Completer<User2?>();

    Get.dialog(
      AlertDialog(
        title: const Text('Complétez vos informations'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (phoneController.text.isEmpty || codeController.text.isEmpty) {
                Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
                return;
              }

              final newUser = User2(
                id: '', // Généré par Firestore
                nom: name.split(' ').first,
                prenom: name.split(' ').length > 1 ? name.split(' ').last : '',
                telephone: phoneController.text,
                mail: email,
                type: 'client',
                solde: 0.0,
                code: codeController.text,
                plafond: 10000
              );

              completer.complete(newUser);
              Get.back(); 
            },
            child: const Text('Enregistrer'),
          ),
          TextButton(
            onPressed: () {
              completer.complete(null); // Annuler
              Get.back();
            },
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    return completer.future;
  }
 
 Future<bool> loginWithPhoneAndCode(String phone, String code) async {
  try {
    print('Attempting login with phone: $phone and code: $code');

    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('telephone', isEqualTo: phone)
        .where('code', isEqualTo: code)
        .get();

    print('Query result: ${userQuery.docs.length} documents found');

    if (userQuery.docs.isNotEmpty) {
      print('Login successful for phone: $phone');

      final userData = userQuery.docs.first.data();
      final userId = userQuery.docs.first.id;

      final User2 loggedInUser = User2.fromMap(userId, userData);
print(loggedInUser.toMap());
      setUser(loggedInUser);

      return true;
    } else {
      print('No user found with the given phone and code');
      return false;
    }
  } catch (e) {
    print('Login error: $e');
    return false;
  }
}


  Future<void> _signInWithPhoneAuthCredential(PhoneAuthCredential credential) async {
    try {
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      if (authResult.user != null) {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erreur', 'Échec de la connexion');
    }
  }

// Future<void> signInWithFacebook() async {
//   try {
//     // Affiche un indicateur de chargement
//     Get.dialog(
//       const Center(child: CircularProgressIndicator()),
//       barrierDismissible: false,
//     );

//     // Initialiser Facebook Login
//     final LoginResult result = await FacebookAuth.instance.login();

//     // Fermer le dialogue de chargement après réponse
//     if (Get.isDialogOpen ?? false) Get.back();

//     switch (result.status) {
//       case LoginStatus.success:
//         final AccessToken? accessToken = result.accessToken;

//         if (accessToken == null) {
//           throw 'Token d\'accès Facebook introuvable';
//         }

//         // Récupérer les données utilisateur depuis Facebook
//         final userData = await FacebookAuth.instance.getUserData();
//         final String? email = userData['email'];
//         final String name = userData['name'] ?? 'Utilisateur Facebook';

//         if (email == null || email.isEmpty) {
//           throw 'L\'email n\'a pas pu être récupéré depuis Facebook';
//         }

//         // Créer les informations d'identification Firebase
//         final OAuthCredential credential = FacebookAuthProvider.credential(
//           accessToken.token,
//         );

//         // Se connecter à Firebase
//         final UserCredential userCredential =
//             await FirebaseAuth.instance.signInWithCredential(credential);
//         final User? firebaseUser = userCredential.user;

//         if (firebaseUser == null) {
//           throw 'Authentification Firebase échouée';
//         }

//         // Vérifier si l'utilisateur existe déjà dans Firestore
//         var existingUser = await _fireStoreService.getUserByEmail(email);

//         if (existingUser == null) {
//           // Si l'utilisateur n'existe pas, demander les informations manquantes
//           final newUser = await _showUserDetailsDialog(
//             name: name,
//             email: email,
//           );

//           if (newUser == null) {
//             await FirebaseAuth.instance.signOut();
//             Get.snackbar('Erreur', 'Informations nécessaires pour l\'enregistrement manquantes');
//             return;
//           }

//           // Ajouter le nouvel utilisateur dans Firestore
//           await _fireStoreService.addUser(newUser);
//           Get.snackbar('Succès', 'Utilisateur enregistré avec succès');
//           existingUser = newUser;
//         }

//         // Mise à jour de l'utilisateur dans le contrôleur
//         final User2 user2 = User2(
//           id: existingUser.id,
//           nom: existingUser.nom,
//           prenom: existingUser.prenom,
//           telephone: existingUser.telephone,
//           mail: existingUser.mail,
//           type: existingUser.type,
//           solde: existingUser.solde,
//           code: existingUser.code,
//           plafond: existingUser.plafond,
//         );

//         setUser(user2);

//         // Navigation vers la page d'accueil
//         Get.snackbar('Succès', 'Connexion réussie');
//         Get.offAllNamed('/home');
//         break;

//       case LoginStatus.cancelled:
//         Get.snackbar(
//           'Annulé',
//           'La connexion avec Facebook a été annulée',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         break;

//       case LoginStatus.failed:
//         Get.snackbar(
//           'Erreur',
//           'Échec de la connexion Facebook: ${result.message}',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         break;

//       default:
//         Get.snackbar(
//           'Erreur',
//           'Une erreur inattendue s\'est produite',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//     }
//   } catch (e) {
//     if (Get.isDialogOpen ?? false) Get.back();

//     Get.snackbar(
//       'Erreur',
//       'Erreur de connexion: $e',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//     print('Erreur lors de la connexion avec Facebook: $e');
//   }
// }


Future<void> signInWithFacebook() async {
  try {
    // Affiche un indicateur de chargement
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Initialiser Facebook Login
    final LoginResult result = await FacebookAuth.instance.login();

    // Fermer le dialogue de chargement après réponse
    if (Get.isDialogOpen ?? false) Get.back();

    switch (result.status) {
      case LoginStatus.success:
        final AccessToken? accessToken = result.accessToken;

        if (accessToken == null) {
          throw 'Token d\'accès Facebook introuvable';
        }

        // Récupérer les données utilisateur depuis Facebook
        final userData = await FacebookAuth.instance.getUserData();
        final String? email = userData['email'];
        final String name = userData['name'] ?? 'Utilisateur Facebook';

        if (email == null || email.isEmpty) {
          throw 'L\'email n\'a pas pu être récupéré depuis Facebook';
        }

        // Créer les informations d'identification Firebase
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.token, 
        );

        // Se connecter à Firebase
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;

        if (firebaseUser == null) {
          throw 'Authentification Firebase échouée';
        }

        // Vérifier si l'utilisateur existe déjà dans Firestore
        var existingUser = await _fireStoreService.getUserByEmail(email);

        if (existingUser == null) {
          // Si l'utilisateur n'existe pas, demander les informations manquantes
          final newUser = await _showUserDetailsDialog(
            name: name,
            email: email,
          );

          if (newUser == null) {
            await FirebaseAuth.instance.signOut();
            Get.snackbar('Erreur', 'Informations nécessaires pour l\'enregistrement manquantes');
            return;
          }

          // Ajouter le nouvel utilisateur dans Firestore
          await _fireStoreService.addUser(newUser);
          Get.snackbar('Succès', 'Utilisateur enregistré avec succès');
          existingUser = newUser;
        }

        // Mise à jour de l'utilisateur dans le contrôleur
        final User2 user2 = User2(
          id: existingUser.id,
          nom: existingUser.nom,
          prenom: existingUser.prenom,
          telephone: existingUser.telephone,
          mail: existingUser.mail,
          type: existingUser.type,
          solde: existingUser.solde,
          code: existingUser.code,
          plafond: existingUser.plafond,
        );

        setUser(user2);

        // Navigation vers la page d'accueil
        Get.snackbar('Succès', 'Connexion réussie');
        Get.offAllNamed('/home');
        break;

      case LoginStatus.cancelled:
        Get.snackbar(
          'Annulé',
          'La connexion avec Facebook a été annulée',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      case LoginStatus.failed:
        Get.snackbar(
          'Erreur',
          'Échec de la connexion Facebook: ${result.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        break;

      default:
        Get.snackbar(
          'Erreur',
          'Une erreur inattendue s\'est produite',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
    }
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.snackbar(
      'Erreur',
      'Erreur de connexion: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    print('Erreur lors de la connexion avec Facebook: $e');
  }
}



 
}