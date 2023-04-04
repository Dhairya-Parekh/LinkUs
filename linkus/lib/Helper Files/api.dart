// import 'package:http/http.dart' as http;
// import 'dart:convert';

// TODO: Add error handling
// TODO: Remove Hardcoded response

class API {
  // static const _baseUrl = 'https://example.com/api';
  // static final _client = http.Client();
  // static final Map<String, String> _defaultHeaders = {'content-type': 'application/json'};

  static Future<Map<String, dynamic>> login(String username, String password) async {
    // final url = Uri.parse('$_baseUrl/login');
    // final response = await _client.post(
    //   url,
    //   headers: _defaultHeaders,
    //   body: jsonEncode({
    //     'username': username, 
    //     'password': password
    //   })
    // );
    // final jsonResponse = jsonDecode(response.body);
    await Future.delayed(const Duration(seconds: 3), () {});
    final jsonResponse = {
      'success': true,
      'message': 'Login successful',
      'data': {
        'username': username,
        'password': password
      }
    };
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    // final url = Uri.parse('$_baseUrl/signup');
    // final response = await _client.post(
    //   url,
    //   headers: _defaultHeaders,
    //   body: jsonEncode({
    //     'name': name, 
    //     'email': email, 
    //     'password': password
    //   })
    // );
    // final jsonResponse = jsonDecode(response.body);
    final jsonResponse = {
      'success': true,
      'message': 'Signup successful',
      'data': {
        'name': name,
        'email': email,
        'password': password
      }
    };
    return jsonResponse;
  }
}
