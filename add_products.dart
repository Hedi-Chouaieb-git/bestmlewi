import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://qxajdhjecopmgvbtbkpu.supabase.co/',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4YWpkaGplY29wbWd2YnRia3B1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NzMxMTYsImV4cCI6MjA3OTU0OTExNn0.CB06Fr7jcQPAFctPG7chV9yeF6B2GQldgFyqcrdq7Bc',
  );

  // Sample products to add
  final products = [
    {
      'idProduit': 'PROD003',
      'nom': 'Couscous Tunisien',
      'description': 'Délicieux couscous tunisien traditionnel avec légumes et viande',
      'prix': 15.00,
      'categorie': 'Plat Principal',
      'image': 'assets/images/mlawi.jpeg',
      'disponible': true,
    },
    {
      'idProduit': 'PROD004',
      'nom': 'Salade Mechouia',
      'description': 'Salade tunisienne grillée avec tomates, poivrons et épices',
      'prix': 8.50,
      'categorie': 'Entrée',
      'image': 'assets/images/logo.png',
      'disponible': true,
    },
    {
      'idProduit': 'PROD005',
      'nom': 'Baklava',
      'description': 'Pâtisserie orientale aux amandes et au miel',
      'prix': 6.00,
      'categorie': 'Dessert',
      'image': 'assets/images/group55.png',
      'disponible': true,
    },
    {
      'idProduit': 'PROD006',
      'nom': 'Thé à la Menthe',
      'description': 'Thé traditionnel tunisien à la menthe fraîche',
      'prix': 3.00,
      'categorie': 'Boisson',
      'image': 'assets/images/jus.jpeg',
      'disponible': true,
    },
    {
      'idProduit': 'PROD007',
      'nom': 'Ojja Merguez',
      'description': 'Plat tunisien avec merguez et œufs dans une sauce épicée',
      'prix': 12.00,
      'categorie': 'Plat Principal',
      'image': 'assets/images/mlawi.jpeg',
      'disponible': true,
    },
    {
      'idProduit': 'PROD008',
      'nom': 'Assiette de Fromage',
      'description': 'Assortiment de fromages tunisiens locaux',
      'prix': 10.00,
      'categorie': 'Entrée',
      'image': 'assets/images/logo.png',
      'disponible': true,
    },
    {
      'idProduit': 'PROD009',
      'nom': 'Café Noir',
      'description': 'Café tunisien traditionnel serré',
      'prix': 2.50,
      'categorie': 'Boisson',
      'image': 'assets/images/jus.jpeg',
      'disponible': true,
    },
    {
      'idProduit': 'PROD010',
      'nom': 'Brik au Thon',
      'description': 'Feuille de brick farcie au thon, œuf et fromage',
      'prix': 7.00,
      'categorie': 'Entrée',
      'image': 'assets/images/shwarma.jpeg',
      'disponible': true,
    },
  ];

  try {
    for (final product in products) {
      await supabase.from('Produit').insert(product);
      print('Added product: ${product['nom']}');
    }
    print('All products added successfully!');
  } catch (e) {
    print('Error adding products: $e');
  }
}
