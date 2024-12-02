class Transactions {
  final String id; // Identifiant unique de la transaction
  final String idSender; // Identifiant de l'envoyeur
  final String idReceiver; // Identifiant du receveur
  final double montant; // Montant de la transaction
  final String type; // Type de transaction : "transfert", "retrait", "depot"
  final double frais; // Frais associés à la transaction
  final DateTime date; // Date de la transaction
  final double soldeSender; // Solde de l'envoyeur après la transaction
  final double soldeReceiver; // Solde du receveur après la transaction
  final String statut; // Statut de la transaction : "success", "failed", "annulé", etc.
  final String motif; // Motif ou explication de la transaction

  // Constructeur principal
  Transactions({
    required this.id,
    required this.idSender,
    required this.idReceiver,
    required this.montant,
    required this.type,
    required this.frais,
    required this.date,
    required this.soldeSender,
    required this.soldeReceiver,
    required this.statut,
    required this.motif,
  });

  // Méthode `copyWith` pour créer une copie avec des valeurs modifiées
  Transactions copyWith({
    String? id,
    String? idSender,
    String? idReceiver,
    double? montant,
    String? type,
    double? frais,
    DateTime? date,
    double? soldeSender,
    double? soldeReceiver,
    String? statut,
    String? motif,
  }) {
    return Transactions(
      id: id ?? this.id,
      idSender: idSender ?? this.idSender,
      idReceiver: idReceiver ?? this.idReceiver,
      montant: montant ?? this.montant,
      type: type ?? this.type,
      frais: frais ?? this.frais,
      date: date ?? this.date,
      soldeSender: soldeSender ?? this.soldeSender,
      soldeReceiver: soldeReceiver ?? this.soldeReceiver,
      statut: statut ?? this.statut,
      motif: motif ?? this.motif,
    );
  }

  // Factory pour convertir un document Firestore (ou autre Map) en `Transactions`
  factory Transactions.fromMap(String id, Map<String, dynamic> data) {
    return Transactions(
      id: id,
      idSender: data['idSender'] ?? '',
      idReceiver: data['idReceiver'] ?? '',
      montant: (data['montant'] ?? 0).toDouble(),
      type: data['type'] ?? '',
      frais: (data['frais'] ?? 0).toDouble(),
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      soldeSender: (data['soldeSender'] ?? 0).toDouble(),
      soldeReceiver: (data['soldeReceiver'] ?? 0).toDouble(),
      statut: data['statut'] ?? 'unknown',
      motif: data['motif'] ?? 'Motif inconnu',
    );
  }

  // Méthode pour convertir une instance `Transactions` en Map
  Map<String, dynamic> toMap() {
    return {
      'idSender': idSender,
      'idReceiver': idReceiver,
      'montant': montant,
      'type': type,
      'frais': frais,
      'date': date.toIso8601String(),
      'soldeSender': soldeSender,
      'soldeReceiver': soldeReceiver,
      'statut': statut,
      'motif': motif,
    };
  }
}
