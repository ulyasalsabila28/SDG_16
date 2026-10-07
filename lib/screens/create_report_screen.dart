import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class CreateReportScreen extends StatefulWidget {
  final String category;
  const CreateReportScreen({super.key, this.category = 'pemerintahan'});
  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  late String cat = widget.category;
  final title = TextEditingController(), desc = TextEditingController(), loc = TextEditingController();
  bool busy = false;

  Widget _in(String hint, TextEditingController c, {int lines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: c, maxLines: lines, style: const TextStyle(color: C.text),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            filled: true, fillColor: C.field,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      );

  Widget _catBtn(String v, String label) => Expanded(child: GestureDetector(
        onTap: () => setState(() => cat = v),
        child: Container(
          margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: cat == v ? C.gold : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.gold)),
          child: Center(child: Text(label, style: TextStyle(color: cat == v ? Colors.white : C.text, fontWeight: FontWeight.w700, fontSize: 12))),
        ),
      ));

  Future<void> _send() async {
    setState(() => busy = true);
    final nav = Navigator.of(context), msg = ScaffoldMessenger.of(context);
    try {
      await Api.post('/reports', {'category': cat, 'title': title.text, 'description': desc.text, 'location': loc.text});
      Api.reportsChanged.value++;
      nav.pop();
      msg.showSnackBar(const SnackBar(content: Text('Laporan berhasil dikirim')));
    } on ApiError catch (e) {
      if (mounted) toast(context, e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const AppHeader('BUAT LAPORAN'),
        body: Narrow(maxWidth: 640, child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('JENIS LAPORAN', style: TextStyle(color: C.gold, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(children: [_catBtn('pemerintahan', 'Pemerintahan'), _catBtn('kriminal', 'Kriminal')]),
          const SizedBox(height: 16),
          _in('Judul laporan', title), _in('Lokasi kejadian', loc), _in('Deskripsi', desc, lines: 5),
          const SizedBox(height: 6),
          Btn(busy ? 'Mengirim...' : 'KIRIM LAPORAN', color: C.blue, onTap: busy ? null : _send),
        ])),
      );
}
