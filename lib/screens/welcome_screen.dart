import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/async_view.dart';
import '../core/responsive.dart';
import '../core/widgets.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  void _go(BuildContext c, bool login) => Navigator.push(c, MaterialPageRoute(builder: (_) => AuthScreen(login: login)));

  static const _shadow = [Shadow(color: Color(0x88000000), blurRadius: 8)];

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    final radius = wide ? BorderRadius.circular(28) : const BorderRadius.vertical(top: Radius.circular(36));
    return Scaffold(
      body: Stack(children: [
        const Positioned.fill(child: PancasilaBg(overlay: 0)),
        Align(
          alignment: Alignment(0, wide ? -0.6 : -0.7),
          child: FadeIn(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('LAPORIN', style: TextStyle(color: Colors.white, fontSize: wide ? 64 : 44, fontWeight: FontWeight.w900, letterSpacing: 3, shadows: _shadow)),
              const SizedBox(height: 6),
              Text('KEADILAN SOSIAL BAGI SELURUH RAKYAT INDONESIA', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: wide ? 13 : 9, letterSpacing: 1, shadows: _shadow)),
            ]),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(wide ? 32 : 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 440 : double.infinity),
              child: FadeIn(
                index: 2,
                child: ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(36, 30, 36, wide ? 30 : 34),
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(color: Colors.white38),
                        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x40B5862F), Color(0x80B5862F)]),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Log in or sign up', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, shadows: _shadow)),
                        const SizedBox(height: 18),
                        Btn('Log in with email', color: const Color(0xE68E2A9B), onTap: () => _go(context, true)),
                        const SizedBox(height: 8),
                        Btn('Log in with Facebook', color: const Color(0xE62A6F97), onTap: () => toast(context, 'Login Facebook belum tersedia')),
                        const SizedBox(height: 8),
                        Btn('Continue with Google', color: const Color(0x33FFFFFF), outline: true, onTap: () => toast(context, 'Login Google belum tersedia')),
                        const SizedBox(height: 18),
                        Center(child: GestureDetector(
                          onTap: () => _go(context, false),
                          child: const Text('Sign up', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, shadows: _shadow)),
                        )),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
