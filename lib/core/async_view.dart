import 'package:flutter/material.dart';
import 'api.dart';
import 'theme.dart';
import 'widgets.dart';

class AsyncView extends StatefulWidget {
  final Future<dynamic> Function() load;
  final Widget Function(BuildContext context, dynamic data) builder;
  const AsyncView({super.key, required this.load, required this.builder});
  @override
  State<AsyncView> createState() => _AsyncViewState();
}

class _AsyncViewState extends State<AsyncView> {
  late Future<dynamic> f = widget.load();
  @override
  void initState() {
    super.initState();
    Api.reportsChanged.addListener(_reload);
  }

  @override
  void dispose() {
    Api.reportsChanged.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (mounted) setState(() => f = widget.load());
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: f,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator(color: C.gold));
          if (s.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${s.error}', textAlign: TextAlign.center, style: const TextStyle(color: C.text)),
              const SizedBox(height: 12),
              SizedBox(width: 160, child: Btn('Coba lagi', onTap: _reload)),
            ])));
          }
          return widget.builder(c, s.data);
        },
      );
}

class PancasilaBg extends StatelessWidget {
  final double overlay;
  const PancasilaBg({super.key, this.overlay = 0.55});
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: C.goldGrad)),
        Image.network(kBgImage, fit: BoxFit.cover, webHtmlElementStrategy: WebHtmlElementStrategy.fallback, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
          const Color(0xFF8A6420).withValues(alpha: overlay), const Color(0xFFB5862F).withValues(alpha: overlay),
        ]))),
      ]);
}
