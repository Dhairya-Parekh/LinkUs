import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Theme/theme_constant.dart';
import 'package:linkus/home.dart';
import 'package:linkus/profile.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:flutter_switch/flutter_switch.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  int _currentIndex = 0;
  User? user;
  List<Widget> _tabs = [];
  bool _isLoading = true;

  Future<void> _createGroup() async {
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
          .createGroup(user?.userId, groupName, groupInfo, members)
          .then((jsonResponse) async {
        if (jsonResponse['success']) {
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
  }

  _showAddMembersScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(color: CustomTheme.of(context).primary),
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        'New Group',
                        style: TextStyle(
                            color: CustomTheme.of(context).onPrimary,
                            fontSize: 24.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameController,
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
                              borderSide: BorderSide.none
                            ),
                            // suffixIcon: Icon(
                            //   Icons.search,
                            //   color: CustomTheme.of(context).onSecondary,
                            // ),
                          ),
                          style: TextStyle(color: CustomTheme.of(context).onSecondary),
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
                              users.add({
                                'username': username,
                                'role': GroupRole.member
                              });
                              _usernameController.clear();
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.of(context)
                              .onSecondary, // set the background color
                          foregroundColor: CustomTheme.of(context)
                              .secondary, // set the text color
                        ),
                        child: const Text('Add User'),
                      ),
                    ],
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
                            title: Text(
                              user['username'],
                              style: TextStyle(
                                fontSize: 20,
                                color: CustomTheme.of(context).onPrimary
                              ),
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
                                      users[index]['role'] = value ? GroupRole.admin : GroupRole.member;
                                    });
                                  },
                                  activeText: 'Admin',
                                  activeTextColor: CustomTheme.of(context).onPrimary,
                                  inactiveText: 'Member',
                                  inactiveTextColor: CustomTheme.of(context).primary,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: CustomTheme.of(context).onPrimary,),
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
                      onPressed: () => _showCreateGroupScreen(),
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _showCreateGroupScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(color: CustomTheme.of(context).primary),
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: CustomTheme.of(context).onPrimary,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: CustomTheme.of(context).primary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 80),
                      Text(
                        'Create Group',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: CustomTheme.of(context).onPrimary
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    style: TextStyle(
                      color: CustomTheme.of(context).onSecondary,
                    ),
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CustomTheme.of(context).secondary,
                      hintText: 'Group Name',
                      hintStyle: TextStyle(
                        color: CustomTheme.of(context).onSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    style: TextStyle(
                      color: CustomTheme.of(context).onSecondary,
                    ),
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CustomTheme.of(context).secondary,
                      hintText: 'Group Description',
                      hintStyle: TextStyle(
                        color: CustomTheme.of(context).onSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            title: Text(
                              user['username'],
                              style: TextStyle(
                                fontSize: 20,
                                color: CustomTheme.of(context).onPrimary
                              )
                            ),
                            trailing: Text(
                              user['role'].toString().split('.').last,
                              style: TextStyle(
                                fontSize: 20,
                                color: CustomTheme.of(context).onPrimary
                              )
                            ),
                          );
                        }),
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
                      onPressed: () => _createGroup(),
                      child: const Text('Create Group'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUser().then((user) {
      if (user != null) {
        LocalDatabase.setupLocalDatabase(user.userId);
        setState(() {
          this.user = user;
          _tabs = [
            HomePage(user: user),
            HomePage(user: user),
            ProfilePage(user: user),
          ];
          _isLoading = false;
        });
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? const Loading() : _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          if (index == 1) {
            _showAddMembersScreen();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Create Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
