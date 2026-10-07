import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/async_view.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool searching = false;
  String q = '';

  void _read(Map n) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: C.cream,
          title: Text(n['title'], style: const TextStyle(color: C.text, fontSize: 16, fontWeight: FontWeight.w800)),
          content: Text(n['body'] ?? n['summary'] ?? '', style: const TextStyle(color: C.text, fontSize: 12)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
        ),
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
            return ListView(padding: const EdgeInsets.all(16), children: [
              if (searching) Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(
                autofocus: true, onChanged: (v) => setState(() => q = v),
                decoration: InputDecoration(hintText: 'Cari berita...', filled: true, fillColor: C.field, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
              )),
              if (main.isNotEmpty) Box(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Stack(children: [
                  Container(height: 120, decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.image, size: 40, color: C.gold))),
                  Positioned(left: 8, top: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(8)), child: const Text('Utama', style: TextStyle(color: Colors.white, fontSize: 9)))),
                ]),
                const SizedBox(height: 8),
                Text(main[0]['title'], style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 14)),
                Text(main[0]['summary'] ?? '', style: const TextStyle(color: C.grey, fontSize: 10)),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.location_on, size: 11, color: C.gold), Text(main[0]['location'] ?? '', style: const TextStyle(fontSize: 9, color: C.grey)), const Spacer(), GestureDetector(onTap: () => _read(main[0]), child: const DetailBtn('Baca berita'))]),
              ])),
              const SizedBox(height: 16),
              const Text('BERITA TERBARU', style: TextStyle(color: C.gold, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (all.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Berita tidak ditemukan', style: TextStyle(color: C.grey)))),
              for (final n in rest)
                GestureDetector(onTap: () => _read(n), child: Container(margin: const EdgeInsets.only(bottom: 10), child: Box(padding: const EdgeInsets.all(8), child: Row(children: [
                  Container(width: 56, height: 48, decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.image, color: C.gold)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n['title'], style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 12)),
                    Text(n['summary'] ?? '', style: const TextStyle(color: C.grey, fontSize: 9)),
                  ])),
                ])))),
            ]);
          },
        ),
      );
}
