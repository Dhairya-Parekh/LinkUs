import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/home.dart';
import 'package:linkus/profile.dart';
import 'package:linkus/Helper%20Files/api.dart';

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
          .createGroup(user?.userId, groupName, groupInfo, members)
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
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        elevation: 4.0, // Set the elevation to 4.0
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(
                          width:
                              100), // Add some horizontal space between the IconButton and Text
                      const Text(
                        'New Group',
                        style: TextStyle(
                            fontSize: 24.0), // Set the font size to 24.0
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0), // Add some vertical space
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Enter Users',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Add rounded borders
                              borderSide: const BorderSide(
                                  color: Colors.grey), // Add a grey border
                            ),
                            filled: true, // Fill the background color
                            fillColor: Colors
                                .white, // Set the background color to white
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, // Add some horizontal padding
                              vertical: 12.0, // Add some vertical padding
                            ),
                            suffixIcon: const Icon(Icons
                                .search), // Add a search icon on the right side
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
                              users.add({
                                'username': username,
                                'role': GroupRole.member
                              });
                              _usernameController.clear();
                            }
                          });
                        },
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
                            title: Text(user['username']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: user['role'] == GroupRole.admin
                                      ? 'Admin'
                                      : 'Member',
                                  hint: const Text('Choose Role'),
                                  items: <String>['Admin', 'Member']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? selectedRole) {
                                    setState(() {
                                      users[index]['role'] =
                                          selectedRole == 'Admin'
                                              ? GroupRole.admin
                                              : GroupRole.member;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
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
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 4.0,
                        backgroundColor: const Color.fromARGB(255, 194, 80, 65),
                        padding: const EdgeInsets.all(16.0),
                      ),
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
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        elevation: 4.0, // Set the elevation to 4.0
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(
                          width:
                              80), // Add some horizontal space between the IconButton and Text
                      const Text(
                        'Create Group',
                        style: TextStyle(
                            fontSize: 24.0), // Set the font size to 24.0
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      hintText: 'Group Name',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Add rounded borders
                        borderSide: const BorderSide(
                            color: Colors.grey), // Add a grey border
                      ),
                      filled: true, // Fill the background color
                      fillColor:
                          Colors.white, // Set the background color to white
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, // Add some horizontal padding
                        vertical: 12.0, // Add some vertical padding
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                            color:
                                Colors.blue), // Add a blue border when focused
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0), // Add some vertical spacing
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Group Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.blue),
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
                            title: Text(user['username']),
                            trailing:
                                Text(user['role'].toString().split('.').last),
                          );
                        }),
                  ),
                  const SizedBox(height: 16),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 4.0,
                        backgroundColor: const Color.fromARGB(255, 194, 80, 65),
                        padding: const EdgeInsets.all(16.0),
                      ),
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
            // Create Group tab
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            elevation: 4.0, // Set the elevation to 4.0
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  50), // Add some horizontal space between the IconButton and Text
                          const Text(
                            'New',
                            style: TextStyle(
                                fontSize: 24.0), // Set the font size to 24.0
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 4.0,
                            backgroundColor:
                                const Color.fromARGB(255, 194, 80, 65),
                            padding: const EdgeInsets.all(16.0),
                          ),
                          onPressed: () => _showAddMembersScreen(),
                          child: const Text('Create a new group'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
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
