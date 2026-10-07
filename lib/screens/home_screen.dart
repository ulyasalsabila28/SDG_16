import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/async_view.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'create_report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _maxW = 1100.0;
  Widget _label(String t, {Color c = C.gold}) => Text(t, style: TextStyle(color: c, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600));
  Widget _title(String t, {Color c = C.blue}) => Text(t, style: TextStyle(color: c, fontSize: 20, fontWeight: FontWeight.w800));
  String _num(num n) => n.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  void _create(BuildContext c, [String cat = 'pemerintahan']) => Navigator.push(c, MaterialPageRoute(builder: (_) => CreateReportScreen(category: cat)));
  Widget _section(Widget child, {Color? color, Gradient? gradient}) => Container(
        decoration: BoxDecoration(color: color, gradient: gradient),
        child: Narrow(maxWidth: _maxW, child: Padding(padding: const EdgeInsets.all(20), child: child)),
      );

  Widget _cat(BuildContext c, IconData i, String t, String s, String cat) => Expanded(child: HoverLift(
        onTap: () => _create(c, cat),
        child: Box(color: C.cream, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(i, color: C.blue, size: 20), const SizedBox(height: 10),
          Text(t, style: const TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 13)),
          Text(s, style: const TextStyle(color: C.text, fontSize: 10)),
        ])),
      ));

  // Hero: gambar Pancasila + lapisan emas. HP = satu kolom, layar lebar = dua kolom.
  Widget _hero(BuildContext c, Map u) {
    final wide = isWide(c);
    final name = u['name'].toString().split(' ').first;
    final head = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white54)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, color: Colors.white, size: 14), const SizedBox(width: 4), Text(u['location'] ?? 'Kota Medan', style: const TextStyle(color: Colors.white, fontSize: 12))]),
      ),
      SizedBox(height: wide ? 28 : 24),
      Text('Selamat Datang, $name', style: TextStyle(color: Colors.white, fontSize: wide ? 34 : 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Silahkan pilih masalah mana yang ingin kamu laporkan...', style: TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
    final cats = Row(children: [
      _cat(c, Icons.account_balance, 'Pemerintahan', 'Fasilitas dan Layanan', 'pemerintahan'), const SizedBox(width: 12),
      _cat(c, Icons.shield, 'Kriminal', 'Tindak Kejahatan', 'kriminal'),
    ]);
    final btn = Btn('BUAT LAPORAN SEKARANG!', color: C.blue, onTap: () => _create(c));
    return Stack(children: [
      const Positioned.fill(child: PancasilaBg()),
      Narrow(maxWidth: _maxW, child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: wide ? 48 : 20),
        child: FadeIn(
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [head, const SizedBox(height: 24), SizedBox(width: 320, child: btn)])),
                  const SizedBox(width: 40), Expanded(child: cats),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [head, const SizedBox(height: 14), cats, const SizedBox(height: 14), btn]),
        ),
      )),
    ]);
  }

  Widget _emergency(BuildContext c) => GestureDetector(
        onTap: () => toast(c, 'Hubungi 110 (Polisi) atau 112 (Darurat) dari aplikasi telepon Anda'),
        child: Container(
          color: C.red,
          child: Narrow(maxWidth: _maxW, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: const [
            CircleAvatar(radius: 14, backgroundColor: Color(0xFFC0392B), child: Icon(Icons.phone, color: Colors.white, size: 14)),
            SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bantuan Darurat', style: TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 12)),
              Text('Untuk kejadian yang sedang berlangsung', style: TextStyle(color: C.text, fontSize: 10)),
            ])),
            Text('110    112', style: TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 11)),
          ]))),
        ),
      );

  Widget _myReports(Map d) {
    final cn = d['counts'] as Map;
    final l = d['latest'] as Map?;
    Widget row(Color col, String t, int n) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
          CircleAvatar(radius: 3, backgroundColor: col), const SizedBox(width: 8),
          Expanded(child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 11))),
          CountUp(n, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ]));
    final step = l == null ? 0 : (l['status'] == 'belum' ? 1 : (l['status'] == 'sedang' ? 2 : 3));
    Widget dot(int n, IconData ic) => AnimatedContainer(
          duration: const Duration(milliseconds: 400), width: 20, height: 20,
          decoration: BoxDecoration(shape: BoxShape.circle, color: step >= n ? C.blue : Colors.white54),
          child: step >= n ? Icon(ic, size: 12, color: Colors.white) : null,
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('LAPORAN SAYA'), const SizedBox(height: 4), _title('Pantau Setiap Langkah'), const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))]),
        child: Column(children: [
          Row(children: [const Expanded(child: Text('Total laporan Anda', style: TextStyle(color: Colors.white, fontSize: 11))), CountUp(cn['total'], style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800))]),
          const Divider(color: Colors.white54),
          row(Colors.red, 'Belum Diverifikasi', cn['belum']), row(Colors.amber, 'Sedang Diverifikasi', cn['sedang']), row(Colors.green, 'Sudah Ditangani', cn['selesai']),
        ]),
      ),
      if (l != null) ...[
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${statusLabel[l['status']]}   ${l['code']}', style: const TextStyle(color: Colors.white70, fontSize: 9)),
            const SizedBox(height: 6),
            Text(l['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 14),
            Row(children: [dot(1, Icons.check), const Expanded(child: Divider(color: Colors.white70)), dot(2, Icons.sync), const Expanded(child: Divider(color: Colors.white70)), dot(3, Icons.check)]),
          ]),
        ),
      ],
    ]);
  }

  Widget _arrowCard(IconData i, String t, String s, {bool gold = false, VoidCallback? onTap}) {
    final fg = gold ? Colors.white : C.text;
    return HoverLift(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: gold ? null : C.card, gradient: gold ? C.goldGrad : null, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: C.blue, borderRadius: BorderRadius.circular(8)), child: Icon(i, color: Colors.white, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)), Text(s, style: TextStyle(color: fg, fontSize: 9))])),
        Icon(Icons.subdirectory_arrow_right, color: fg),
      ]),
    ));
  }

  Widget _done(List done) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: _label('SELESAI DITANGANI')), GestureDetector(onTap: () => Api.tab.value = 1, child: _label('Semua'))]),
        const SizedBox(height: 4), _title('Perubahan yang sudah\nterwujud'), const SizedBox(height: 14),
        for (final r in done) Padding(padding: const EdgeInsets.only(bottom: 10), child: _arrowCard(Icons.construction, r['title'], r['location'] ?? '', gold: true, onTap: () => Api.tab.value = 1)),
      ]);

  Widget _stat(IconData i, num v, String l, String Function(double) f) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: C.blueLight, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(i, color: Colors.white), const SizedBox(height: 8), CountUp(v, format: f, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)), Text(l, style: const TextStyle(color: Colors.white70, fontSize: 9))]),
      );

  Widget _transparency(Map s) => _section(color: C.blue, Column(children: [
        const Text('TRANSPARANSI PUBLIK', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 14),
        const Text('Bersama, kita membuat kota\nlebih baik', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        RGrid(children: [
          _stat(Icons.assignment, s['total'], 'Total laporan', (v) => _num(v)),
          _stat(Icons.check_box_outlined, s['done_pct'], 'Sudah ditangani', (v) => '${v.toStringAsFixed(1).replaceAll('.', ',')}%'),
          _stat(Icons.schedule, s['avg_days'], 'Rata-rata', (v) => '${v.toStringAsFixed(1).replaceAll('.', ',')} hari'),
          _stat(Icons.groups, s['reporters'], 'Pelapor Aktif', (v) => _num(v)),
        ]),
      ]));

  Widget _guide(BuildContext c) {
    Widget g(IconData i, String t, String n) => HoverLift(child: Container(
          height: 90, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFE6C778), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(i, color: C.blue, size: 18), const Spacer(), Text(n, style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w800))]),
            const Spacer(), Text(t, style: const TextStyle(color: C.text, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        ));
    return _section(gradient: C.goldGrad, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('PANDUAN', c: Colors.white), const SizedBox(height: 4), _title('Empat langkah menuju perubahan'), const SizedBox(height: 14),
      RGrid(children: [
        g(Icons.touch_app, 'Pilih Jenis Laporan', '01'), g(Icons.photo_camera, 'Lengkapi Bukti Dokumentasi', '02'),
        g(Icons.send, 'Tinjau dan Kirim Laporan', '03'), g(Icons.fact_check, 'Pantau Status Laporan', '04'),
      ]),
      const SizedBox(height: 14), Btn('BUAT LAPORAN SEKARANG!', color: C.blue, onTap: () => _create(c)),
    ]));
  }

  Widget _news(BuildContext c, List alerts) => _section(color: C.blue, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('INFORMASI WILAYAH', c: Colors.white70), const SizedBox(height: 4),
        Row(children: [const Expanded(child: Text('Berita dan Peringatan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))), GestureDetector(onTap: () => Api.tab.value = 2, child: const Text('Semua', style: TextStyle(color: Colors.white, fontSize: 11)))]),
        const SizedBox(height: 14),
        RGrid(cols: 1, wideCols: 2, children: [
          for (var i = 0; i < alerts.length; i++)
            _arrowCard(i == 0 ? Icons.warning_amber : Icons.campaign, alerts[i]['title'], alerts[i]['summary'] ?? '', onTap: () => showDialog(
                  context: c,
                  builder: (_) => AlertDialog(backgroundColor: C.cream, title: Text(alerts[i]['title'], style: const TextStyle(color: C.text, fontSize: 16)), content: Text(alerts[i]['body'] ?? '', style: const TextStyle(fontSize: 12)),
                      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Tutup'))]),
                )),
        ]),
      ]));

  Widget _pair(Map d) => _section(LayoutBuilder(builder: (c, box) {
        final a = _myReports(d), b = _done(d['done']);
        return box.maxWidth >= 800
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: a), const SizedBox(width: 32), Expanded(child: b)])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [a, const SizedBox(height: 24), b]);
      }));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppHeader('LAPORIN!', actions: [
          GestureDetector(onTap: () => Api.tab.value = 2, child: const Icon(Icons.search, color: Colors.white)),
          const SizedBox(width: 16),
          GestureDetector(onTap: () => toast(context, 'Belum ada notifikasi baru'), child: const Icon(Icons.notifications_none, color: Colors.white)),
        ]),
        body: AsyncView(
          load: () => Api.get('/home'),
          builder: (c, d) => ListView(padding: EdgeInsets.zero, children: [
            _hero(c, d['user']), _emergency(c), FadeIn(index: 1, child: _pair(d)), FadeIn(index: 2, child: _transparency(d['stats'])),
            FadeIn(index: 3, child: _guide(c)), _news(c, d['alerts']), const _Faq(),
          ]),
        ),
      );
}

