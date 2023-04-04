import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkAuthentication() async {
  // Check if user is authenticated
  await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  if (username != null && password != null) {
    return true;
  } else {
    return false;
  }
}

Future<void> removeCredentials() async {
  // Logout user
  // await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('username');
  prefs.remove('password');
}

Future<void> saveCredentials(String username, String password) async {
  // Login user
  await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('username', username);
  prefs.setString('password', password);
}