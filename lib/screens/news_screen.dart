import 'dart:async';
import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/async_view.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool searching = false;
  bool grid = false;
  String q = '';
  final _page = PageController();
  int _cur = 0, _count = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_count < 2 || !_page.hasClients) return;
      _page.animateToPage((_cur + 1) % _count, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  void _read(Map n) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: C.cream,
          title: Text(n['title'], style: const TextStyle(color: C.text, fontSize: 16, fontWeight: FontWeight.w800)),
          content: Text(n['body'] ?? n['summary'] ?? '', style: const TextStyle(color: C.text, fontSize: 12)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
        ),
      );

  Widget _thumb({double? w, double? h, double radius = 8, double icon = 40}) => Container(
        width: w, height: h,
        decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(radius)),
        child: Center(child: Icon(Icons.image, size: icon, color: C.gold)),
      );

  Widget _slide(Map n, {required bool isMain}) => Box(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            _thumb(h: 110),
            Positioned(left: 8, top: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(8)),
              child: Text(isMain ? 'Utama' : 'Terbaru', style: const TextStyle(color: Colors.white, fontSize: 9)),
            )),
          ]),
          const SizedBox(height: 8),
          Text(n['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 14)),
          Text(n['summary'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.grey, fontSize: 10)),
          const Spacer(),
          Row(children: [
            const Icon(Icons.location_on, size: 11, color: C.gold),
            Text(n['location'] ?? '', style: const TextStyle(fontSize: 9, color: C.grey)),
            const Spacer(),
            GestureDetector(onTap: () => _read(n), child: const DetailBtn('Baca berita')),
          ]),
        ]),
      );

  Widget _carousel(List slides) {
    _count = slides.length;
    if (_cur >= _count) _cur = 0;
    return Column(children: [
      SizedBox(
        height: 215,
        child: PageView.builder(
          controller: _page,
          itemCount: slides.length,
          onPageChanged: (i) => setState(() => _cur = i),
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: _slide(slides[i], isMain: slides[i]['is_main'] == 1),
          ),
        ),
      ),
      if (slides.length > 1) Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int i = 0; i < slides.length; i++) AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _cur ? 18 : 6, height: 6,
            decoration: BoxDecoration(color: i == _cur ? C.gold : C.field, borderRadius: BorderRadius.circular(3)),
          ),
        ]),
      ),
    ]);
  }

  Widget _listItem(Map n) => GestureDetector(
        onTap: () => _read(n),
        child: Container(margin: const EdgeInsets.only(bottom: 10), child: Box(padding: const EdgeInsets.all(8), child: Row(children: [
          _thumb(w: 56, h: 48, radius: 6, icon: 24),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n['title'], style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 12)),
            Text(n['summary'] ?? '', style: const TextStyle(color: C.grey, fontSize: 9)),
          ])),
        ]))),
      );

  Widget _gridItem(Map n) => GestureDetector(
        onTap: () => _read(n),
        child: Box(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _thumb(h: 80, radius: 6, icon: 28),
          const SizedBox(height: 8),
          Text(n['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 2),
          Text(n['summary'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.grey, fontSize: 9)),
        ])),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppHeader('BERITA', actions: [
          GestureDetector(onTap: () => setState(() { searching = !searching; q = ''; }), child: RoundIcon(searching ? Icons.close : Icons.search)),
        ]),
        body: AsyncView(
          load: () => Api.get('/news'),
          builder: (c, d) {
            final all = (d as List).where((n) => '${n['title']} ${n['summary']}'.toLowerCase().contains(q.toLowerCase())).toList();
            final main = all.where((n) => n['is_main'] == 1).toList();
            final rest = all.where((n) => n['is_main'] != 1).toList();
            // Carousel: berita utama lebih dulu, dilengkapi berita terbaru hingga 3 slide.
            final slides = [...main, ...rest].take(3).toList();
            return ListView(padding: const EdgeInsets.all(16), children: [
              if (searching) Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(
                autofocus: true, onChanged: (v) => setState(() => q = v),
                decoration: InputDecoration(hintText: 'Cari berita...', filled: true, fillColor: C.field, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
              )),
              if (slides.isNotEmpty) _carousel(slides),
              const SizedBox(height: 16),
              SectionHeader('BERITA TERBARU', grid: grid, onChanged: (v) => setState(() => grid = v)),
              const SizedBox(height: 8),
              if (all.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Berita tidak ditemukan', style: TextStyle(color: C.grey)))),
              if (grid)
                RGrid(cols: 2, wideCols: 3, gap: 10, children: [for (final n in rest) _gridItem(n)])
              else
                for (final n in rest) _listItem(n),
            ]);
          },
        ),
      );
}
