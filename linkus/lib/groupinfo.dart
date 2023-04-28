import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Theme/theme_constant.dart';

// TODO: Handle deleting group
// TODO: Take user info from parent widget

class GroupInfoPage extends StatefulWidget {
  final Group group;
  final User user;
  const GroupInfoPage({super.key, required this.group, required this.user});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  // group description
  Map<String, dynamic> groupInfo = {};
  bool _isGroupInfoLoading = true;
  int _isMemberInfoLoading = -1;
  Map<String, dynamic> userInfo = {};
  final TextEditingController _usernameController = TextEditingController();
  List<Map<String, dynamic>> users = [];

  Future<void> _loadGroupInfo() async {
    final ginfo = await LocalDatabase.getGroupInfo(widget.group.groupId);
    final uinfo = await LocalDatabase.getGroupSpecificUserInfo(
        widget.user.userId, widget.group.groupId);
    setState(() {
      groupInfo = ginfo;
      userInfo = uinfo;
      _isGroupInfoLoading = false;
    });
  }

  Future<void> _leaveGroup() async {
    if (userInfo["isSoleAdmin"]) {
      // Not allowed to leave group if you are the sole admin
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text(
              "You are the sole admin of this group. You cannot leave the group."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      API
          .broadcastLeave(widget.user.userId, widget.group.groupId)
          .then((response) => {
                if (response["success"] == true)
                  {
                    LocalDatabase.removeMembers([
                      {
                        "group_id": widget.group.groupId,
                        "affected_id": widget.user.userId,
                      }
                    ]).then((value) => {
                          //Go back to home page after leaving group
                          Navigator.popUntil(
                              context, ModalRoute.withName('/home'))
                        })
                  }
                else
                  {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Error"),
                        content: Text(response["message"]),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    )
                  }
              });
    }
  }