class _Faq extends StatefulWidget {
  const _Faq();
  @override
  State<_Faq> createState() => _FaqState();
}

class _FaqState extends State<_Faq> {
  int open = 0;
  static const _q = [
    ('Bagaimana laporan saya ditangani?', 'Laporan diverifikasi, diteruskan kepada instansi terkait, lalu diperbarui statusnya hingga selesai.'),
    ('Apakah identitas pelapor aman?', 'Identitas Anda hanya dipakai untuk verifikasi dan tidak ditampilkan kepada publik.'),
    ('Apakah Laporin digunakan pada keadaan darurat?', 'Tidak. Untuk kejadian yang sedang berlangsung, hubungi 110 atau 112.'),
  ];
  @override
  Widget build(BuildContext context) => Narrow(maxWidth: 800, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PERTANYAAN UMUM', style: TextStyle(color: C.gold, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)), const SizedBox(height: 4),
        const Text('Hal yang perlu diketahui', style: TextStyle(color: C.blue, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 14),
        Box(child: Column(children: [
          for (var i = 0; i < _q.length; i++)
            InkWell(
              onTap: () => setState(() => open = open == i ? -1 : i),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.help_outline, size: 18, color: C.text), const SizedBox(width: 8), Expanded(child: Text(_q[i].$1, style: const TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 12))), Icon(open == i ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: C.text)]),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250), curve: Curves.easeOut, alignment: Alignment.topLeft,
                  child: open == i ? Padding(padding: const EdgeInsets.only(left: 26, top: 4), child: Text(_q[i].$2, style: const TextStyle(color: C.grey, fontSize: 10))) : const SizedBox(width: double.infinity),
                ),
              ])),
            ),
        ])),
      ])));
}
