import 'package:flutter/material.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  const AmountInputWidget({
    super.key,
    required this.controller,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Montant',
            labelStyle: const TextStyle(color: Colors.white),
            prefixIcon: const Icon(Icons.attach_money, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un montant';
            }
            return null;
          },
        ),
      ),
    );
  }
}
