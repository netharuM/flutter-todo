class Todo {
  final int? id;
  final int? taskId;
  final String? title;
  final bool? completed;
  final int? position;
  Todo({this.id, this.taskId, this.position, this.title, this.completed});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position': position,
      'taskId': taskId,
      'title': title,
      'completed': completed,
    };
  }
}
