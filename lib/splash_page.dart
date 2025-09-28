import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  final String imagePath;
  final VoidCallback onFinished;
  final Duration duration;
  const SplashPage({
    super.key,
    required this.imagePath,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  double _opacity = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Fade in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _opacity = 1);
    });
    // Finish after duration
    _timer = Timer(widget.duration, () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F0F),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: Image.asset(
            widget.imagePath,
            width: 220,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
