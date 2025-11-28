enum RefundStatus { enAttente, approuvee, refusee }

class RefundRequest {
  final String idRefund;
  final String idCommande;
  final String idClient;
  final String motif;
  final RefundStatus statut;
  final double? montantRembourse;
  final String? traiteePar;
  final DateTime? dateTraitement;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RefundRequest({
    required this.idRefund,
    required this.idCommande,
    required this.idClient,
    required this.motif,
    this.statut = RefundStatus.enAttente,
    this.montantRembourse,
    this.traiteePar,
    this.dateTraitement,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory RefundRequest.fromJson(Map<String, dynamic> json) {
    RefundStatus statut;
    switch (json['statut']?.toString().toLowerCase()) {
      case 'approuvee':
        statut = RefundStatus.approuvee;
        break;
      case 'refusee':
        statut = RefundStatus.refusee;
        break;
      case 'en_attente':
      default:
        statut = RefundStatus.enAttente;
        break;
    }

    return RefundRequest(
      idRefund: json['idRefund'] as String,
      idCommande: json['idCommande'] as String,
      idClient: json['idClient'] as String,
      motif: json['motif'] as String,
      statut: statut,
      montantRembourse: json['montantRembourse'] != null
          ? (json['montantRembourse'] as num).toDouble()
          : null,
      traiteePar: json['traiteePar'] as String?,
      dateTraitement: json['dateTraitement'] != null
          ? DateTime.tryParse(json['dateTraitement'].toString())
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String statutString;
    switch (statut) {
      case RefundStatus.approuvee:
        statutString = 'approuvee';
        break;
      case RefundStatus.refusee:
        statutString = 'refusee';
        break;
      case RefundStatus.enAttente:
      default:
        statutString = 'en_attente';
        break;
    }

    return {
      'idRefund': idRefund,
      'idCommande': idCommande,
      'idClient': idClient,
      'motif': motif,
      'statut': statutString,
      'montantRembourse': montantRembourse,
      'traiteePar': traiteePar,
      'dateTraitement': dateTraitement?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
