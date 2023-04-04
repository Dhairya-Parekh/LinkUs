import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';

class Authenticator extends StatefulWidget {
  const Authenticator({super.key});

  @override
  State<Authenticator> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  @override
  void initState() {
    super.initState();
    checkAuthentication().then((isAuthenticated) {
      if (isAuthenticated) {
        // Navigate to home screen if user is authenticated
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Navigate to login screen if user is not authenticated
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Loading(),
      ),
    );
  }
}
