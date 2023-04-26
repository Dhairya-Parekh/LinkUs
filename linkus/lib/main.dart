import 'package:flutter/material.dart';
import 'package:linkus/app.dart';
import 'package:linkus/authenticator.dart';
import 'package:linkus/login.dart';
import 'package:linkus/signup.dart';
import 'package:linkus/welcome.dart';

void main() {
  runApp(const LinkUs());
}

class LinkUs extends StatelessWidget {
  const LinkUs({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      title: 'LinkUs',
      initialRoute: '/',
      routes: {
        '/': (context) => const Authenticator(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const App(),
        '/welcome': (context) => const Welcome(),
      },
    );
  }
}
