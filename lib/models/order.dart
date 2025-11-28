import 'cart_item.dart';

class Order {
  final String idCommande;
  final String idClient;
  final String? idCollab; // Assigned livreur
  final String statut; // en_attente, en_preparation, en_cours, livree, annulee
  final DateTime dateCommande;
  final DateTime? dateLivraison;
  final double montantTotal;
  final String adresseLivraison;
  final String? notes;
  final List<CartItem>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.idCommande,
    required this.idClient,
    this.idCollab,
    required this.statut,
    required this.dateCommande,
    this.dateLivraison,
    required this.montantTotal,
    required this.adresseLivraison,
    this.notes,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      idCommande: json['idCommande'] as String,
      idClient: json['idClient'] as String,
      idCollab: json['idCollab'] as String?,
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
      'idCollab': idCollab,
      'statut': statut,
      'dateCommande': dateCommande.toIso8601String(),
      'dateLivraison': dateLivraison?.toIso8601String(),
      'montantTotal': montantTotal,
      'adresseLivraison': adresseLivraison,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

