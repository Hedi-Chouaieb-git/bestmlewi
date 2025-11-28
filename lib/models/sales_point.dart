class SalesPoint {
  final String idPoint;
  final String nom;
  final String? adresse;
  final String? ville;
  final String? telephone;
  final bool ouvert;
  final String? heureOuverture;
  final String? heureFermeture;
  final DateTime? createdAt;

  SalesPoint({
    required this.idPoint,
    required this.nom,
    this.adresse,
    this.ville,
    this.telephone,
    this.ouvert = true,
    this.heureOuverture,
    this.heureFermeture,
    this.createdAt,
  });

  String get id => idPoint;
  String get title => nom;
  String get address => adresse ?? 'Adresse non spécifiée';
  bool get isOpen => ouvert;
  String? get collaborators => null; // Not stored in this model, could be fetched separately

  factory SalesPoint.fromJson(Map<String, dynamic> json) {
    return SalesPoint(
      idPoint: json['idPoint'] as String,
      nom: json['nom'] as String,
      adresse: json['adresse'] as String?,
      ville: json['ville'] as String?,
      telephone: json['telephone'] as String?,
      ouvert: json['ouvert'] as bool? ?? true,
      heureOuverture: json['heureOuverture'] as String?,
      heureFermeture: json['heureFermeture'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPoint': idPoint,
      'nom': nom,
      'adresse': adresse,
      'ville': ville,
      'telephone': telephone,
      'ouvert': ouvert,
      'heureOuverture': heureOuverture,
      'heureFermeture': heureFermeture,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
