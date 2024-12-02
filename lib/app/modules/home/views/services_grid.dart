import 'package:flutter/material.dart';
import 'package:flutter3/app/modules/auth/service_auth.dart';
import 'package:get/get.dart';

class ServicesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find();
    var user = authService.currentUser.value!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top services',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ServiceItem(
                  icon: Icons.send,
                  label: 'Send money',
                  onTap: () => Navigator.pushNamed(context, '/transfert'),
                ),
                const SizedBox(width: 16),
                ServiceItem(
                  icon: Icons.phone_android,
                  label: 'Achat crédit',
                  onTap: () => Navigator.pushNamed(context, '/credit'),
                ),
                if (user.type != 'client') ...[
                  const SizedBox(width: 16),
                  ServiceItem(
                    icon: Icons.account_balance_wallet,
                    label: 'Retrait',
                    onTap: () => Navigator.pushNamed(context, '/retrait'),
                  ),
                  const SizedBox(width: 16),
                  ServiceItem(
                    icon: Icons.payments,
                    label: 'Dépôt',
                    onTap: () => Navigator.pushNamed(context, '/depot'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ServiceItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}