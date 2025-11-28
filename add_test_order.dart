import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://qxajdhjecopmgvbtbkpu.supabase.co/',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4YWpkaGplY29wbWd2YnRia3B1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NzMxMTYsImV4cCI6MjA3OTU0OTExNn0.CB06Fr7jcQPAFctPG7chV9yeF6B2GQldgFyqcrdq7Bc',
  );

  // Add a test order
  final testOrder = {
    'idCommande': 'TEST001',
    'idClient': 'CLI001',
    'statut': 'en_attente',
    'dateCommande': DateTime.now().toIso8601String(),
    'montantTotal': 45.50,
    'adresseLivraison': '123 Rue Habib Bourguiba, Tunis',
    'notes': 'Test order for coordinator and livreur testing',
  };

  try {
    await supabase.from('Commande').insert(testOrder);
    print('Test order added successfully: ${testOrder['idCommande']}');
  } catch (e) {
    print('Error adding test order: $e');
  }
}
