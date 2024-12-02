import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter3/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:flutter3/app/utils/email_service.dart';
import 'package:get/get.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/user_model.dart';
import 'dart:math';

class FireStoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailService mail = Get.find();
  Future<void> create(String collection, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).add(data);
    } catch (e) {
      Get.snackbar('Erreur de création', e.toString());
    }
  }
  Future<DocumentReference> create2(String collection, Map<String, dynamic> data) async {
  try {
    return await _firestore.collection(collection).add(data);
  } catch (e) {
    print('Error creating document: $e');
    rethrow;
  }
}
Future<List<Map<String, dynamic>>> getWhere(
      String collection, String field, {required dynamic isEqualTo}) async {
    try {
      // Requête Firestore avec un filtre where
      final querySnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where(field, isEqualTo: isEqualTo)
          .get();

      // Transformation des résultats en une liste de Map
      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des données avec where : $e');
      rethrow; // Repropager l'exception si nécessaire
    }
  }
  Future<void> update(String collection, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      Get.snackbar('Erreur de mise à jour', e.toString());
    }
  }

  Future<void> delete(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      Get.snackbar('Erreur de suppression', e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> get(String collection) async {
    try {
      return (await _firestore.collection(collection).get()).docs.map((doc) => doc.data()).toList();
    } catch (e) {
      Get.snackbar('Erreur de récupération', e.toString());
      return [];
    }
  }

  Future<User2?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User2.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur de récupération de l\'utilisateur : $e');
      return null;
    }
  }

 Future<List<Transactions>> getTransactionsByUser(String userId) async {
  try {
    print('Fetching transactions for UserIdjshjdshdjssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss: $userId');

    // Query for sent transactions
    final sentTransactionsQuery = await _firestore
        .collection('transactions')
        .where('idSender', isEqualTo: userId)
        .get();
    print('Sent Transactions: ${sentTransactionsQuery.docs.length}');

    // Query for received transactions
    final receivedTransactionsQuery = await _firestore
        .collection('transactions')
        .where('idReceiver', isEqualTo: userId)
        .get();
    print('Received Transactions: ${receivedTransactionsQuery.docs.length}');

    // Combine results
    final allTransactions = [
      ...sentTransactionsQuery.docs,
      ...receivedTransactionsQuery.docs,
    ];

    // Log documents with null timestamps
    allTransactions.forEach((doc) {
      if (doc.data()['timestamp'] == null) {
        print('Document with null timestamp: ${doc.id}');
      }
    });

    // Sort by timestamp
    allTransactions.sort((a, b) {
      final dateA = (a.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = (b.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    // Map to Transactions objects
    var filtered =allTransactions
        .map((doc) => Transactions.fromMap(doc.id, doc.data()))
        .toList();
        filtered.forEach((fil){
          print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");
          print(fil.toMap());
          print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");
        });
        print(filtered);
        print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");
    return filtered;
  } catch (e, stacktrace) {
    print('Error fetching transactions: $e');
    print(stacktrace);
    Get.snackbar('Erreur', e.toString());
    return [];
  }
}




  Future<void> addUser(User2 user) async {
    try {
      await _firestore.collection('users').add(user.toMap());
      Get.snackbar('Succès', 'Utilisateur créé avec succès');
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }
  Future<Map<String, dynamic>?> getCollectionById(String collection, String documentId) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de récupérer les données : $e');
      return null;
    }
  }

 Future<Transactions> addTransaction(Transactions transaction) async {
  try {
    // Ajouter la transaction dans Firestore
    DocumentReference docRef = await _firestore
        .collection('transactions')
        .add(transaction.toMap());

    // Récupérer les données du document inséré
    DocumentSnapshot docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Extraire les données et construire un objet Transactions
      var data = docSnapshot.data() as Map<String, dynamic>;
      var trans = Transactions.fromMap(docRef.id, data);

      print(trans.toMap());
      Get.snackbar('Succès', 'Transaction créée avec succès : ${docRef.id}');
      
      return trans; // Retourne la transaction complète avec ID et données
    } else {
      throw Exception('Erreur : Le document inséré est introuvable.');
    }
  } catch (e) {
    Get.snackbar('Erreur', e.toString());
    throw e; // Relancer l'exception pour une gestion éventuelle
  }
}


  Future<void> updateUserBalance(String userId, double newBalance) async {
    try {
      await _firestore.collection('users').doc(userId).update({'solde': newBalance});
      Get.snackbar('Succès', 'Solde mis à jour avec succès');
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<User2?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('mail', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return User2.fromMap(querySnapshot.docs.first.id, data);
      }
      return null;
    } catch (e) {
      print('Erreur de récupération : $e');
      return null;
    }
  }

  Future<List<Transactions>> getAllTransactions() async {
    try {
      final snapshot = await _firestore.collection('transactions').get();
      return snapshot.docs.map((doc) => Transactions.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
      return [];
    }
  }

  

 Future<User2?> getUserByPhone(String phone) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: phone)
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) {
        return null;
      }
      
      return User2.fromMap(
         userDoc.docs.first.id,
        userDoc.docs.first.data(),
      );
    } catch (e) {
      throw Exception('Erreur lors de la recherche de l\'utilisateur: $e');
    }
  }

  Future<void> sendValidationCode(String email) async {
    final code = (100000 + Random().nextInt(900000)).toString();
    
    try {
      await _firestore.collection('validationCodes').add({
        'email': email,
        'code': code,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 15))
        ),
        'used': false
      });

      await mail.sendEmail(to :email, subject: 'Code de validation',
       body:  'Votre code de validation est: $code');
        
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du code: $e');
    }
  }

  Future<bool> verifyCode(String email, String code) async {
  try {
    final codeQuery = await _firestore
        .collection('validationCodes')
        .where('email', isEqualTo: email)
        .where('code', isEqualTo: code)
        .where('used', isEqualTo: false)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .limit(1)
        .get();

    if (codeQuery.docs.isEmpty) {
      return false;
    }

    await codeQuery.docs.first.reference.delete();
    return true;
  } catch (e) {
    throw Exception('Erreur lors de la vérification du code: $e');
  }
}
  collection(String s) {}
}
