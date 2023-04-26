import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Theme/theme_constant.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Call requestFocus() on the username focus node after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _usernameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final jsonResponse = await API.login(username, password);

    if (jsonResponse['success']) {
      // Login successful, do something here (e.g. navigate to home page)
      await saveCredentials(username, password, jsonResponse["user_id"],
              jsonResponse["email"])
          .then((res) {
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
        body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CustomTheme.of(context).gradientStart,
                  CustomTheme.of(context).gradientEnd,
                ],
              ),
            ),
            child: _isLoading
              ? const Loading()
              : SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 100),
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            color: CustomTheme.of(context).onBackground,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sign in to continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: CustomTheme.of(context).onBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 100),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: _usernameController,
                            focusNode: _usernameFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Username',
                              hintStyle: TextStyle(
                                color: CustomTheme.of(context).primary,
                              ),
                              filled: true,
                              fillColor: CustomTheme.of(context).onBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: TextStyle(
                              color: CustomTheme.of(context).primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: CustomTheme.of(context).primary,
                              ),
                              filled: true,
                              fillColor: CustomTheme.of(context).onBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: TextStyle(
                              color: CustomTheme.of(context).primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100),
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(200, 40),
                              backgroundColor: CustomTheme.of(context).primary,
                            ),
                            child: Text('Login',
                                style: TextStyle(
                                  color: CustomTheme.of(context).onPrimary,
                                )),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            color: CustomTheme.of(context).error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/signup');
                            },
                            child: Text(
                              'Don\'t have an account? Sign up',
                              style: TextStyle(
                                color: CustomTheme.of(context).onBackground,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                ),
              ),
        ),
      ),
    );
  }
}
