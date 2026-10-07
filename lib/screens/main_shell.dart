import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'create_report_screen.dart';
import 'home_screen.dart';
import 'news_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'welcome_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int get i => Api.tab.value;
  static const _items = [
    (Icons.home_outlined, 'Beranda'), (Icons.description_outlined, 'Laporan'),
    (Icons.newspaper_outlined, 'Berita'), (Icons.person_outline, 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    Api.tab.value = 0;
    Api.tab.addListener(_rebuild);
  }

  @override
  void dispose() {
    Api.tab.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Widget _pages(bool wide) {
    Widget p(Widget w) => wide ? Narrow(maxWidth: 820, child: w) : w;
    return IndexedStack(index: i, children: [const HomeScreen(), p(const ReportsScreen()), p(const NewsScreen()), p(const ProfileScreen())]);
  }

  Widget _sidebar() => Container(
        width: 240,
        decoration: const BoxDecoration(gradient: C.goldGrad),
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.only(left: 8), child: Text('LAPORIN!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2))),
          const Padding(padding: EdgeInsets.only(left: 8, bottom: 28), child: Text('segala bentuk tindak kejahatan', style: TextStyle(color: Colors.white70, fontSize: 10))),
          for (var n = 0; n < _items.length; n++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Api.tab.value = n,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: i == n ? Colors.white30 : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Icon(_items[n].$1, color: Colors.white, size: 20), const SizedBox(width: 12),
                    Text(_items[n].$2, style: TextStyle(color: Colors.white, fontWeight: i == n ? FontWeight.w800 : FontWeight.w500)),
                  ]),
                ),
              ),
            ),
          const Spacer(),
          Btn('Buat Laporan', color: C.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReportScreen()))),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              final nav = Navigator.of(context);
              await Api.logout();
              nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 16),
            label: const Text('Keluar akun', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );

  Widget _bottomBar() => Container(
        color: C.gold,
        padding: EdgeInsets.only(top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
        child: Row(children: [
          for (var n = 0; n < _items.length; n++)
            Expanded(child: InkWell(
              onTap: () => Api.tab.value = n,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  decoration: BoxDecoration(color: i == n ? Colors.white30 : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                  child: Icon(_items[n].$1, color: Colors.white, size: 22),
                ),
                Text(_items[n].$2, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: i == n ? FontWeight.bold : FontWeight.normal)),
              ]),
            )),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    return Scaffold(
      body: wide ? Row(children: [_sidebar(), Expanded(child: _pages(true))]) : _pages(false),
      bottomNavigationBar: wide ? null : _bottomBar(),
    );
  }
}
