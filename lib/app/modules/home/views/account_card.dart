import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter3/app/modules/auth/service_auth.dart';
import '../../../../constant.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Get.find();

    return Obx(() {
      
      
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // User Info Section
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          auth.currentUser.value!.prenom,
                          style: const TextStyle(color: AppColors.searchBarFill),
                        ),
                        const Icon(Icons.copy, color: AppColors.searchBarFill, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Savings Account',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NGN ${auth.currentUser.value!.solde}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // QR Code Section - Now Centered and Larger
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data:  auth.currentUser.value!.telephone ,
                    version: QrVersions.auto,
                    size: 180.0, // Increased size
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Votre Code QR Personnel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                 if ( auth.currentUser.value!.type!= 'client') // Bouton affiché uniquement si l'utilisateur n'est pas "client"
  ElevatedButton.icon(
    onPressed: () => Get.toNamed('/qr'),
    icon: const Icon(Icons.qr_code_scanner),
    label: const Text('Scanner un QR Code'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[700],
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),

                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}