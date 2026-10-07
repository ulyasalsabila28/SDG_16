import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/async_view.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'create_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String filter = '';
  static const _tabs = [('', 'Semua'), ('belum', 'Belum Diverifikasi'), ('sedang', 'Sedang Diverifikasi'), ('selesai', 'Sudah Ditangani')];

  Widget _tab(String v, String t) {
    final sel = filter == v;
    return GestureDetector(
      onTap: () => setState(() => filter = v),
      child: Container(
        margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: sel ? C.gold : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.gold)),
        child: Text(sel && v == '' ? '✓ $t' : t, style: TextStyle(color: sel ? Colors.white : C.text, fontSize: 11)),
      ),
    );
  }

  Widget _count(String s, int n) => Expanded(child: Box(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        StatusChip(statusLabel[s]!, statusColor(s)),
        Text('$n', style: const TextStyle(color: C.text, fontSize: 22, fontWeight: FontWeight.w800)),
      ])));

  void _detail(Map r) => showModalBottomSheet(
        context: context, backgroundColor: C.cream,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r['code'] ?? '', style: const TextStyle(color: C.gold, fontSize: 10)),
          const SizedBox(height: 6),
          Text(r['title'], style: const TextStyle(color: C.text, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          StatusChip(statusLabel[r['status']]!, statusColor(r['status'])),
          const SizedBox(height: 10),
          Text(r['description'] == null || r['description'] == '' ? 'Tidak ada deskripsi.' : r['description'], style: const TextStyle(color: C.text, fontSize: 12)),
          const SizedBox(height: 10),
          Row(children: [const Icon(Icons.location_on, size: 13, color: C.gold), Text(' ${r['location'] ?? '-'}', style: const TextStyle(color: C.grey, fontSize: 11))]),
          const SizedBox(height: 4),
          Text('Dikirim: ${r['created_at']}', style: const TextStyle(color: C.grey, fontSize: 10)),
          const SizedBox(height: 10),
        ])),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppHeader('LAPORAN SAYA', actions: [
          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReportScreen())), child: const RoundIcon(Icons.add)),
        ]),
        body: AsyncView(
          key: ValueKey(filter),
          load: () => Api.get('/reports${filter.isEmpty ? '' : '?status=$filter'}'),
          builder: (c, d) {
            final cn = d['counts'];
            final list = d['reports'] as List;
            return ListView(padding: const EdgeInsets.all(16), children: [
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final t in _tabs) _tab(t.$1, t.$2)])),
              const SizedBox(height: 14),
              Row(children: [_count('belum', cn['belum']), const SizedBox(width: 8), _count('sedang', cn['sedang']), const SizedBox(width: 8), _count('selesai', cn['selesai'])]),
              const SizedBox(height: 16),
              const Text('LAPORAN TERBARU', style: TextStyle(color: C.gold, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (list.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Belum ada laporan', style: TextStyle(color: C.grey)))),
              for (final r in list)
                Container(margin: const EdgeInsets.only(bottom: 10), child: Box(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(r['code'] ?? '', style: const TextStyle(color: C.gold, fontSize: 9), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8), StatusChip(statusLabel[r['status']]!, statusColor(r['status'])),
                    const Spacer(), GestureDetector(onTap: () => _detail(r), child: const DetailBtn('Lihat detail')),
                  ]),
                  const SizedBox(height: 6),
                  Text(r['title'], style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.location_on, size: 11, color: C.gold), Flexible(child: Text(r['location'] ?? '', style: const TextStyle(color: C.grey, fontSize: 9)))]),
                ]))),
            ]);
          },
        ),
      );
}
