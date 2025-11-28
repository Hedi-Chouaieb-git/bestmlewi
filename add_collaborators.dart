import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://qxajdhjecopmgvbtbkpu.supabase.co/',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4YWpkaGplY29wbWd2YnRia3B1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NzMxMTYsImV4cCI6MjA3OTU0OTExNn0.CB06Fr7jcQPAFctPG7chV9yeF6B2GQldgFyqcrdq7Bc',
  );

  // Sample collaborators to add
  final collaborators = [
    {
      'idCollab': 'COORD001',
      'nom': 'Ben Ali',
      'prenom': 'Ahmed',
      'email': 'ahmed.coordinator@example.com',
      'password': 'coord123',
      'role': 'coordinateur',
      'disponible': true,
      'telephone': '+21698765430',
    },
    {
      'idCollab': 'LIV001',
      'nom': 'Trabelsi',
      'prenom': 'Mohamed',
      'email': 'mohamed.livreur@example.com',
      'password': 'livreur123',
      'role': 'livreur',
      'disponible': true,
      'telephone': '+21698765431',
    },
    {
      'idCollab': 'CUIS001',
      'nom': 'Mejri',
      'prenom': 'Fatma',
      'email': 'fatma.cuisinier@example.com',
      'password': 'cuisinier123',
      'role': 'cuisinier',
      'disponible': true,
      'telephone': '+21698765432',
    },
    {
      'idCollab': 'GER001',
      'nom': 'Dupont',
      'prenom': 'Jean',
      'email': 'jean.gerant@example.com',
      'password': 'gerant123',
      'role': 'gerant',
      'disponible': true,
      'telephone': '+21698765433',
    },
  ];

  try {
    for (final collab in collaborators) {
      await supabase.from('Collaborateurs').insert(collab);
      print('Added collaborator: ${collab['prenom']} ${collab['nom']} (${collab['role']})');
    }
    print('All collaborators added successfully!');
  } catch (e) {
    print('Error adding collaborators: $e');
  }
}
