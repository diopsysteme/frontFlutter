class User2 {
  String id;
  String nom;
  String prenom;
  String telephone;
  String mail;
  String type;
  double solde;
  String code;
  double plafond;  // Nouveau champ ajouté

  User2({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.mail,
    required this.type,
    required this.solde,
    required this.code,
    required this.plafond,  // Ajout dans le constructeur
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'mail': mail,
      'type': type,
      'solde': solde,
      'code': code,
      'plafond': plafond,  // Ajout dans la conversion vers Map
    };
  }

  // Construire un User à partir d'un document Firestore
  factory User2.fromMap(String id, Map<String, dynamic> map) {
    return User2(
      id: id,
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      telephone: map['telephone'] ?? '',
      mail: map['mail'] ?? '',
      type: map['type'] ?? '',
      solde: (map['solde'] ?? 0).toDouble(),
      code: map['code'] ?? '',
      plafond: (map['plafond'] ?? 0).toDouble(),  // Ajout dans la conversion depuis Map
    );
  }
}