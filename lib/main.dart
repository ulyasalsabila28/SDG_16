import 'package:flutter/material.dart';
import 'core/api.dart';
import 'core/theme.dart';
import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.loadSession();
  var loggedIn = false;
  if (Api.token != null) {
    try {
      await Api.get('/profile');
      loggedIn = true;
    } on ApiError catch (e) {
      if (!e.message.startsWith('Tidak dapat')) await Api.logout();
      loggedIn = false;
    }
  }
  runApp(LaporinApp(loggedIn: loggedIn));
}

class LaporinApp extends StatelessWidget {
  final bool loggedIn;
  const LaporinApp({super.key, required this.loggedIn});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Laporin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: C.cream, colorScheme: ColorScheme.fromSeed(seedColor: C.gold)),
        home: loggedIn ? const MainShell() : const WelcomeScreen(),
      );
}