  Future<void> _changeMemberRole(int index, GroupRole role) async {
    setState(() {
      _isMemberInfoLoading = index;
    });
    String userID = groupInfo["members"][index]["userId"];
    API
        .broadcastChangeRole(
            userID, widget.group.groupId, widget.user.userId, role)
        .then((Map<String, dynamic> response) async {
      if (response["success"] == true) {
        await LocalDatabase.updateRoles([
          {
            "group_id": widget.group.groupId,
            "user_id": userID,
            "role": role,
          }
        ]);
        setState(() {
          groupInfo["members"][index]["role"] = role;
          _isMemberInfoLoading = -1;
        });
      } else {
        setState(() {
          _isMemberInfoLoading = -1;
        });
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(response["message"]),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> _kickMember(int index) async {
    setState(() {
      _isMemberInfoLoading = index;
    });
    String userID = groupInfo["members"][index]["userId"];
    API
        .broadcastKick(userID, widget.user.userId, widget.group.groupId)
        .then((Map<String, dynamic> response) async {
      if (response["success"] == true) {
        await LocalDatabase.removeMembers([
          {
            "group_id": widget.group.groupId,
            "user_id": userID,
          }
        ]);
        setState(() {
          groupInfo["members"].removeAt(index);
          _isMemberInfoLoading = -1;
        });
      } else {
        setState(() {
          _isMemberInfoLoading = -1;
        });
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(response["message"]),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> _deleteGroup() async {
    String userID = widget.user.userId;
    String groupID = widget.group.groupId;
    Map<String,dynamic> response = await API.deleteGroup(userID, groupID); 
    if(response["success"])
    {
      await LocalDatabase.deleteGroup(groupID);
      Navigator.popUntil(context, ModalRoute.withName('/home'));
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
  
   Future<void> _addMember() async {
    // Check if group name and at least one user has been entered
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
        }).catchError((e) {
          print(e);
        });
      }
      // TODO; Make sure that the change is displayed without reload
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
      setState(() {
      _loadGroupInfo();
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
                      onPressed: () => _addMember(),
                      child: const Text('Add'),
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
    _loadGroupInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            CustomTheme.of(context).gradientStart,
            CustomTheme.of(context).gradientEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.clamp,
        )),
        child: _isGroupInfoLoading
            ? const Loading()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50.0),
                  Row(
                    children: [
                      IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back, color: CustomTheme.of(context).onPrimary)),
                      const SizedBox(width: 16.0),
                      Text(
                        widget.group.groupName,
                        style: TextStyle(
                          color: CustomTheme.of(context).onPrimary,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ]
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: groupInfo["members"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            groupInfo["members"][index]["userName"],
                            style: TextStyle(
                                color: CustomTheme.of(context).secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                          trailing: userInfo["isAdmin"]
                              ? _isMemberInfoLoading == index
                                  ? const CircularProgressIndicator()
                                  : _isMemberInfoLoading != -1
                                      ? null
                                      : PopupMenuTheme(
                                          data: PopupMenuThemeData(
                                            color: CustomTheme.of(context).onPrimary
                                          ),                                          
                                          child: PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert, color: CustomTheme.of(context).onPrimary),
                                            onSelected: (String value) {
                                              if (value == "Make admin") {
                                                _changeMemberRole(
                                                    index, GroupRole.admin);
                                              } else if (value == "Make member") {
                                                _changeMemberRole(
                                                    index, GroupRole.member);
                                              } else if (value == "Kick") {
                                                // kick member
                                                _kickMember(index);
                                              }
                                            },
                                            itemBuilder: (BuildContext context) {
                                              return <PopupMenuEntry<String>>[
                                                PopupMenuItem<String>(
                                                  value: "Make member",
                                                  child: Text("Make member", style: TextStyle(color: CustomTheme.of(context).primary)),
                                                ),
                                                PopupMenuItem<String>(
                                                  value: "Make admin",
                                                  child: Text("Make admin", style: TextStyle(color: CustomTheme.of(context).primary)),
                                                ),
                                                PopupMenuItem<String>(
                                                  value: "Kick",
                                                  child: Text("Kick", style: TextStyle(color: CustomTheme.of(context).primary)),
                                                ),
                                              ];
                                            },
                                          ),
                                      )
                              : null,
                          subtitle: Text(
                            groupInfo["members"][index]["role"] ==
                                    GroupRole.admin
                                ? "Admin"
                                : "Member",
                            style: TextStyle(
                                color: CustomTheme.of(context).onPrimary,
                                fontSize: 16
                              ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        groupInfo["groupDesc"],
                        style: TextStyle(
                          fontSize: 20.0,
                          color: CustomTheme.of(context).primary
                        ),
                      ),
                    ),
                  ),
                  // Button to add members
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: userInfo["isAdmin"]
                          ? ElevatedButton(
                              onPressed: () {
                                _showAddMembersScreen();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    CustomTheme.of(context).primary,
                                minimumSize: const Size(350, 40),
                              ),
                              child: Text("Add members",
                                  style: TextStyle(
                                    color: CustomTheme.of(context).onPrimary,
                                  )),
                            )
                          : null,
                    ),
                  ),
                  // Button to leave group
                  const SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: userInfo["isAdmin"]
                          ? ElevatedButton(
                              onPressed: _leaveGroup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomTheme.of(context).error,
                                minimumSize: const Size(350, 40),
                              ),
                              child: Text("Leave group",
                                  style: TextStyle(
                                    color: CustomTheme.of(context).onSecondary,
                                  )),
                            )
                          : null,
                    ),
                  ),
                  // Button to delete group
                  const SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: userInfo["isAdmin"]
                          ? ElevatedButton(
                              onPressed: () {
                                _deleteGroup();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomTheme.of(context).error,
                                minimumSize: const Size(350, 40),
                              ),
                              child: Text("Delete group",
                                  style: TextStyle(
                                    color: CustomTheme.of(context).onSecondary,
                                  )),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
