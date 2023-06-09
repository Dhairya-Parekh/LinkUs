import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';

// Add error handling
// Remove Hardcoded response

class API {
  static const _baseUrl = 'https://linkus.onrender.com';
  // static const _baseUrl = 'http://192.168.2.104:8080';
  static final _client = http.Client();
  static final Map<String, String> _defaultHeaders = {
    'content-type': 'application/json'
  };

  static void updateCookies(http.Response response) {
    String? cookies = response.headers['set-cookie'];
    if (cookies != null) {
      int index = cookies.indexOf(';');
      _defaultHeaders['cookie'] =
          (index == 1) ? cookies : cookies.substring(0, index);
    }
  }

  static Future<void> handleSessionTimeout() async {
    Map<String, dynamic> user = await getUserCredentials();
    if (user['username'] != null && user['password'] != null) {
      Map<String, dynamic> response =
          await authenticate(user['username']!, user['password']!);
      if (response['success'] == true) {
      } else {
        throw Exception('Session Timed Out');
      }
    }
  }

  static Future<Map<String, dynamic>> authenticate(
      String username, String password) async {
    final url = Uri.parse('$_baseUrl/authenticate');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode({'user_name': username, 'password': password}));
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception(
          'Failed to authenticate. Error code ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode({'user_name': username, 'password': password}));
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to login. Error code ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> signup(
      String username, String email, String password) async {
    final url = Uri.parse('$_baseUrl/signup');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode(
            {'user_name': username, 'password': password, 'email': email}));
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to signup. Error code ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> createGroup(
      String? userId,
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
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await createGroup(userId, groupName, groupInfo, members);
    } else {
      throw Exception(
          'Failed to create group. Error code ${response.statusCode}');
    }
  }

  static Map<String, dynamic> formatUpdates(Map<String, dynamic> updates)
  {
    Map<String, dynamic> formattedUpdates = {};
    List<Map<String, dynamic>> newMessagesActions = updates['new_messages'].map<Map<String, dynamic>>((message) => message as Map<String, dynamic>).toList();
    for (int i = 0; i < newMessagesActions.length; i++) {
      List<String> tags = List<String>.from(newMessagesActions[i]['tags'].map<String>((e) => e.toString())).toList();
      newMessagesActions[i]['tags'] = tags;
    }
    formattedUpdates['new_messages_actions'] = newMessagesActions;

     List<Map<String, dynamic>> deleteMessagesActions = updates['delete_messages'].map<Map<String, dynamic>>((message) => message as Map<String, dynamic>).toList(); 
    formattedUpdates['delete_messages_actions'] = deleteMessagesActions;

     List<Map<String, dynamic>> reactActions = updates['react'].map<Map<String, dynamic>>((message) => message as Map<String, dynamic>).toList();
    formattedUpdates['react_actions'] = reactActions;

     List<Map<String, dynamic>> rawchangeRoleActions = updates['change_role'].map<Map<String, dynamic>>((message) => message as Map<String, dynamic>).toList();
    List<Map<String, dynamic>> changeRoleActions = [];
    for (Map<String, dynamic> changeRoleAction in rawchangeRoleActions) {
        Map<String, dynamic> newChangeRoleAction = {};
        newChangeRoleAction['user_id'] = changeRoleAction['affected_id'];
        newChangeRoleAction['group_id'] = changeRoleAction['group_id'];
        newChangeRoleAction['role'] = changeRoleAction['affected_role'] == 'adm'
            ? GroupRole.admin
            : changeRoleAction['affected_role'] == 'mem'
                ? GroupRole.member
                : null;
        changeRoleActions.add(newChangeRoleAction);
      }
    formattedUpdates['change_role_actions'] = changeRoleActions;

     List<Map<String, dynamic>> removeMemberActions = updates['remove_member'].map<Map<String, dynamic>>((message) => message as Map<String, dynamic>).toList();
    formattedUpdates['remove_member_actions'] = removeMemberActions;

     List<Map<String, dynamic>> addUserActions = updates['add_user'].map<Map<String, dynamic>>((message) => message as Map<String, dynamic>).toList();
    formattedUpdates['add_user_actions'] = addUserActions;

     List<Map<String, dynamic>> getAddedActions = updates['get_added'].map<Map<String, dynamic>>((message) => message as Map<String, dynamic>).toList();
    for (int i=0; i < getAddedActions.length; i++) {
      List<Map<String, dynamic>> members = getAddedActions[i]['members'].map<Map<String, dynamic>>((message) => message as Map<String, dynamic>).toList();
      getAddedActions[i]['members'] = members;
    }
    formattedUpdates['get_added_actions'] = getAddedActions;

     List<Map<String, dynamic>> deletedGroupsActions = updates['deleted_groups'].map<Map<String, dynamic>>((message) => message as Map<String, dynamic>).toList();
    formattedUpdates['deleted_groups_actions'] = deletedGroupsActions;
    
    formattedUpdates['time_stamp'] = updates['time_stamp'];
    return formattedUpdates;
  }

