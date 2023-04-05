import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final jsonResponse = await API.login(username, password);

    if (jsonResponse['success']) {
      // Login successful, do something here (e.g. navigate to home page)
      await saveCredentials(username, password).then((res) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    } else {
      // Login failed, display error message
      setState(() {
        _errorMessage = jsonResponse['message'];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Page'),
      ),
      body: _isLoading
          ? const Loading()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your username',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}