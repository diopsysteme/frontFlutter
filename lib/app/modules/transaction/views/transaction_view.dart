import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import './transaction_card.dart';

class TransactionView extends StatelessWidget {
  final TransactionController controller = Get.find();

  TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
      controller.fetchTransactionsByConnectedUser();
  
    // print(controller.transactions.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Transactions'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.transactions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(), // Affiche un loader pendant le chargement
          );
        }

        if (controller.transactions.isEmpty && !controller.isLoading.value) {
          // Message "aucune transaction" après le chargement
          return const Center(
            child: Text(
              'No recent transactions',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Afficher la liste des transactions
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent transactions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Implémentez la logique pour "See all"
                      print("See all transactions clicked");
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.transactions[index];
                    return TransactionCard(transaction: transaction);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
