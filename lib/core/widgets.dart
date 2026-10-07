import 'package:flutter/material.dart';
import 'theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  const AppHeader(this.title, {super.key, this.actions = const []});
  @override
  Size get preferredSize => const Size.fromHeight(64);
  @override
  Widget build(BuildContext context) => Container(
        color: C.blue,
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 16, 12),
        child: Row(children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 2))),
          ...actions,
        ]),
      );
}

class RoundIcon extends StatelessWidget {
  final IconData icon;
  const RoundIcon(this.icon, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 34, height: 34,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
        child: Icon(icon, color: Colors.white, size: 18),
      );
}

class Box extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  const Box({super.key, required this.child, this.padding = const EdgeInsets.all(12), this.color = C.card});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2))]),
        child: child,
      );
}

class Btn extends StatelessWidget {
  final String text;
  final Color color, fg;
  final VoidCallback? onTap;
  final bool outline;
  const Btn(this.text, {super.key, this.color = C.gold, this.fg = Colors.white, this.onTap, this.outline = false});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity, height: 42,
        child: ElevatedButton(
          onPressed: onTap ?? () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: fg, elevation: 0,
            side: outline ? BorderSide(color: fg) : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
}

class StatusChip extends StatelessWidget {
  final String text;
  final Color dot;
  const StatusChip(this.text, this.dot, {super.key});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 3, backgroundColor: dot),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: C.text)),
      ]);
}

class DetailBtn extends StatelessWidget {
  final String label;
  const DetailBtn(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: C.blue, borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.description_outlined, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ]),
      );
}
