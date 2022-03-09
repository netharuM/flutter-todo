import 'package:flutter/material.dart';

class TitleInput extends StatelessWidget {
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;
  final TextEditingController? controller;
  const TitleInput(
      {Key? key, this.onChanged, this.onSubmitted, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: this.controller,
        onChanged: this.onChanged,
        onSubmitted: this.onSubmitted,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter Task Title",
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DescriptionInput extends StatelessWidget {
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  const DescriptionInput(
      {Key? key,
      this.padding,
      this.fontSize,
      this.onSubmitted,
      this.onChanged,
      this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: TextField(
          controller: this.controller,
          onChanged: this.onChanged,
          onSubmitted: this.onSubmitted,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter Task Description",
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(horizontal: 12)),
          style: TextStyle(
            fontSize: fontSize ?? 15,
          ),
        ),
      ),
    );
  }
}

class NewTodoInput extends StatelessWidget {
  final Function(String todoName)? onSubmitted;
  final TextEditingController? controller;
  const NewTodoInput({Key? key, this.controller, this.onSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 23,
            height: 23,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Color(0xFF4cc9f0),
                width: 2,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: this.controller,
              onSubmitted: this.onSubmitted,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter a new TODO",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
