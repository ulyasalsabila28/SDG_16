import 'package:flutter/material.dart';

bool isWide(BuildContext c) => MediaQuery.sizeOf(c).width >= 900;

class Narrow extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const Narrow({super.key, required this.child, this.maxWidth = 440});
  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}

class FadeIn extends StatelessWidget {
  final Widget child;
  final int index;
  const FadeIn({super.key, required this.child, this.index = 0});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 450 + index * 110),
        curve: Curves.easeOutCubic,
        builder: (c, v, ch) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: ch)),
        child: child,
      );
}

class HoverLift extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const HoverLift({super.key, required this.child, this.onTap});
  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(scale: hover ? 1.04 : 1, duration: const Duration(milliseconds: 150), child: widget.child),
        ),
      );
}

class CountUp extends StatelessWidget {
  final num value;
  final TextStyle style;
  final String Function(double)? format;
  const CountUp(this.value, {super.key, required this.style, this.format});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOut,
        builder: (c, v, _) => Text(format != null ? format!(v) : v.round().toString(), style: style),
      );
}

class RGrid extends StatelessWidget {
  final List<Widget> children;
  final int wideCols, cols;
  final double gap;
  const RGrid({super.key, required this.children, this.wideCols = 4, this.cols = 2, this.gap = 12});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (c, box) {
        final n = box.maxWidth >= 640 ? wideCols : cols;
        final w = (box.maxWidth - gap * (n - 1)) / n;
        return Wrap(spacing: gap, runSpacing: gap, children: [for (final ch in children) SizedBox(width: w, child: ch)]);
      });
}
