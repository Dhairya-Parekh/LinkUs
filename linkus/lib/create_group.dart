import 'package:flutter/material.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';

class CreateGroupPage extends StatefulWidget {
  final User user;
  const CreateGroupPage({super.key, required this.user});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> users = [];

  Future<void> _createGroup() async {
    // Check if group name and at least one user has been entered
    if (_groupNameController.text.trim().isEmpty || users.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('Please enter a group name and at least one user.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final groupName = _groupNameController.text.trim();
    final groupInfo = _descriptionController.text.trim();
    final members = users.map<Map<String, dynamic>>((user) {
      return {
        'participant_name': user['username'],
        'role': (user['role'] as GroupRole).value,
      };
    }).toList();
    try {
      await API
          .createGroup(widget.user.userId, groupName, groupInfo, members)
          .then((jsonResponse) async {
        if (jsonResponse['success']) {
          // Save the group to local database
          // print(jsonResponse);
          LocalDatabase.getAdded([
            {
              'group_id': jsonResponse['group_id'],
              'group_name': groupName,
              'group_info': groupInfo,
              'members': jsonResponse['members']
                  .map<Map<String, dynamic>>(
                      (message) => message as Map<String, dynamic>)
                  .toList(),
            }
          ]).then((value) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        } else {
          // Group creation failed, display error message
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(jsonResponse['message']),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      });
    } catch (e) {
      print(e);
    }

    // if (jsonResponse['success']) {
    //   // Group creation successful, do something here (e.g. navigate to home page)
    //   Navigator.pushReplacementNamed(context, '/home');
    // } else {
    //   // Group creation failed, display error message
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: const Text('Error'),
    //         content: Text(jsonResponse['message']),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.of(context).pop(),
    //             child: const Text('OK'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Enter group name:'),
                const SizedBox(height: 8),
                TextField(
                  controller: _groupNameController,
                  decoration: const InputDecoration(
                    hintText: 'Group Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Enter group description:'),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Group Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: "Enter username...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final username = _usernameController.text.trim();
                      if (username.isNotEmpty &&
                          !users
                              .map((user) => user['username'])
                              .contains(username)) {
                        users.add(
                            {'username': username, 'role': GroupRole.member});
                        _usernameController.clear();
                      }
                    });
                  },
                  child: const Text('Add User'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Dismissible(
                  key: Key(user['username']),
                  onDismissed: (direction) {
                    setState(() {
                      users.removeAt(index);
                    });
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(user['username']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: user['role'] == GroupRole.admin
                              ? 'Admin'
                              : 'Member',
                          hint: const Text('Choose Role'),
                          items:
                              <String>['Admin', 'Member'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? selectedRole) {
                            setState(() {
                              users[index]['role'] = selectedRole == 'Admin'
                                  ? GroupRole.admin
                                  : GroupRole.member;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              users.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _createGroup,
              child: const Text('Create Group'),
            ),
          ),
        ],
      ),
    );
  }
}
