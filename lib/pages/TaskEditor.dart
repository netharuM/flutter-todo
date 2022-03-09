import 'package:flutter/material.dart';
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

  @override
  void initState() {
    this._notANewTask = widget.task != null;
    this._titleController.text = widget.task?.title ?? '';
    this._descController.text = widget.task?.description ?? '';
    this._id = widget.task?.id;
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
                      child: FutureBuilder(
                        initialData: [],
                        future: _dbHandler.getTodos(this._id ?? 0),
                        builder: (context, AsyncSnapshot snapshot) {
                          return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return TodoWidget(
                                  todo: snapshot.data[index],
                                  onTap: (state) {
                                    Todo newTodo = new Todo(
                                      id: snapshot.data[index].id,
                                      taskId: this._id,
                                      completed: state,
                                      title: snapshot.data[index].title,
                                    );
                                    _dbHandler.updateTodo(newTodo);
                                    setState(() {});
                                  },
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return createDeleteConfirmation(
                                          context: context,
                                          title:
                                              "delete todo '${snapshot.data[index].title}'",
                                          onDelete: () {
                                            _dbHandler.deleteTodo(
                                                snapshot.data[index].id);
                                            setState(() {});
                                            // Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              });
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: _notANewTask,
                    child: NewTodoInput(
                      controller: _newTodoController,
                      onSubmitted: (value) async {
                        _dbHandler.insertTodo(new Todo(
                            title: value, completed: false, taskId: this._id));
                        setState(() {});
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
                          Task newTask = new Task(title: _titleController.text);
                          int taskID = await _dbHandler.insertTask(newTask);
                          newTask = Task(
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
