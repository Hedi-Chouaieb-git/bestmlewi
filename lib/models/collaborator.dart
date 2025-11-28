class Collaborator {
  final String idCollab;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final bool disponible;
  final String? telephone;
  final String? salesPointId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Collaborator({
    required this.idCollab,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.disponible = true,
    this.telephone,
    this.salesPointId,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$prenom $nom';

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      idCollab: json['idCollab'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      disponible: json['disponible'] as bool? ?? true,
      telephone: json['telephone'] as String?,
      salesPointId: json['salesPointId'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCollab': idCollab,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role,
      'disponible': disponible,
      'telephone': telephone,
      'salesPointId': salesPointId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

