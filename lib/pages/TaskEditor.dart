import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo/DBHandler.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/widgets/Buttons.dart';
import 'package:todo/widgets/Inputs.dart';
import 'package:todo/widgets/ProgressBar.dart';
import 'package:todo/widgets/Todo.dart';

class TaskEditingPage extends StatefulWidget {
  final Task? task;
  const TaskEditingPage({Key? key, this.task}) : super(key: key);

  @override
  State<TaskEditingPage> createState() => _TaskEditingPageState();
}

class _TaskEditingPageState extends State<TaskEditingPage> {
  bool _titleChanged = false;
  bool _notANewTask = true;
  int? _id;
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _descController = new TextEditingController();
  TextEditingController _newTodoController = new TextEditingController();
  DBHandler _dbHandler = DBHandler.instance;
  List<Todo> _todos = [];

  void _refresh() {
    _dbHandler.getTodos(this._id ?? 0).then((value) {
      setState(() {
        this._todos = value;
      });
    });
  }

  @override
  void initState() {
    this._notANewTask = widget.task != null;
    this._titleController.text = widget.task?.title ?? '';
    this._descController.text = widget.task?.description ?? '';
    this._id = widget.task?.id;
    _refresh();
    super.initState();
  }

  @override
  void dispose() {
    this._titleController.dispose();
    this._descController.dispose();
    this._newTodoController.dispose();
    super.dispose();
  }

  Future<void> _updateTask() async {
    Task newTask = new Task(
      id: this.widget.task?.id ?? null,
      position: this.widget.task?.position ?? 0,
      title: this._titleController.text.isNotEmpty
          ? this._titleController.text
          : null,
      description: this._descController.text.isNotEmpty
          ? this._descController.text
          : null,
    );
    this._id = await _dbHandler.updateTask(newTask);
    print(this._id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // page
            Column(
              children: [
                // task title and the back button
                Container(
                  child: Row(
                    children: [
                      GoBackButton(),
                      TitleInput(
                        controller: _titleController,
                        onChanged: (value) {
                          setState(() {
                            _titleChanged = value.isNotEmpty;
                          });
                        },
                        onSubmitted: (value) async {
                          await _updateTask();
                        },
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: _notANewTask,
                  child: FutureBuilder(
                    future:
                        _dbHandler.getCompletedTodoPrecentage(this._id ?? 0),
                    initialData: 0.0,
                    builder: (context, AsyncSnapshot snapshot) {
                      return ProgressBar(
                        value: snapshot.data,
                        progressColor: Color(0xFF4cc9f0),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: _notANewTask,
                  child: DescriptionInput(
                    controller: _descController,
                    onSubmitted: (value) async {
                      await _updateTask();
                    },
                  ),
                ),
                // todos
                Visibility(
                  visible: _notANewTask,
                  child: Expanded(
                    child: ScrollConfiguration(
                        behavior: NoGlowBehaviour(),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: ReorderableListView(
                            proxyDecorator: (
                              Widget child,
                              int index,
                              Animation<double> animation,
                            ) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    cardColor: Theme.of(context).splashColor,
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            onReorder: (int oldIndex, int newIndex) {
                              _dbHandler
                                  .moveTodo(_id!, oldIndex, newIndex)
                                  .then((value) {
                                _refresh();
                              });
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final Todo item = _todos.removeAt(oldIndex);
                                _todos.insert(newIndex, item);
                              });
                            },
                            children: <Widget>[
                              for (int i = 0; i < _todos.length; i++)
                                Slidable(
                                  startActionPane: ActionPane(
                                    extentRatio: 0.25,
                                    motion: ScrollMotion(),
                                    children: [
                                      Builder(builder: (BuildContext context) {
                                        return Expanded(
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onLongPress: () {},
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return createDeleteConfirmation(
                                                          context: context,
                                                          title:
                                                              "delete todo ${_todos[i].title}",
                                                          onDelete: () async {
                                                            await _dbHandler
                                                                .deleteTodo(
                                                                    _todos[i]
                                                                        .id!);
                                                            _refresh();
                                                          });
                                                    },
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Icon(
                                                  Icons.delete_forever_rounded,
                                                  color: Color(0xfff72785),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                  key: ValueKey(_todos[i].id),
                                  child: TodoWidget(
                                    todo: _todos[i],
                                    onTap: (state) async {
                                      Todo newTodo = new Todo(
                                        id: _todos[i].id,
                                        taskId: this._id,
                                        position: _todos[i].position,
                                        completed: state,
                                        title: _todos[i].title,
                                      );
                                      await _dbHandler.updateTodo(newTodo);
                                      _refresh();
                                    },
                                  ),
                                ),
                            ],
                          ),
                        )),
                  ),
                ),
                Visibility(
                    visible: _notANewTask,
                    child: NewTodoInput(
                      controller: _newTodoController,
                      onSubmitted: (value) async {
                        await _dbHandler.insertTodo(
                          new Todo(
                            title: value,
                            completed: false,
                            position: _todos.length,
                            taskId: this._id,
                          ),
                        );
                        _refresh();
                        _newTodoController.text = '';
                      },
                    )),
              ],
            ),
            // add button
            Positioned(
              right: 16,
              bottom: 30,
              child: this._notANewTask
                  ? DeleteButton(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return createDeleteConfirmation(
                              context: context,
                              title: "delete Task '${this.widget.task?.title}'",
                              onDelete: () {
                                _dbHandler.deleteTask(this._id!);
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    )
                  : Visibility(
                      visible: _titleChanged,
                      child: SaveButton(
                        onTap: () async {
                          List<Task> tasks = await _dbHandler.getTasks();
                          Task newTask = new Task(
                              title: _titleController.text,
                              position: tasks.length);
                          int taskID = await _dbHandler.insertTask(newTask);
                          newTask = Task(
                            position: newTask.position,
                            id: taskID,
                            title: newTask.title,
                          );
                          Navigator.pop(context, newTask);
                        },
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class NoGlowBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

AlertDialog createDeleteConfirmation({
  required BuildContext context,
  Color? deleteColor,
  Color? cancelColor,
  Function()? onCancel,
  Function()? onDelete,
  String? title,
}) {
  return AlertDialog(
    title: Text(title ?? 'Do you wanna delete it'),
    backgroundColor: Color(0xFF1c2541),
    actions: [
      TextButton(
        child: Text('Cancel'),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
              cancelColor ?? Color(0xFF4cc9f0)),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered))
                return (cancelColor ?? Color(0xFF4cc9f0)).withOpacity(0.04);
              if (states.contains(MaterialState.focused) ||
                  states.contains(MaterialState.pressed))
                return (cancelColor ?? Color(0xFF4cc9f0)).withOpacity(0.12);
              return null; // Defer to the widget's default.
            },
          ),
        ),
        onPressed: () {
          if (onCancel != null) onCancel();
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: Text('Delete'),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
              deleteColor ?? Color(0xFFf72785)),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered))
                return deleteColor ?? Color(0xFFf72785).withOpacity(0.04);
              if (states.contains(MaterialState.focused) ||
                  states.contains(MaterialState.pressed))
                return (deleteColor ?? Color(0xFFf72785)).withOpacity(0.12);
              return null; // Defer to the widget's default.
            },
          ),
        ),
        onPressed: () {
          if (onDelete != null) onDelete();
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
