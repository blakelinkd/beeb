import 'package:flutter/material.dart';

class TypingBubbles extends StatefulWidget {
  const TypingBubbles({Key? key}) : super(key: key);

  @override
  State<TypingBubbles> createState() => _TypingBubblesState();
}

class _TypingBubblesState extends State<TypingBubbles> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.3).animate(controller);
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < _controllers.length; i++) {
      await _controllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _controllers[i].reverse();
      if (i < _controllers.length - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    if (mounted) {
      _startAnimation(); // Restart the cycle
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.amber[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 3; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                shape: BoxShape.circle,
              ),
              child: FadeTransition(
                opacity: _animations[i],
                child: Container(
                  color: Colors.grey[700],
                ),
              ),
            ),
        ],
      ),
    );
  }
}