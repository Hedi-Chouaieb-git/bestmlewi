class Collaborator {
  final String idCollab;
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String role;
  final String? idPointAffecte; // Assigned sales point
  final bool disponible;
  final String? telephone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Collaborator({
    required this.idCollab,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.role,
    this.idPointAffecte,
    this.disponible = true,
    this.telephone,
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
      password: json['password'] as String? ?? '',
      role: json['role'] as String,
      idPointAffecte: json['idPointAffecte'] as String?,
      disponible: json['disponible'] as bool? ?? true,
      telephone: json['telephone'] as String?,
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
      'password': password,
      'role': role,
      'idPointAffecte': idPointAffecte,
      'disponible': disponible,
      'telephone': telephone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
