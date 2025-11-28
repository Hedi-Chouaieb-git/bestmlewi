class KitchenMember {
  final String idMembre;
  final String idCollab;
  final String? specialite;
  final int? experience;
  final bool disponible;
  final DateTime? createdAt;

  KitchenMember({
    required this.idMembre,
    required this.idCollab,
    this.specialite,
    this.experience,
    this.disponible = true,
    this.createdAt,
  });

  factory KitchenMember.fromJson(Map<String, dynamic> json) {
    return KitchenMember(
      idMembre: json['idMembre'] as String,
      idCollab: json['idCollab'] as String,
      specialite: json['specialite'] as String?,
      experience: json['experience'] as int?,
      disponible: json['disponible'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMembre': idMembre,
      'idCollab': idCollab,
      'specialite': specialite,
      'experience': experience,
      'disponible': disponible,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
