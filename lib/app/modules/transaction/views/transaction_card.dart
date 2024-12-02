import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/transaction_model.dart';
import '../../../modules/auth/service_auth.dart';
import '../controllers/transaction_controller.dart';

class TransactionCard extends StatelessWidget {
  final Transactions transaction;
    final AuthService authService = Get.find();
  final TransactionController _controller = Get.find();

  TransactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  bool get isCurrentUserSender {
        print(transaction.idSender);
        print( authService.currentUser.value?.id);
      return transaction.idSender == authService.currentUser.value?.id;
  }

 bool get canCancel {
 if (transaction.type.toUpperCase() == 'RETRAIT') return false;
    // Vérifier si la transaction est réussie
    if (transaction.statut.toUpperCase() != 'SUCCESS') return false;
    
    final currentUser = authService.currentUser.value;
    if (currentUser == null) return false;

    final now = DateTime.now();
    final transactionDate = DateTime.parse(transaction.date.toString());
    final timeDifference = now.difference(transactionDate);

    // Si c'est un client, vérifier la limite de 30 minutes
    if (currentUser.type?.toLowerCase() == 'client') {
      return timeDifference.inMinutes <= 30;
    }

    // Pour les autres types d'utilisateurs (admin, agent, etc.), 
    // le bouton est toujours affiché
    return true;
  }

  Future<void> _showCancelConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer l\'annulation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text('Êtes-vous sûr de vouloir annuler cette transaction ?'),
                const SizedBox(height: 8),
                Text(
                  'Montant: ${transaction.montant.toStringAsFixed(2)} ₦',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Oui, annuler'),
              onPressed: () {
                Navigator.of(context).pop();
                _controller.cancelTransaction(transaction);
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor() {
    switch (transaction.statut.toUpperCase()) {
      case 'SUCCESS':
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'ANNULE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTransactionTitle() {
    if (isCurrentUserSender) {
      switch (transaction.type.toUpperCase()) {
        case 'TRANSFERT':
          return 'Envoyé à ${_formatId(transaction.idReceiver)}';
        case 'RETRAIT':
          return 'Retrait';
        case 'DEPOT':
          return 'Dépôt';
        default:
          return 'Transaction';
      }
    } else {
      switch (transaction.type.toUpperCase()) {
        case 'TRANSFERT':
          return 'Reçu de ${_formatId(transaction.idSender)}';
        case 'RETRAIT':
          return 'Retrait';
        case 'DEPOT':
          return 'Dépôt';
        default:
          return 'Transaction';
      }
    }
  }

  String _formatId(String id) {
    return id.length > 6 ? '${id.substring(0, 6)}...' : id;
  }

  IconData _getTransactionIcon() {
    if (isCurrentUserSender) {
      switch (transaction.type.toUpperCase()) {
        case 'TRANSFERT':
          return Icons.arrow_upward;
        case 'RETRAIT':
          return Icons.account_balance_wallet;
        case 'DEPOT':
          return Icons.arrow_downward;
        default:
          return Icons.swap_horiz;
      }
    } else {
      switch (transaction.type.toUpperCase()) {
        case 'TRANSFERT':
          return Icons.arrow_downward;
        case 'RETRAIT':
          return Icons.account_balance_wallet;
        case 'DEPOT':
          return Icons.arrow_downward;
        default:
          return Icons.swap_horiz;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = isCurrentUserSender ? -transaction.montant : transaction.montant;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Afficher les détails de la transaction
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icône avec background
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTransactionIcon(),
                        color: _getStatusColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Informations principales
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTransactionTitle(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.date.toString().substring(0, 16),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Montant et statut
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} ₦',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: amount >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.statut.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Bouton d'annulation conditionnel
             if (canCancel) ...[
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 20),
                      label: const Text('Annuler la transaction'),
                      onPressed: () => _showCancelConfirmation(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}