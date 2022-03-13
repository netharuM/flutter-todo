class Task {
  final int? id;
  final String? title;
  final String? description;
  final int position;

  Task({this.id, required this.position, this.title, this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position': position,
      'title': title,
      'description': description,
    };
  }
}
