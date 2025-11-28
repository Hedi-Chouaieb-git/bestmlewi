class SalesPoint {
  final String id;
  final String title;
  final String status; // OPEN, CLOSED
  final String? address;
  final String? collaborators; // JSON or comma-separated IDs
  final DateTime? createdAt;

  SalesPoint({
    required this.id,
    required this.title,
    required this.status,
    this.address,
    this.collaborators,
    this.createdAt,
  });

  bool get isOpen => status.toUpperCase() == 'OPEN';

  factory SalesPoint.fromJson(Map<String, dynamic> json) {
    return SalesPoint(
      id: json['id'] as String? ?? json['idPoint'] as String,
      title: json['title'] as String? ?? json['nom'] as String,
      status: json['status'] as String? ?? (json['ouvert'] == true ? 'OPEN' : 'CLOSED'),
      address: json['address'] as String? ?? json['adresse'] as String?,
      collaborators: json['collaborators'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPoint': id,
      'nom': title,
      'ouvert': status.toUpperCase() == 'OPEN',
      'adresse': address,
      'collaborators': collaborators,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
