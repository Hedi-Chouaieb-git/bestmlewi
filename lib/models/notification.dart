enum NotificationType {
  nouvelleCommande,
  commandeAssignee,
  statutModifie,
  urgence,
}

class NotificationModel {
  final String idNotification;
  final String idDestinataire;
  final String? idCommande;
  final NotificationType type;
  final String titre;
  final String message;
  final bool lue;
  final DateTime? createdAt;

  NotificationModel({
    required this.idNotification,
    required this.idDestinataire,
    this.idCommande,
    required this.type,
    required this.titre,
    required this.message,
    this.lue = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType type;
    switch (json['type']?.toString().toLowerCase()) {
      case 'nouvelle_commande':
        type = NotificationType.nouvelleCommande;
        break;
      case 'commande_assignee':
        type = NotificationType.commandeAssignee;
        break;
      case 'statut_modifie':
        type = NotificationType.statutModifie;
        break;
      case 'urgence':
        type = NotificationType.urgence;
        break;
      default:
        type = NotificationType.nouvelleCommande;
        break;
    }

    return NotificationModel(
      idNotification: json['idNotification'] as String,
      idDestinataire: json['idDestinataire'] as String,
      idCommande: json['idCommande'] as String?,
      type: type,
      titre: json['titre'] as String,
      message: json['message'] as String,
      lue: json['lue'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case NotificationType.nouvelleCommande:
        typeString = 'nouvelle_commande';
        break;
      case NotificationType.commandeAssignee:
        typeString = 'commande_assignee';
        break;
      case NotificationType.statutModifie:
        typeString = 'statut_modifie';
        break;
      case NotificationType.urgence:
        typeString = 'urgence';
        break;
    }

    return {
      'idNotification': idNotification,
      'idDestinataire': idDestinataire,
      'idCommande': idCommande,
      'type': typeString,
      'titre': titre,
      'message': message,
      'lue': lue,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
