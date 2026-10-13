class Student {
  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.major,
    this.isSelected = false,
  });
  final String id;
  final String name;
  final String email;
  final String major;
  bool isSelected;
}
