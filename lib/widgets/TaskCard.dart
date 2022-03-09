import 'package:flutter/material.dart';
import 'package:todo/DBHandler.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/ProgressBar.dart';

// ignore: must_be_immutable
class TaskCard extends StatelessWidget {
  final Function(Task task)? onTap;
  final Task task;

  TaskCard({Key? key, this.onTap, required this.task}) : super(key: key);

  DBHandler _dbHandler = DBHandler.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1c2541),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (onTap != null) {
                this.onTap!(task);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder(
                  initialData: 0.0,
                  future: _dbHandler.getCompletedTodoPrecentage(task.id ?? 0),
                  builder: (context, AsyncSnapshot snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          task.title ?? 'unnamed Task',
                          style: TextStyle(
                            decoration: snapshot.data == 100
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          task.description ?? 'unknown description',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        ProgressBar(
                          value: snapshot.data,
                          enableCompleteIcon: true,
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ),
      ),
      margin: EdgeInsets.all(5),
    );
  }
}
