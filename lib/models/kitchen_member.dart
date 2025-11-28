class KitchenMember {
  final String id;
  final String name;
  final String? currentOrder;
  final String status; // available, busy, offline
  final String? specialite;
  final int? experience; // Years of experience

  KitchenMember({
    required this.id,
    required this.name,
    this.currentOrder,
    required this.status,
    this.specialite,
    this.experience,
  });

  bool get isAvailable => status.toLowerCase() == 'available';

  factory KitchenMember.fromJson(Map<String, dynamic> json) {
    return KitchenMember(
      id: json['id'] as String? ?? json['idMembre'] as String,
      name: json['name'] as String,
      currentOrder: json['currentOrder'] as String?,
      status: json['status'] as String? ?? 'available',
      specialite: json['specialite'] as String?,
      experience: json['experience'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentOrder': currentOrder,
      'status': status,
      'specialite': specialite,
      'experience': experience,
    };
  }
}

