import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'main_shell.dart';
import 'otp_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool login;
  const AuthScreen({super.key, required this.login});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController(), pass = TextEditingController();
  bool hide = true, busy = false;

  Future<void> _submit() async {
    setState(() => busy = true);
    final nav = Navigator.of(context);
    try {
      final body = {'email': email.text.trim(), 'password': pass.text};
      if (widget.login) {
        final r = await Api.post('/auth/login', body);
        await Api.saveSession(r['token']);
        nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
      } else {
        final r = await Api.post('/auth/register', body);
        _toOtp(r['devOtp']);
      }
    } on ApiError catch (e) {
      if (e.needOtp) {
        _toOtp(e.devOtp);
      } else if (mounted) {
        toast(context, e.message);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _toOtp(String? devOtp) {
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(email: email.text.trim(), devOtp: devOtp)));
  }

  Widget _field(String hint, TextEditingController c, {bool isPass = false}) => TextField(
        controller: c,
        obscureText: isPass && hide,
        keyboardType: isPass ? TextInputType.visiblePassword : TextInputType.emailAddress,
        style: const TextStyle(color: C.text),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          filled: true, fillColor: C.field,
          suffixIcon: isPass ? IconButton(icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white, size: 18), onPressed: () => setState(() => hide = !hide)) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Narrow(child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthScreen(login: !widget.login))),
                  child: Text(widget.login ? 'Sign up' : 'Log in', style: const TextStyle(color: C.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 28),
              Text(widget.login ? 'Log in' : 'Sign up', style: const TextStyle(color: C.gold, fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 36),
              _field('Email', email), const SizedBox(height: 16), _field('Password', pass, isPass: true),
              if (widget.login) const Padding(padding: EdgeInsets.only(top: 10), child: Text('Akun demo: demo@laporin.id / demo1234', style: TextStyle(color: C.grey, fontSize: 10))),
              const SizedBox(height: 56),
              Btn(busy ? 'Mohon tunggu...' : (widget.login ? 'Log in' : 'Sign up'), onTap: busy ? null : _submit),
            ]),
          ),
        )),
      );
}
