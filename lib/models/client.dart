class Client {
  final String idClient;
  final String nom;
  final String? prenom;
  final String? email;
  final String phone;
  final String? adresse;
  final String? ville;
  final String? codePostal;
  final bool favorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    required this.idClient,
    required this.nom,
    this.prenom,
    this.email,
    required this.phone,
    this.adresse,
    this.ville,
    this.codePostal,
    this.favorite = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      idClient: json['idClient'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      adresse: json['adresse'] as String?,
      ville: json['ville'] as String?,
      codePostal: json['codePostal'] as String?,
      favorite: json['favorite'] as bool? ?? false,
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
      'idClient': idClient,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'phone': phone,
      'adresse': adresse,
      'ville': ville,
      'codePostal': codePostal,
      'favorite': favorite,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

