import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Theme/theme_constant.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/api.dart';

class AddMemberPopup extends StatefulWidget {
  final User user;
  final Group group;
  const AddMemberPopup({super.key, required this.user, required this.group});

  @override
  State<AddMemberPopup> createState() => _AddMemberPopupState();
}

class _AddMemberPopupState extends State<AddMemberPopup> {
  final TextEditingController _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  List<Map<String, dynamic>> users = [];
  bool _isLoading = false;

  Future<void> _addMember() async {
    // Check if group name and at least one user has been entered
    setState(() {
      _isLoading = true;
    });

    if (users.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter at least one user.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final members = users.map<Map<String, dynamic>>((user) {
      return {
        'user_name': user['username'],
        'role': user['role'],
        'group_id': widget.group.groupId,
      };
    }).toList();
    try {
      for (final member in members) {
        await API
            .broadcastAdd(
          widget.user.userId,
          widget.group.groupId,
          member['user_name'],
          member['role'],
        )
            .then((jsonResponse) async {
          if (jsonResponse['success']) {
            // Save the user to local database
            final memberId = jsonResponse['new_member_id'];
            final memberWithId = {
              'user_name': member['user_name'],
              'role': (member['role'] as GroupRole).value,
              'group_id': widget.group.groupId,
              'user_id': memberId,
            };
            await LocalDatabase.addUsers([memberWithId]);
          } else {
            // Display error message
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text("User ${member['user_name']} not found."),
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
        }).catchError((e) {
          throw e;
        });
      }
      // TODO; Make sure that the change is displayed without reload
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content:
                  const Text('Please check your internet connection and try again.'),
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
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final addMemberScreen = Column(
      children: [
        Row(
          children: [
            Material(
              color: CustomTheme.of(context).onPrimary,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: CustomTheme.of(context).primary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 100),
            Text(
              'Add Members',
              style: TextStyle(
                  color: CustomTheme.of(context).onPrimary, fontSize: 24.0),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: CustomTheme.of(context).secondary,
                  hintText: 'Enter Users',
                  hintStyle: TextStyle(
                    color: CustomTheme.of(context).onSecondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  // suffixIcon: Icon(
                  //   Icons.search,
                  //   color: CustomTheme.of(context).onSecondary,
                  // ),
                ),
                style: TextStyle(color: CustomTheme.of(context).onSecondary),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final username = _usernameController.text.trim();
                  if (username.isNotEmpty &&
                      !users
                          .map((user) => user['username'])
                          .contains(username)) {
                    users.add({'username': username, 'role': GroupRole.member});
                    _usernameController.clear();
                  }
                });
                FocusScope.of(context).unfocus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.of(context)
                    .onSecondary, // set the background color
                foregroundColor:
                    CustomTheme.of(context).secondary, // set the text color
              ),
              child: const Text('Add User'),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
                background: Container(color: CustomTheme.of(context).error),
                child: ListTile(
                  title: Text(
                    user['username'],
                    style: TextStyle(
                        fontSize: 20, color: CustomTheme.of(context).onPrimary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlutterSwitch(
                        width: 100.0,
                        height: 40.0,
                        valueFontSize: 12.0,
                        toggleSize: 12.0,
                        activeToggleColor: CustomTheme.of(context).onPrimary,
                        inactiveToggleColor: CustomTheme.of(context).primary,
                        value: user['role'] == GroupRole.admin,
                        activeColor: CustomTheme.of(context).primary,
                        inactiveColor: CustomTheme.of(context).onPrimary,
                        borderRadius: 16.0,
                        padding: 8.0,
                        showOnOff: true,
                        onToggle: (value) {
                          setState(() {
                            users[index]['role'] =
                                value ? GroupRole.admin : GroupRole.member;
                          });
                        },
                        activeText: 'Admin',
                        activeTextColor: CustomTheme.of(context).onPrimary,
                        inactiveText: 'Member',
                        inactiveTextColor: CustomTheme.of(context).primary,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: CustomTheme.of(context).onPrimary,
                        ),
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
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4.0,
                backgroundColor: CustomTheme.of(context).secondary,
                foregroundColor: CustomTheme.of(context).onSecondary,
                minimumSize: const Size(200, 40)),
            onPressed: _addMember,
            child: const Text('Next'),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: CustomTheme.of(context).primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: _isLoading ? const Loading() : addMemberScreen,
      ),
    );
  }
}
