import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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
        position INTEGER NOT NULL,
        title TEXT,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS todos(
        id INTEGER PRIMARY KEY,
        position INTEGER NOT NULL,
        taskId INTEGER,
        title TEXT,
        completed INTEGER
      )''');
  }

  Future<void> deleteTask(int id) async {
    final Database db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    await db.delete('todos', where: 'taskId = ?', whereArgs: [id]);
    await fixTaskPositions();
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

  Future<void> moveTasks(int prevPos, int newPos) async {
    if (newPos > prevPos) newPos--;
    List<Task> tasks = await getTasks();
    prevPos = tasks[prevPos].position;
    newPos = tasks[newPos].position;
    List<int> indexArray = [];
    for (int i = 0; i < tasks.length; i++) {
      indexArray.add(tasks[i].position);
    }

    int prevIndex = indexArray.indexOf(prevPos);
    indexArray.removeAt(prevIndex);
    indexArray.insert(newPos, prevPos);

    for (int i = 0; i < indexArray.length; i++) {
      Task newTask = Task(
        position: tasks[i].position,
        title: tasks[indexArray[i]].title,
        description: tasks[indexArray[i]].description,
        id: tasks[indexArray[i]].id,
      );
      await updateTask(newTask);
    }
  }

  Future<void> fixTaskPositions() async {
    List<Task> tasks = await getTasks();
    for (int i = 0; i < tasks.length; i++) {
      Task fixedTask = Task(
        position: i,
        title: tasks[i].title,
        description: tasks[i].description,
        id: tasks[i].id,
      );
      await updateTask(fixedTask);
    }
  }

  Future<List<Task>> getTasks() async {
    Database _db = await instance.database;
    List<Map<String, dynamic>> _taskMap = await _db.query('tasks');
    List<Map<String, dynamic>> taskMap = _taskMap.toList();
    taskMap.sort((a, b) {
      return a['position'].compareTo(b['position']);
    });
    return List.generate(taskMap.length, (index) {
      return Task(
        id: taskMap[index]['id'],
        position: taskMap[index]['position'],
        title: taskMap[index]['title'],
        description: taskMap[index]['description'],
      );
    });
  }

  // todos

  Future<void> moveTodo(int taskId, int prevPos, int newPos) async {
    if (newPos > prevPos) newPos--;
    List<Todo> todos = await getTodos(taskId);
    prevPos = todos[prevPos].position!;
    newPos = todos[newPos].position!;
    List<int> indexArray = [];
    for (int i = 0; i < todos.length; i++) {
      indexArray.add(todos[i].position ?? i);
    }

    int prevIndex = indexArray.indexOf(prevPos);
    indexArray.removeAt(prevIndex);
    indexArray.insert(newPos, prevPos);

    for (int i = 0; i < indexArray.length; i++) {
      Todo newTodo = Todo(
        position: todos[i].position,
        title: todos[indexArray[i]].title,
        completed: todos[indexArray[i]].completed,
        taskId: todos[indexArray[i]].taskId,
        id: todos[indexArray[i]].id,
      );
      await updateTodo(newTodo);
    }
  }

  Future<void> fixTodoPositions(int taskId) async {
    List<Todo> todo = await getTodos(taskId);
    for (int i = 0; i < todo.length; i++) {
      Todo fixedTodo = Todo(
        position: i,
        title: todo[i].title,
        completed: todo[i].completed,
        taskId: todo[i].taskId,
        id: todo[i].id,
      );
      await updateTodo(fixedTodo);
    }
  }

  Future<List<Todo>> getTodos(int taskId) async {
    Database _db = await instance.database;
    final List<Map<String, dynamic>> _todoMap = await _db.query(
      'todos',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
    List<Map<String, dynamic>> todoMap = _todoMap.toList();
    todoMap.sort((a, b) {
      return a['position'].compareTo(b['position']);
    });
    List<Todo> todoList = List.generate(todoMap.length, (index) {
      return Todo(
        id: todoMap[index]['id'],
        taskId: todoMap[index]['taskId'],
        position: todoMap[index]['position'],
        title: todoMap[index]['title'],
        completed: todoMap[index]['completed'] == 1,
      );
    });

    return todoList;
  }

  Future<Todo> getTodo(int todoId) async {
    Database _db = await instance.database;
    final List<Map<String, dynamic>> todoMap = await _db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [todoId],
    );
    return Todo(
      id: todoMap[0]['id'],
      taskId: todoMap[0]['taskId'],
      position: todoMap[0]['position'],
      title: todoMap[0]['title'],
      completed: todoMap[0]['completed'] == 1,
    );
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
    Todo todoTobeDeleted = await getTodo(todoId);
    int deletedtodoId =
        await _db.delete('todos', where: 'id = ?', whereArgs: [todoId]);
    await this.fixTodoPositions(todoTobeDeleted.taskId!);
    return deletedtodoId;
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
