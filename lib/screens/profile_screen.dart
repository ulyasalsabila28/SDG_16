import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/async_view.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _sec(String t, List<Widget> rows) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Box(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(color: C.gold, fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 6), ...rows,
      ])));
  Widget _info(String k, String? v) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Text(k, style: const TextStyle(color: C.grey, fontSize: 10)), const Spacer(), Text(v == null || v.isEmpty ? 'Belum tersedia' : v, style: const TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 10))]));
  Widget _nav(String t, VoidCallback onTap) => InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Text(t, style: const TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 11)), const Spacer(), const Icon(Icons.chevron_right, size: 16, color: C.text)])));
  Widget _stat(String l, String v) => Column(children: [Text(l, style: const TextStyle(color: C.grey, fontSize: 9)), Text(v, style: const TextStyle(color: C.text, fontSize: 20, fontWeight: FontWeight.w800))]);

  void _info2(BuildContext c, String title, String text) => showDialog(
        context: c,
        builder: (_) => AlertDialog(backgroundColor: C.cream, title: Text(title, style: const TextStyle(color: C.text, fontSize: 16)), content: Text(text, style: const TextStyle(fontSize: 12)),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Tutup'))]),
      );

  void _edit(BuildContext c, Map u) {
    final name = TextEditingController(text: u['name']), phone = TextEditingController(text: u['phone'] ?? ''), loc = TextEditingController(text: u['location'] ?? '');
    showDialog(context: c, builder: (_) => AlertDialog(
      backgroundColor: C.cream,
      title: const Text('Ubah profil', style: TextStyle(color: C.text, fontSize: 16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama lengkap')),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor telepon')),
        TextField(controller: loc, decoration: const InputDecoration(labelText: 'Lokasi')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Batal')),
        TextButton(onPressed: () async {
          try {
            await Api.put('/profile', {'name': name.text, 'phone': phone.text, 'location': loc.text});
            Api.reportsChanged.value++;
            if (c.mounted) Navigator.pop(c);
          } on ApiError catch (e) {
            if (c.mounted) toast(c, e.message);
          }
        }, child: const Text('Simpan')),
      ],
    ));
  }

  Future<void> _logout(BuildContext c) async {
    final nav = Navigator.of(c);
    await Api.logout();
    nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: AsyncView(
          load: () => Api.get('/profile'),
          builder: (c, d) {
            final u = d['user'] as Map;
            return Column(children: [
              AppHeader('PROFILE', actions: [GestureDetector(onTap: () => _edit(context, u), child: const RoundIcon(Icons.edit_outlined))]),
              Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
                Padding(padding: const EdgeInsets.only(bottom: 10), child: Box(child: Column(children: [
                  Row(children: [
                    CircleAvatar(radius: 22, backgroundColor: C.blue, child: Text(u['name'].toString()[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(u['name'], style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 13)),
                      Text('${u['location'] ?? 'Kota Medan'}, Sumatera Utara, Indonesia', style: const TextStyle(color: C.grey, fontSize: 9)),
                      Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(8)), child: const Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 9))),
                    ])),
                  ]),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_stat('Total laporan', '${d['total']}'), _stat('Laporan Selesai', '${d['selesai']}')]),
                ]))),
                _sec('INFORMASI AKUN', [_info('Nama lengkap', u['name'].toString().split(' ').first), _info('Email', u['email']), _info('Nomor telepon', u['phone']), _info('Lokasi', u['location'])]),
                _sec('PENGATURAN AKUN', [
                  _nav('Ubah profil', () => _edit(context, u)),
                  _nav('Notifikasi', () => _info2(context, 'Notifikasi', 'Belum ada notifikasi baru.')),
                  _nav('Kebijakan privasi', () => _info2(context, 'Kebijakan privasi', 'Data laporan hanya digunakan untuk proses penanganan pengaduan.')),
                ]),
                _sec('BANTUAN', [
                  _nav('Pusat bantuan', () => _info2(context, 'Pusat bantuan', 'Pilih jenis laporan, lengkapi bukti, kirim, lalu pantau status di tab Laporan.')),
                  _nav('Hubungi admin', () => _info2(context, 'Hubungi admin', 'Email: admin@laporin.id')),
                ]),
                InkWell(onTap: () => _logout(context), child: const Box(child: Row(children: [Text('Keluar akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 11)), Spacer(), Icon(Icons.logout, color: Colors.red, size: 16)]))),
              ])),
            ]);
          },
        ),
      );
}
