class Task {
  String title;
  bool isDone;

  // Constructor sử dụng named parameters với giá trị mặc định là false
  Task({required this.title, this.isDone = false});
}
