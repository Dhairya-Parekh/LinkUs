import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';

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
    }
  }
  @override
  void initState() {
    super.initState();
    _loadGroupInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.groupName),
      ),
      body: _isGroupInfoLoading
          ? const Loading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Members",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: groupInfo["members"].length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(groupInfo["members"][index]["userName"]),
                        trailing: userInfo["isAdmin"]
                            ? _isMemberInfoLoading == index
                                ? const CircularProgressIndicator()
                                : _isMemberInfoLoading != -1
                                    ? null
                                    : PopupMenuButton<String>(
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
                                            const PopupMenuItem<String>(
                                              value: "Make member",
                                              child: Text("Make member"),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: "Make admin",
                                              child: Text("Make admin"),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: "Kick",
                                              child: Text("Kick"),
                                            ),
                                          ];
                                        },
                                      )
                            : null,
                        subtitle: Text(groupInfo["members"][index]["role"] ==
                                GroupRole.admin
                            ? "Admin"
                            : "Member"),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    groupInfo["groupDesc"],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                // Button to leave group
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: userInfo["isMember"]
                      ? ElevatedButton(
                          onPressed: _leaveGroup,
                          child: const Text("Leave group"),
                        )
                      : null,
                ),
                // Button to add members
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: userInfo["isAdmin"]
                      ? ElevatedButton(
                          onPressed: () {
                            // add members
                          },
                          child: const Text("Add members"),
                        )
                      : null,
                ),
                // Button to delete group
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: userInfo["isAdmin"]
                      ? ElevatedButton(
                          onPressed: () {
                            // delete group
                            _deleteGroup();
                          },
                          child: const Text("Delete group"),
                        )
                      : null,
                ),
              ],
            ),
    );
  }
}
