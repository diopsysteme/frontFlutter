class ScheduledTransferRequestDTO {
  final List<String> contacts;
  final double montant;
  final String type;
  final String frequency;
  final int intervalDays;
  final String userId;

  ScheduledTransferRequestDTO({
    required this.contacts,
    required this.montant,
    required this.type,
    required this.frequency,
    required this.userId,
    this.intervalDays = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'contacts': contacts,
      'montant': montant,
      'type': type,
      'frequency': frequency,
      'intervalDays': intervalDays,
      'userId': userId,
    };
  }
}
