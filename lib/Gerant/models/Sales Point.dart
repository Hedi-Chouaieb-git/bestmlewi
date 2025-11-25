class SalesPoint {
  final String id;
  final String title;
  final String status;
  final String collaborators; // could be List<Employee> for real use

  SalesPoint({
    required this.id,
    required this.title,
    required this.status,
    required this.collaborators,
  });
}
