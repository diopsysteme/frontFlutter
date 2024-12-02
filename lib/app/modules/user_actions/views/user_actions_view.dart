import 'package:flutter/material.dart';
import 'package:flutter3/app/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserActionsView extends StatelessWidget {
  final User2 userData;

  const UserActionsView({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(userData.toMap());
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Détails du Client'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card d'information utilisateur
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userData.nom ?? 'Client',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.account_circle, 
                          size: 40, 
                          color: Colors.blue[700]
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow('Numéro de compte', userData.telephone ?? ''),
                    _buildInfoRow('Solde', '${userData.solde ?? 0} FCFA'),
                    _buildInfoRow('Type de compte', userData.type ?? ''),
                  ].animate(interval: 100.ms).fadeIn().slideX(),
                ),
              ),
            ).animate().scale(delay: 100.ms),
            
            const SizedBox(height: 24),
            
            // Section des actions
            const Text(
              'Actions Disponibles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Cartes d'action
            _buildActionCard(
              'Dépôt',
              'Effectuer un dépôt sur le compte',
              Icons.arrow_downward,
              Colors.green,
              () => Get.toNamed('/depot', arguments: userData.telephone),
            ).animate().scale(delay: 200.ms),
            
            const SizedBox(height: 12),
            
            _buildActionCard(
              'Retrait',
              'Effectuer un retrait du compte',
              Icons.arrow_upward,
              Colors.red,
              () => Get.toNamed('/retrait', arguments: userData.telephone),
            ).animate().scale(delay: 300.ms),
            
            const SizedBox(height: 12),
            
            _buildActionCard(
              'Déplafonnement',
              'Modifier les limites du compte',
              Icons.settings,
              Colors.blue,
              () => Get.toNamed('/limit-change', arguments: userData.telephone),
            ).animate().scale(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}