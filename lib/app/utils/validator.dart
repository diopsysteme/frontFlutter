abstract class Validator {
  String? required(String? value);
  String? email(String? value);
  String? phone(String? value);
  String? length(String? value, {int? min, int? max});
}

class FormValidators implements Validator {
  static final FormValidators _instance = FormValidators._internal();

  FormValidators._internal();

  factory FormValidators() => _instance;

  @override
  String? required(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Ce champ est requis' : null;
  }

  @override
  String? email(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return (value != null && emailRegex.hasMatch(value)) ? null : 'Entrez un email valide';
  }

  @override
  String? phone(String? value) {
    final phoneRegex = RegExp(r'^\d{9}$');
    return (value != null && phoneRegex.hasMatch(value)) ? null : 'Numéro de téléphone invalide';
  }

  @override
  String? length(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) return 'Ce champ est requis';
    if (min != null && value.length < min) return 'Au moins $min caractères requis';
    if (max != null && value.length > max) return 'Pas plus de $max caractères autorisés';
    return null;
  }
}

class CustomValidator implements Validator {
  @override
  String? required(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Champ obligatoire' : null;
  }

  @override
  String? email(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return (value != null && emailRegex.hasMatch(value)) ? null : 'Email invalide';
  }

  @override
  String? phone(String? value) {
    final phoneRegex = RegExp(r'^\+?\d{9,10}$');
    return (value != null && phoneRegex.hasMatch(value)) ? null : 'Numéro de téléphone invalide';
  }

  @override
  String? length(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) return 'Ce champ est requis';
    if (min != null && value.length < min) return 'Doit contenir au moins $min caractères';
    if (max != null && value.length > max) return 'Doit contenir au maximum $max caractères';
    return null;
  }
}
