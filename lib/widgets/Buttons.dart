import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final Function()? onTap;
  const DeleteButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xFFf72585),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: this.onTap ?? () {},
            child: Icon(
              Icons.delete_forever_rounded,
              size: 35,
              color: Colors.white,
            )),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final Function()? onTap;
  const SaveButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xFF4cc9f0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: this.onTap ?? () {},
            child: Icon(
              Icons.save_alt_rounded,
              size: 35,
            )),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final Function()? onTap;
  const AddButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xFF4361ee),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: this.onTap ?? () {},
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          ),
        ),
      ),
    );
  }
}

class GoBackButton extends StatelessWidget {
  final Function()? onTap;
  const GoBackButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onTap ??
          () {
            Navigator.pop(context);
          },
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
    );
  }
}
