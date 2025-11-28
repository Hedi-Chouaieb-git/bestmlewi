class LocationUpdate {
  final String idLocation;
  final String idCollab;
  final double latitude;
  final double longitude;
  final DateTime? timestamp;
  final double? vitesse;
  final double? precision;

  LocationUpdate({
    required this.idLocation,
    required this.idCollab,
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.vitesse,
    this.precision,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      idLocation: json['idLocation'] as String,
      idCollab: json['idCollab'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
      vitesse: json['vitesse'] != null ? (json['vitesse'] as num).toDouble() : null,
      precision: json['precision'] != null ? (json['precision'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idLocation': idLocation,
      'idCollab': idCollab,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp?.toIso8601String(),
      'vitesse': vitesse,
      'precision': precision,
    };
  }
}
