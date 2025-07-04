import 'package:flutter/material.dart';
import 'package:help_connect/components/app_colors.dart';

class MyFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;

  const MyFloatingActionButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<MyFloatingActionButton> createState() => _MyFloatingActionButtonState();
}

class _MyFloatingActionButtonState extends State<MyFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: FloatingActionButton(
            backgroundColor: AppColors.sunrise,
            tooltip: "Mở Chatbot",
            child: Icon(Icons.chat),
            onPressed: widget.onPressed,
          ),
        );
      },
    );
  }
}
