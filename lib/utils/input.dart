import 'package:flutter/material.dart';
abstract class IFormWidgets {
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10.0),
    InputDecoration? decoration,
  });

  Widget buildDropdownField({
    required String label,
    required String? selectedValue,
    required List<String> options,
    void Function(String?)? onChanged,
    String? Function(String?)? validator,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10.0),
    InputDecoration? decoration,
  });

  Widget buildPhotoUploader({
    bool multiple = false,
    int fileCount = 1,
    void Function()? onPressed,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10.0),
    ButtonStyle? style,
  });
}


class FormWidgets implements IFormWidgets {
  @override
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10.0),
    InputDecoration? decoration,
  }) {
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        decoration: decoration ??
            InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  @override
  Widget buildDropdownField({
    required String label,
    required String? selectedValue,
    required List<String> options,
    void Function(String?)? onChanged,
    String? Function(String?)? validator,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10.0),
    InputDecoration? decoration,
  }) {
    return Padding(
      padding: padding,
      child: DropdownButtonFormField<String>(
        decoration: decoration ??
            InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
        value: selectedValue,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  @override
  Widget buildPhotoUploader({
    bool multiple = false,
    int fileCount = 1,
    void Function()? onPressed,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10.0),
    ButtonStyle? style,
  }) {
    return Padding(
      padding: padding,
      child: OutlinedButton.icon(
        onPressed: onPressed ?? () {
          // Implémentez le téléchargement de photo
        },
        icon: const Icon(Icons.camera_alt),
        label: Text(
          multiple ? 'Télécharger $fileCount photos' : 'Télécharger une photo',
        ),
        style: style ??
            OutlinedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
      ),
    );
  }
}

