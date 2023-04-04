import 'package:flutter/material.dart';
import 'authenticator.dart';
import 'signup.dart';
import 'login.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkUs',
      initialRoute: '/',
      routes: {
        '/': (context) => const Authenticator(),
        '/signup': (context) => const Dummy(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const Dummy3(),
      },
    );
  }
}

class Dummy extends StatelessWidget {
  const Dummy({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Dummy'),
      ),
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
