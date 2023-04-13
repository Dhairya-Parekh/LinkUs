import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Welcome! Login or register to start using the App.'),
      ),
      bottomNavigationBar: Stack(
        children: <Widget>[
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 4.0,
                padding: const EdgeInsets.all(16.0),
                primary: Color.fromARGB(255, 194, 80, 65),
              ),
              child: const Text('Login'),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
          Positioned(
            bottom: 84.0,
            left: 16.0,
            right: 16.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 4.0,
                padding: const EdgeInsets.all(16.0),
                primary: Color.fromARGB(255, 22, 101, 167),
              ),
              child: const Text('Register'),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
            ),
          ),
        ],
      ),
    );
  }
}
