import 'cart_item.dart';

class Order {
  final String idCommande;
  final String idClient;
  final String? idPointVente; // Assigned sales point
  final String? idCollab; // Assigned livreur
  final String? idCuisinier; // Assigned cook
  final String statut; // en_attente, en_preparation, en_cours, livree, annulee
  final DateTime dateCommande;
  final DateTime? dateLivraison;
  final double montantTotal;
  final String adresseLivraison;
  final String? notes;
  final double? latitude; // Client location latitude
  final double? longitude; // Client location longitude
  final DateTime? tempsPreparationDebut; // Preparation start time
  final DateTime? tempsPreparationFin; // Preparation end time
  final DateTime? tempsRemiseLivreur; // Handover to delivery time
  final DateTime? tempsRecuperationLivreur; // Pickup by delivery time
  final DateTime? tempsLivraison; // Delivery completion time
  final List<CartItem>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.idCommande,
    required this.idClient,
    this.idPointVente,
    this.idCollab,
    this.idCuisinier,
    required this.statut,
    required this.dateCommande,
    this.dateLivraison,
    required this.montantTotal,
    required this.adresseLivraison,
    this.notes,
    this.latitude,
    this.longitude,
    this.tempsPreparationDebut,
    this.tempsPreparationFin,
    this.tempsRemiseLivreur,
    this.tempsRecuperationLivreur,
    this.tempsLivraison,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      idCommande: json['idCommande'] as String,
      idClient: json['idClient'] as String,
      idPointVente: json['idPointVente'] as String?,
      idCollab: json['idCollab'] as String?,
      idCuisinier: json['idCuisinier'] as String?,
      statut: json['statut'] as String? ?? 'en_attente',
      dateCommande: json['dateCommande'] != null
          ? DateTime.parse(json['dateCommande'].toString())
          : DateTime.now(),
      dateLivraison: json['dateLivraison'] != null
          ? DateTime.tryParse(json['dateLivraison'].toString())
          : null,
      montantTotal: (json['montantTotal'] as num).toDouble(),
      adresseLivraison: json['adresseLivraison'] as String,
      notes: json['notes'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      tempsPreparationDebut: json['tempsPreparationDebut'] != null
          ? DateTime.tryParse(json['tempsPreparationDebut'].toString())
          : null,
      tempsPreparationFin: json['tempsPreparationFin'] != null
          ? DateTime.tryParse(json['tempsPreparationFin'].toString())
          : null,
      tempsRemiseLivreur: json['tempsRemiseLivreur'] != null
          ? DateTime.tryParse(json['tempsRemiseLivreur'].toString())
          : null,
      tempsRecuperationLivreur: json['tempsRecuperationLivreur'] != null
          ? DateTime.tryParse(json['tempsRecuperationLivreur'].toString())
          : null,
      tempsLivraison: json['tempsLivraison'] != null
          ? DateTime.tryParse(json['tempsLivraison'].toString())
          : null,
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
      'idCommande': idCommande,
      'idClient': idClient,
      'idPointVente': idPointVente,
      'idCollab': idCollab,
      'idCuisinier': idCuisinier,
      'statut': statut,
      'dateCommande': dateCommande.toIso8601String(),
      'dateLivraison': dateLivraison?.toIso8601String(),
      'montantTotal': montantTotal,
      'adresseLivraison': adresseLivraison,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'tempsPreparationDebut': tempsPreparationDebut?.toIso8601String(),
      'tempsPreparationFin': tempsPreparationFin?.toIso8601String(),
      'tempsRemiseLivreur': tempsRemiseLivreur?.toIso8601String(),
      'tempsRecuperationLivreur': tempsRecuperationLivreur?.toIso8601String(),
      'tempsLivraison': tempsLivraison?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
