import 'package:flutter/material.dart';
import 'package:linkus/app.dart';
import 'package:linkus/authenticator.dart';
import 'package:linkus/login.dart';
import 'package:linkus/signup.dart';


void main() {
  runApp(const LinkUs());
}

class LinkUs extends StatelessWidget {
  const LinkUs({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkUs',
      initialRoute: '/',
      routes: {
        '/': (context) => const Authenticator(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const App(),
      },
    );
  }
}

class Dummy3 extends StatelessWidget {
  const Dummy3({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Dummy 3'),
      ),
    );
  }
}
