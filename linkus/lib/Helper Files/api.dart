import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:linkus/Helper%20Files/db.dart';

// TODO: Add error handling
// TODO: Remove Hardcoded response

class API {
  static const _baseUrl = 'http://192.168.0.104:8080';
  static final _client = http.Client();
  static final Map<String, String> _defaultHeaders = {
    'content-type': 'application/json'
  };

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode({'user_name': username, 'password': password}));
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> signup(
      String username, String email, String password) async {
    final url = Uri.parse('$_baseUrl/signup');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode(
            {'user_name': username, 'password': password, 'email': email}));
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> createGroup(
      String userId,
      String groupName,
      String groupInfo,
      List<Map<String, dynamic>> members) async {
    final url = Uri.parse('$_baseUrl/create_group');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode({
          'user_id': userId,
          'group_name': groupName,
          'group_info': groupInfo,
          'members': members
        }));
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> getUpdates(
      DateTime lastOpened, String userId) async {
    final url = Uri.https('$_baseUrl/get_updates', '', {
      'last_opened': lastOpened,
      'user_id': userId,
    });
    final response = await _client.get(
      url,
      headers: _defaultHeaders,
    );
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> broadcastMessage(
      String senderID, String groupID, Map<String, dynamic> link) async {
    final url = Uri.parse('$_baseUrl/send_message');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode(
            {'sender_id': senderID, 'group_id': groupID, 'link': link}));
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> broadcastReact(
      String senderID, String linkID, String groupID, String react) async {
    final url = Uri.parse('$_baseUrl/react');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode({
          'sender_id': senderID,
          'link_id': linkID,
          'group_id': groupID,
          'react': react
        }));
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> broadcastDelete(
      String userID, String linkID, String groupID) async {
    final url = Uri.parse('$_baseUrl/delete_message');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode(
            {'user_id': userID, 'link_id': linkID, 'group_id': groupID}));
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> broadcastAdd(
      String userId, String groupId, String name, GroupRole role) async {
    final url = Uri.parse('$_baseUrl/add_user');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode({
          'user_id': userId,
          'group_id': groupId,
          'new_member_name': name,
          'new_member_role': role.value
        }));
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> broadcastChangeRole(
      String userID, String groupID, String changerID, GroupRole role) async {
    final url = Uri.parse('$_baseUrl/change_role');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode({
          'user_id': userID,
          'group_id': groupID,
          'changer_id': changerID,
          'role': role.value
        }));
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  static Future<Map<String, dynamic>> broadcastKick(
      String userID, String kickerID, String groupID) async {
    final url = Uri.parse('$_baseUrl/remove_member');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode(
            {'user_id': userID, 'kicker_id': kickerID, 'group_id': groupID}));
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }
}
