class Todo {
  final int? id;
  final int? taskId;
  final String? title;
  final bool? completed;
  Todo({this.id, this.taskId, this.title, this.completed});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'completed': completed,
    };
  }
}
