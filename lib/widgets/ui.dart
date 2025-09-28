import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color? background;
  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.background,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class PillLabel extends StatelessWidget {
  final String text;
  const PillLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x2E138808),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x59138808)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFC0FFD0)),
      ),
    );
  }
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down(_) => _c.forward();
  void _up([_]) => _c.reverse();

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 1, end: .97).animate(CurvedAnimation(
      parent: _c,
      curve: Curves.easeOut,
    ));

    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _up,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: scale,
        builder: (_, child) => Transform.scale(scale: scale.value, child: child),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.background ?? Theme.of(context).colorScheme.primary,
            borderRadius: widget.borderRadius,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF04140A)),
            child: IconTheme.merge(
              data: const IconThemeData(color: Color(0xFF04140A)),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerBox extends StatefulWidget {
  final double height;
  final BorderRadius borderRadius;
  const ShimmerBox({super.key, this.height = 18, this.borderRadius = const BorderRadius.all(Radius.circular(12))});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).cardColor;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              colors: [
                base.withOpacity(.25),
                base.withOpacity(.15),
                base.withOpacity(.25),
              ],
              stops: [0, (_c.value * .6) + .2, 1],
            ),
          ),
        );
      },
    );
  }
}

class FloatCard extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  const FloatCard({super.key, required this.child, this.amplitude = 6, this.duration = const Duration(seconds: 5)});

  @override
  State<FloatCard> createState() => _FloatCardState();
}

class _FloatCardState extends State<FloatCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final dy = math.sin(_c.value * 2 * math.pi) * widget.amplitude;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}
