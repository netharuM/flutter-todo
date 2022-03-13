import 'package:flutter/material.dart';
import 'package:todo/models/todo.dart';

class TodoWidget extends StatelessWidget {
  final String? text;
  final bool? completed;
  final Function()? onLongPress;
  final Function(bool state)? onTap;
  final Todo? todo;
  const TodoWidget(
      {Key? key,
      this.onLongPress,
      this.onTap,
      this.todo,
      this.text,
      this.completed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onTap != null)
              onTap!(!(this.completed ?? this.todo?.completed ?? false));
          },
          onLongPress: this.onLongPress,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 23,
                  height: 23,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: (this.completed ?? this.todo?.completed ?? false)
                        ? Color(0xFF4cc9f0)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: (this.completed ?? this.todo?.completed ?? false)
                        ? null
                        : Border.all(
                            color: Color(0xFF4cc9f0),
                            width: 2,
                          ),
                  ),
                  child: (this.completed ?? this.todo?.completed ?? false)
                      ? Icon(Icons.check_rounded)
                      : null,
                ),
                Flexible(
                  child: Text(
                    this.text ?? this.todo?.title ?? 'Unnamed Todo',
                    style: TextStyle(
                      decoration:
                          (this.completed ?? this.todo?.completed ?? false)
                              ? TextDecoration.lineThrough
                              : null,
                      fontStyle:
                          (this.completed ?? this.todo?.completed ?? false)
                              ? FontStyle.italic
                              : null,
                      fontWeight:
                          (this.completed ?? this.todo?.completed ?? false)
                              ? FontWeight.bold
                              : null,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
