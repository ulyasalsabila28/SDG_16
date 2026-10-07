import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/api.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'main_shell.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String? devOtp;
  const OtpScreen({super.key, required this.email, this.devOtp});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final code = TextEditingController();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    code.addListener(() => setState(() {}));
    if (widget.devOtp != null) WidgetsBinding.instance.addPostFrameCallback((_) => toast(context, 'Kode OTP (mode dev): ${widget.devOtp}'));
  }

  Future<void> _verify() async {
    if (code.text.length != 6) return toast(context, 'Masukkan 6 digit kode OTP');
    setState(() => busy = true);
    final nav = Navigator.of(context);
    try {
      final r = await Api.post('/auth/verify-otp', {'email': widget.email, 'otp': code.text});
      await Api.saveSession(r['token']);
      nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
    } on ApiError catch (e) {
      if (mounted) toast(context, e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      final r = await Api.post('/auth/resend-otp', {'email': widget.email});
      if (mounted) toast(context, r['devOtp'] != null ? 'Kode OTP baru (mode dev): ${r['devOtp']}' : 'Kode OTP dikirim ulang');
    } on ApiError catch (e) {
      if (mounted) toast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Narrow(child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              const SizedBox(height: 80),
              const Text('Verifikasi', style: TextStyle(color: C.gold, fontSize: 18, fontWeight: FontWeight.w700)),
              const Text('Kode OTP sudah dikirim ke emailmu', style: TextStyle(color: C.grey, fontSize: 11)),
              const SizedBox(height: 50),
              SizedBox(
                height: 36,
                child: Stack(children: [
                  Container(
                    color: C.field,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(6, (i) => i < code.text.length
                        ? Text(code.text[i], style: const TextStyle(color: C.text, fontWeight: FontWeight.w800))
                        : const CircleAvatar(radius: 4, backgroundColor: Colors.white))),
                  ),
                  Positioned.fill(child: Opacity(opacity: 0, child: TextField(
                    controller: code, autofocus: true, keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  ))),
                ]),
              ),
              const SizedBox(height: 50),
              Btn(busy ? 'Memeriksa...' : 'Verifikasi', color: const Color(0xFFFFF8E1), fg: C.gold, outline: true, onTap: busy ? null : _verify),
              const SizedBox(height: 8),
              Btn('Kirim Ulang', onTap: _resend),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _resend,
                child: const Text.rich(TextSpan(style: TextStyle(color: C.grey, fontSize: 11), children: [
                  TextSpan(text: 'Tidak menerima Kode OTP? '),
                  TextSpan(text: 'Resend again', style: TextStyle(color: C.blue, fontWeight: FontWeight.bold)),
                ])),
              ),
            ]),
          ),
        )),
      );
}
