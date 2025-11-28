enum AlertSeverity { info, warning, error }

class Alert {
  final int id;
  final String message;
  final AlertSeverity severity;
  final DateTime? createdAt;
  final bool resolved;

  Alert({
    required this.id,
    required this.message,
    required this.severity,
    this.createdAt,
    this.resolved = false,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    AlertSeverity severity;
    switch (json['severity']?.toString().toLowerCase()) {
      case 'warning':
        severity = AlertSeverity.warning;
        break;
      case 'error':
        severity = AlertSeverity.error;
        break;
      case 'info':
      default:
        severity = AlertSeverity.info;
        break;
    }

    return Alert(
      id: json['id'] as int,
      message: json['message'] as String,
      severity: severity,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      resolved: json['resolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    String severityString;
    switch (severity) {
      case AlertSeverity.warning:
        severityString = 'warning';
        break;
      case AlertSeverity.error:
        severityString = 'error';
        break;
      case AlertSeverity.info:
      default:
        severityString = 'info';
        break;
    }

    return {
      'id': id,
      'message': message,
      'severity': severityString,
      'created_at': createdAt?.toIso8601String(),
      'resolved': resolved,
    };
  }
}
