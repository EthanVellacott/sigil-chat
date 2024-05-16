import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:sigil/firebase_options.dart';
import 'package:sigil/routes/auth_gate.dart';
import 'package:sigil/routes/register.dart';
import 'package:sigil/routes/invites.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sigil",
      debugShowCheckedModeBanner: false,
      theme: sigilTheme,
      routes: {
        "/": (context) => const AuthGate(),
        "/register": (context) => const RegisterScreen(),
        "/invites": (context) => InviteScreen(),
      },
      initialRoute: "/",
    );
  }
}

ThemeData sigilTheme = ThemeData(
    colorScheme: ColorScheme.dark(
        background: Colors.grey.shade900,
        primary: Colors.amber.shade700,
        secondary: const Color.fromRGBO(200, 41, 10, 1),
        tertiary: Colors.blueGrey.shade500));
