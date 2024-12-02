import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'trans_card.dart';
import '../../controllers/schedule_controller.dart';

class TransfersList extends StatelessWidget {
  TransfersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScheduleController controller = Get.put(ScheduleController());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) => controller.filterTransfers(value),
            decoration: InputDecoration(
              labelText: 'Rechercher des transferts',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(
            () {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final transfers = controller.filteredTransfers;

              if (transfers.isEmpty) {
                return const Center(
                  child: Text('Aucun transfert trouvé.'),
                );
              }

              return ListView.builder(
                itemCount: transfers.length,
                itemBuilder: (context, index) {
                  final transfer = transfers[index];

                  // Handle the contacts list safely
                  String contactsString = '';
                  if (transfer['contacts'] != null) {
                    if (transfer['contacts'] is List) {
                      contactsString = (transfer['contacts'] as List)
                          .map((e) => e.toString())
                          .join(', ');
                    } else {
                      contactsString = transfer['contacts'].toString();
                    }
                  }

                 return TransferCard(
  id: transfer['id'],
  contacts: contactsString,
  montant: transfer['montant'],
  type: transfer['type'],
  active: transfer['active'] ?? false, // Ajout de la valeur par défaut
  frequency: transfer['frequency'],
  onDelete: controller.cancelScheduledTransfer,
  onDeactivate: controller.deactivateSchedule,
  onActivate: controller.activateSchedule,
);

                },
              );
            },
          ),
        ),
      ],
    );
  }
}