  static Future<Map<String, dynamic>> getUpdates(
      DateTime lastOpened, String userId) async {
    final url = Uri.parse(
        '$_baseUrl/get_updates?time_stamp=${lastOpened.toIso8601String()}&user_id=$userId');
    final response = await _client.get(
      url,
      headers: _defaultHeaders,
    );
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return formatUpdates(jsonResponse);
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await getUpdates(lastOpened, userId);
    } else {
      throw Exception(
          'Failed to get updates. Error code ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> broadcastMessage(
      String senderID, String groupID, Map<String, dynamic> link) async {
    final url = Uri.parse('$_baseUrl/send_message');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode(
            {'sender_id': senderID, 'group_id': groupID, 'link': link}));
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await broadcastMessage(senderID, groupID, link);
    } else {
      throw Exception(
          'Failed to send message. Error code ${response.statusCode}');
    }
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
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await broadcastReact(senderID, linkID, groupID, react);
    } else {
      throw Exception('Failed to react. Error code ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> broadcastDelete(
      String userID, String linkID, String groupID) async {
    final url = Uri.parse('$_baseUrl/delete_message');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode(
            {'user_id': userID, 'link_id': linkID, 'group_id': groupID}));
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await broadcastDelete(userID, linkID, groupID);
    } else {
      throw Exception(
          'Failed to delete message. Error code ${response.statusCode}');
    }
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
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await broadcastAdd(userId, groupId, name, role);
    } else {
      throw Exception('Failed to add user. Error code ${response.statusCode}');
    }
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
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await broadcastChangeRole(userID, groupID, changerID, role);
    } else {
      throw Exception(
          'Failed to change role. Error code ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> broadcastKick(
      String userID, String kickerID, String groupID) async {
    final url = Uri.parse('$_baseUrl/remove_member');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode(
            {'user_id': userID, 'kicker_id': kickerID, 'group_id': groupID}));
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await broadcastKick(userID, kickerID, groupID);
    } else {
      throw Exception(
          'Failed to remove member. Error code ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> broadcastLeave(
      String userID, String groupID) async {
    final url = Uri.parse('$_baseUrl/leave_group');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode({'user_id': userID, 'group_id': groupID}));
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await broadcastLeave(userID, groupID);
    } else {
      throw Exception(
          'Failed to leave group. Error code ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> deleteGroup(String userID, String groupId) async{
    final url = Uri.parse('$_baseUrl/delete_group');
    final response = await _client.post(url,
        headers: _defaultHeaders,
        body: jsonEncode({'user_id': userID, 'group_id': groupId}));
    if (response.statusCode == 200) {
      updateCookies(response);
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await handleSessionTimeout();
      return await deleteGroup(userID, groupId);
    } else {
      throw Exception(
          'Failed to delete group. Error code ${response.statusCode}');
    }
  }
}
