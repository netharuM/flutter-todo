import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/todo.dart';

class DBHandler {
  DBHandler._init();
  static final DBHandler instance = DBHandler._init();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDataBase();

  Future<Database> _initDataBase() async {
    String path = join(await getDatabasesPath(), "database.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks(
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS todos(
        id INTEGER PRIMARY KEY,
        taskId INTEGER,
        title TEXT,
        completed INTEGER,
        name TEXT
      )''');
  }

  Future<void> deleteTask(int id) async {
    final Database db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    await db.delete('todos', where: 'taskId = ?', whereArgs: [id]);
  }

  Future<int> updateTask(Task task) async {
    Database _db = await instance.database;
    return await _db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<List<Todo>> getCompletedTodos(int taskId) async {
    Database _db = await instance.database;
    List<Map<String, dynamic>> todoMap = await _db.query('todos',
        where: 'taskId = ? AND completed = ?', whereArgs: [taskId, 1]);
    return List.generate(todoMap.length, (index) {
      return Todo(
        id: todoMap[index]['id'],
        taskId: todoMap[index]['taskId'],
        title: todoMap[index]['title'],
        completed: todoMap[index]['completed'] == 1,
      );
    });
  }

  Future<double> getCompletedTodoPrecentage(int taskId) async {
    List<Todo> completedTodods = await this.getCompletedTodos(taskId);
    int todoCount = await this.getCountOfTodos(taskId);
    if (completedTodods.length == 0 && todoCount == 0) {
      return 0;
    }
    return (completedTodods.length / todoCount) * 100;
  }

  Future<int> getCountOfTodos(int taskId) async {
    Database _db = await instance.database;
    return Sqflite.firstIntValue(await _db.rawQuery(
            'SELECT COUNT(*) FROM todos WHERE taskId = ?', [taskId])) ??
        0;
  }

  Future<int> insertTask(Task task) async {
    Database _db = await instance.database;
    int taskId = await _db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return taskId;
  }

  Future<List<Task>> getTasks() async {
    Database _db = await instance.database;
    final List<Map<String, dynamic>> taskMap = await _db.query('tasks');
    return List.generate(taskMap.length, (index) {
      return Task(
        id: taskMap[index]['id'],
        title: taskMap[index]['title'],
        description: taskMap[index]['description'],
      );
    });
  }

  Future<List<Todo>> getTodos(int taskId) async {
    Database _db = await instance.database;
    final List<Map<String, dynamic>> todoMap = await _db.query(
      'todos',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
    return List.generate(todoMap.length, (index) {
      return Todo(
        id: todoMap[index]['id'],
        taskId: todoMap[index]['taskId'],
        title: todoMap[index]['title'],
        completed: todoMap[index]['completed'] == 1,
      );
    });
  }

  Future<int> insertTodo(Todo todo) async {
    Database _db = await instance.database;
    Map<String, dynamic> todoMap = todo.toMap();
    todoMap['completed'] = (todoMap['completed'] ?? false) ? 1 : 0;
    int todoId = await _db.insert(
      'todos',
      todoMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return todoId;
  }

  Future<int> deleteTodo(int todoId) async {
    Database _db = await instance.database;
    return await _db.delete('todos', where: 'id = ?', whereArgs: [todoId]);
  }

  Future<int> updateTodo(Todo todo) async {
    Database _db = await instance.database;
    Map<String, dynamic> todoMap = todo.toMap();
    todoMap['completed'] = (todoMap['completed'] ?? false) ? 1 : 0;
    return await _db.update(
      'todos',
      todoMap,
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }
}
