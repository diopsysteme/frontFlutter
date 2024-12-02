import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';

class ScheduledTransferPage extends StatelessWidget {
  final ScheduleController controller =
      Get.put(ScheduleController());
 final selectedType = 'TRANSFERT'.obs; 
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Schedule')),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAmountInput(),
                        const SizedBox(height: 16),
                        _buildTransactionTypeSelector(),
                        const SizedBox(height: 16),
                        _buildFrequencySelector(),
                        const SizedBox(height: 16),
                        _buildContactSearch(),
                        const SizedBox(height: 8),
                        _buildSelectedContactChips(context),
                        const SizedBox(height: 16),
                        _buildContactListContainer(),
                        const SizedBox(height: 16),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

 Widget _buildContactListContainer() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(
        () => controller.filteredContacts.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No contacts found",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: controller.filteredContacts.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                itemBuilder: (context, index) {
                  final contact = controller.filteredContacts[index];
                  final isSelected = controller.selectedContacts.contains(contact);
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade200,
                      child: Text(
                        contact.displayName[0].toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.displayName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      contact.phones.isNotEmpty
                          ? contact.phones.first.number
                          : 'No phone number',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () => controller.selectContact(contact),
                    selected: isSelected,
                  );
                },
              ),
      ),
    );
  }
  Widget _buildAmountInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller.amountController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Transfer Amount',
          prefixIcon: const Icon(Icons.attach_money),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an amount';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

 Widget _buildTransactionTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: controller.selectedType.value,
        decoration: InputDecoration(
          labelText: 'Transaction Type',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: const [
          DropdownMenuItem(value: 'TRANSFERT', child: Text('Transfer')),
          DropdownMenuItem(value: 'OTHER', child: Text('Other')),
        ],
        onChanged: (value) => controller.selectedType.value = value!,
        validator: (value) => value == null ? 'Please select a type' : null,
      ),
    );
  }
 Widget _buildSelectedContactChips(context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.selectedContacts.map((contact) {
          return Chip(
            avatar: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                contact.displayName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            label: Text(contact.displayName),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => controller.removeContact(contact),
          );
        }).toList(),
      ),
    );
  }
  Widget _buildFrequencySelector() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      children: [
        Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedFrequency.value,
              decoration: InputDecoration(
                labelText: 'Transfer Frequency',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: controller.frequencyOptions
                  .map((freq) => DropdownMenuItem(
                        value: freq,
                        child: Text(freq),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedFrequency.value = value;
                }
              },
            )),
        Obx(() {
          return controller.selectedFrequency.value == 'EVERY_X_DAYS'
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    initialValue: controller.customInterval.value.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Interval Days',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) {
                      final parsedValue = int.tryParse(value);
                      if (parsedValue != null) {
                        controller.customInterval.value = parsedValue;
                      }
                    },
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    ),
  );
}


  Widget _buildContactSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          labelText: 'Search Contacts',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: controller.filterContacts,
      ),
    );
  }

  // Widget _buildSelectedContactChips() {
  //   return Obx(
  //     () => Wrap(
  //       spacing: 8,
  //       runSpacing: 4,
  //       children: controller.selectedContacts
  //           .map((contact) => Chip(
  //                 label: Text(contact.displayName),
  //                 onDeleted: () => controller.removeContact(contact),
  //               ))
  //           .toList(),
  //     ),
  //   );
  // }

Widget _buildContactList() {
  return Obx(
    () => controller.filteredContacts.isEmpty
        ? Center(child: Text("No contacts found."))
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = controller.filteredContacts[index];
              return ListTile(
                title: Text(contact.displayName),
                subtitle: Text(contact.phones.isNotEmpty
                    ? contact.phones.first.number
                    : 'No phone number'),
                onTap: () => controller.selectContact(contact),
              );
            },
          ),
  );
}


  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: controller.submitScheduledTransfer,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Create Scheduled Transfer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
