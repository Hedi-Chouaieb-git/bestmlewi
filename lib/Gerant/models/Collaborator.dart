class Collaborator {
  final String id;
  final String name;
  final String role;
  final String image; // or details as needed
  final String? salesPointId; // Current sales point assignment

  Collaborator({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
    this.salesPointId,
  });
}
