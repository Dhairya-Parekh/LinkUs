import 'package:shared_preferences/shared_preferences.dart';

class User{
  String username;
  String userId;
  String email;
  User({required this.username, required this.userId, required this.email});
}

Future<bool> checkAuthentication() async {
  // Check if user is authenticated
  await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  String? userid = prefs.getString('userid');
  String? email = prefs.getString('email');
  if (username != null && password != null && userid != null && email != null) {
    return true;
  } else {
    return false;
  }
}

Future<void> removeCredentials() async {
  // Logout user
  await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('username');
  prefs.remove('password');
  prefs.remove('userid');
  prefs.remove('email');
}

Future<void> saveCredentials(String username, String password, String userId, String email) async {
  // Login user
  await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('username', username);
  prefs.setString('password', password);
  prefs.setString('userid', userId);
  prefs.setString('email', email);
}

Future<User?> getUser() async {
  // Login user
  await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? userid = prefs.getString('userid');
  String? email = prefs.getString('email');
  if (username != null && userid != null && email != null) {
    return User(username: username, userId: userid, email: email);
  } else {
    return null;
  }
}

Future<Map<String, dynamic>> getUserCredentials() async {
  await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  String? userid = prefs.getString('userid');
  return {'username': username, 'password': password, 'userid': userid};
}

Future<String> getUserId() async {
  await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String userid = prefs.getString('userid') ?? "";
  return userid;
}

Future<DateTime> getLastFetched(String userId) async {
  // await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? lastFetchedString = prefs.getString('last_fetched_$userId');
  final DateTime lastFetched = lastFetchedString != null
      ? DateTime.parse(lastFetchedString)
      : DateTime.fromMillisecondsSinceEpoch(0);
  return lastFetched;
}

Future<void> setLastFetched(String userId,DateTime lastFetched) async {
  // await Future.delayed(const Duration(seconds: 3), () {});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('last_fetched_$userId', lastFetched.toIso8601String());
}