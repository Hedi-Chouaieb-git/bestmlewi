import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/alert.dart';

class DashboardSnapshot {
  DashboardSnapshot({
    required this.ordersToday,
    required this.deliveriesToday,
    required this.activeSalesPoints,
    required this.revenueToday,
    required this.alerts,
    required this.databaseReachable,
    required this.fetchedAt,
    this.databaseMessage,
  });

  final int ordersToday;
  final int deliveriesToday;
  final int activeSalesPoints;
  final double revenueToday;
  final List<DashboardAlert> alerts;
  final bool databaseReachable;
  final DateTime fetchedAt;
  final String? databaseMessage;

  factory DashboardSnapshot.failure(String reason) {
    return DashboardSnapshot(
      ordersToday: 0,
      deliveriesToday: 0,
      activeSalesPoints: 0,
      revenueToday: 0,
      alerts: [
        DashboardAlert(
          message: reason,
          severity: DashboardAlertSeverity.error,
          createdAt: DateTime.now(),
        ),
      ],
      databaseReachable: false,
      fetchedAt: DateTime.now(),
      databaseMessage: reason,
    );
  }

  DashboardSnapshot copyWith({
    int? ordersToday,
    int? deliveriesToday,
    int? activeSalesPoints,
    double? revenueToday,
    List<DashboardAlert>? alerts,
    bool? databaseReachable,
    DateTime? fetchedAt,
    String? databaseMessage,
  }) {
    return DashboardSnapshot(
      ordersToday: ordersToday ?? this.ordersToday,
      deliveriesToday: deliveriesToday ?? this.deliveriesToday,
      activeSalesPoints: activeSalesPoints ?? this.activeSalesPoints,
      revenueToday: revenueToday ?? this.revenueToday,
      alerts: alerts ?? this.alerts,
      databaseReachable: databaseReachable ?? this.databaseReachable,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      databaseMessage: databaseMessage ?? this.databaseMessage,
    );
  }
}

enum DashboardAlertSeverity {
  info,
  warning,
  error,
}

class DashboardAlert {
  DashboardAlert({
    required this.message,
    this.severity = DashboardAlertSeverity.info,
    this.createdAt,
  });

  final String message;
  final DashboardAlertSeverity severity;
  final DateTime? createdAt;

  factory DashboardAlert.fromJson(Map<String, dynamic> row) {
    final severityValue = (row['severity'] as String?)?.toLowerCase();
    DashboardAlertSeverity severity = DashboardAlertSeverity.info;
    switch (severityValue) {
      case 'warning':
        severity = DashboardAlertSeverity.warning;
        break;
      case 'error':
        severity = DashboardAlertSeverity.error;
        break;
      case 'info':
      default:
        severity = DashboardAlertSeverity.info;
    }
    DateTime? createdAt;
    final rawDate = row['created_at'];
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate);
    }
    return DashboardAlert(
      message: row['message'] as String? ?? 'Alerte inconnue',
      severity: severity,
      createdAt: createdAt,
    );
  }
}

class DashboardService {
  DashboardService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<DashboardSnapshot> fetchSnapshot() async {
    try {
      final now = DateTime.now().toUtc();
      final startOfDay = DateTime.utc(now.year, now.month, now.day);

      // Use Commande table instead of orders
      final orderRows = await _client
          .from('Commande')
          .select('statut, montantTotal, dateCommande')
          .gte('dateCommande', startOfDay.toIso8601String());

      // Try both table names for sales points
      List<Map<String, dynamic>> openSalesPoints = [];
      try {
        final salesPointsRows = await _client
            .from('PointDeVente')
            .select('idPoint')
            .eq('ouvert', true);
        openSalesPoints = List<Map<String, dynamic>>.from(salesPointsRows);
      } catch (e) {
        try {
          final salesPointsRows = await _client
              .from('sales_points')
              .select('id')
              .eq('is_open', true);
          openSalesPoints = List<Map<String, dynamic>>.from(salesPointsRows);
        } catch (e2) {
          // Table doesn't exist, use empty list
        }
      }

      final alertRows = await _client
          .from('alerts')
          .select('message,severity,created_at')
          .order('created_at', ascending: false)
          .limit(5);

      final orders = List<Map<String, dynamic>>.from(orderRows);
      final alerts = List<Map<String, dynamic>>.from(alertRows)
          .map(DashboardAlert.fromJson)
          .toList();

      final deliveries = orders.where((order) {
        final status = (order['statut'] as String?)?.toLowerCase();
        return status == 'delivered' || status == 'livree';
      }).length;

      final revenue = orders.fold<double>(0, (acc, order) {
        final amount = order['montantTotal'];
        if (amount is num) {
          return acc + amount.toDouble();
        }
        return acc;
      });

      return DashboardSnapshot(
        ordersToday: orders.length,
        deliveriesToday: deliveries,
        activeSalesPoints: openSalesPoints.length,
        revenueToday: double.parse(revenue.toStringAsFixed(2)),
        alerts: alerts,
        databaseReachable: true,
        fetchedAt: DateTime.now(),
        databaseMessage: null,
      );
    } on PostgrestException catch (error) {
      return DashboardSnapshot.failure(error.message);
    } catch (error) {
      return DashboardSnapshot.failure(error.toString());
    }
  }
}
