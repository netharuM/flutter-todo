import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo/DBHandler.dart';
import 'package:todo/models/task.dart';
import 'package:todo/pages/TaskEditor.dart';
import 'package:todo/widgets/Buttons.dart';
import 'package:todo/widgets/TaskCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DBHandler _dbHandler = DBHandler.instance;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _dbHandler.getTasks().then((tasks) {
      setState(() {
        _tasks = tasks;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // page
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 32, bottom: 16, left: 12),
                    width: 50,
                    child: Image(
                      image: AssetImage('assets/images/icon.png'),
                    ),
                  ),
                  Expanded(
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
                                borderRadius: BorderRadius.circular(12),
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
                                  cardColor: Color(0xff4260ee).withOpacity(0.5),
                                ),
                                child: child,
                              ),
                            );
                          },
                          onReorder: (int oldIndex, int newIndex) {
                            _dbHandler
                                .moveTasks(oldIndex, newIndex)
                                .then((tasks) {
                              _refresh();
                            });
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              final Task item = _tasks.removeAt(oldIndex);
                              _tasks.insert(newIndex, item);
                            });
                          },
                          children: <Widget>[
                            for (int i = 0; i < _tasks.length; i++)
                              Slidable(
                                key: ValueKey(_tasks[i].id),
                                endActionPane: ActionPane(
                                  extentRatio: 0.40,
                                  motion: ScrollMotion(),
                                  children: [
                                    Builder(builder: (BuildContext context) {
                                      return Expanded(
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 5),
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
                                                          "delete Task '${_tasks[i].title}'",
                                                      onDelete: () async {
                                                        await _dbHandler
                                                            .deleteTask(
                                                                _tasks[i].id!);
                                                        _refresh();
                                                      },
                                                    );
                                                  },
                                                ).then((value) {
                                                  Slidable.of(context)!.close();
                                                });
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Icon(
                                                Icons.delete_forever_rounded,
                                                color: Color(0xfff72785),
                                                size: 45,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                                  ],
                                ),
                                child: TaskCard(
                                  task: _tasks[i],
                                  onTap: (Task task) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TaskEditingPage(
                                          task: task,
                                        ),
                                      ),
                                    ).then((value) {
                                      _refresh();
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // add button
            Positioned(
              right: 16,
              bottom: 30,
              child: AddButton(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskEditingPage(),
                      )).then(
                    (value) {
                      _refresh();
                      // redirecting to edit description and those things
                      if (value != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskEditingPage(
                              task: value,
                            ),
                          ),
                        ).then((value) {
                          _refresh();
                        });
                      }
                    },
                  );
                },
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
