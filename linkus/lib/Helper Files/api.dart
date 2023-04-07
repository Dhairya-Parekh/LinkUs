// import 'package:http/http.dart' as http;
// import 'dart:convert';

// TODO: Add error handling
// TODO: Remove Hardcoded response

class API {
  // static const _baseUrl = 'https://example.com/api';
  // static final _client = http.Client();
  // static final Map<String, String> _defaultHeaders = {'content-type': 'application/json'};

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
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
      'data': {'username': username, 'password': password}
    };
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> signup(
      String name, String email, String password) async {
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
      'data': {'name': name, 'email': email, 'password': password}
    };
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> createGroup(
      String userName,
      String groupName,
      String groupInfo,
      List<Map<String, dynamic>> members) async {
    // final url = Uri.parse('$_baseUrl/create_group');
    // final response = await _client.post(
    //   url,
    //   headers: _defaultHeaders,
    //   body: jsonEncode({
    //     'user_id': userId,
    //     'group_name': groupName,
    //     'group_info': groupInfo,
    //     'members': members
    //   })
    // );
    // final jsonResponse = jsonDecode(response.body);
    final jsonResponse = {
      'success': true,
      'message': 'Group created successfully',
      'group_id': 0
    };
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> broadcastMessage(
      int senderId,
      int grouoId,
      Map<String, dynamic> link) async {
    // final url = Uri.parse('$_baseUrl/create_group');
    // final response = await _client.post(
    //   url,
    //   headers: _defaultHeaders,
    //   body: jsonEncode({
    //     'sender_id': senderId,
    //     'group_id': groupId,
    //     'link': link,
    //   })
    // );
    // final jsonResponse = jsonDecode(response.body);
    final jsonResponse = {
      'link_id': 0,
      'timestamp': 10,
    };
    return jsonResponse;
  }

  static Future<Map<String,dynamic>> changeRole(int groupId, int userId, String role) async {
    // final url = Uri.parse('$_baseUrl/changeRole');
    // final response = await _client.post(
    //   url,
    //   headers: _defaultHeaders,
    //   body: jsonEncode({
    //     'groupId': groupId, 
    //     'userId': userId, 
    //     'role': role
    //   })
    // );
    // final jsonResponse = jsonDecode(response.body);
    final jsonResponse = {
      'success': true,
      'message': 'Role changed successfully',
      'data': {
        'groupId': groupId,
        'userId': userId,
        'role': role
      }
    };
    return jsonResponse;
  }

  static Future<Map<String,dynamic>> kickUser(int groupId, int userId) async {
    // final url = Uri.parse('$_baseUrl/kickUser');
    // final response = await _client.post(
    //   url,
    //   headers: _defaultHeaders,
    //   body: jsonEncode({
    //     'groupId': groupId, 
    //     'userId': userId
    //   })
    // );
    // final jsonResponse = jsonDecode(response.body);
    final jsonResponse = {
      'success': true,
      'message': 'User kicked successfully',
      'data': {
        'groupId': groupId,
        'userId': userId
      }
    };
    return jsonResponse;
  }
}


