import 'package:flutter/material.dart';
import 'package:linkus/Theme/theme_constant.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 4.0,
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: CustomTheme.of(context).secondary,
                ),
                child: Text('Register',
                    style: TextStyle(
                      color: CustomTheme.of(context).onSecondary,
                    )
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
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
                  backgroundColor: CustomTheme.of(context).primary,
                ),
                child: Text('Login',
                style: TextStyle(
                  color: CustomTheme.of(context).onPrimary,
                )
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}