import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  final double value;
  final bool enableCompleteIcon;
  final Color? backgroundColor;
  final Color? progressColor;
  final EdgeInsetsGeometry? barPadding;
  const ProgressBar(
      {Key? key,
      this.backgroundColor,
      this.progressColor,
      this.enableCompleteIcon = false,
      this.barPadding,
      required this.value})
      : super(key: key);

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 650),
    );
    _animController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animation = Tween<double>(begin: 0, end: this.widget.value / 100).animate(
        new CurvedAnimation(parent: _animController, curve: Curves.decelerate));
    _animController.forward();
    return this.widget.enableCompleteIcon
        ? Row(
            children: [
              Padding(
                padding: this.widget.barPadding ??
                    const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                    width: 310,
                    child: _LinearProgressBar(
                      backgroundColor: this.widget.backgroundColor,
                      progressColor: this.widget.progressColor,
                      value: _animation.value,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(Icons.check_circle,
                    color: this.widget.value == 100
                        ? Color(0xFF4260ee)
                        : Color(0xFF00142b)),
              ),
            ],
          )
        : Padding(
            padding: this.widget.barPadding ??
                const EdgeInsets.symmetric(vertical: 12),
            child: _LinearProgressBar(
              backgroundColor: this.widget.backgroundColor,
              progressColor: this.widget.progressColor,
              value: _animation.value,
            ),
          );
  }
}

class _LinearProgressBar extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? progressColor;
  const _LinearProgressBar(
      {this.backgroundColor, this.progressColor, this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        this.progressColor ?? Color(0xFF4260ee),
      ),
      backgroundColor: this.backgroundColor ?? Color(0xFF00142b),
      value: this.value,
    );
  }
}
