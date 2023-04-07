import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/db.dart';

// TODO: Handle admin leaving group and deleting group

class GroupInfoPage extends StatefulWidget {
  final Group group;
  const GroupInfoPage({super.key, required this.group});

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
    // TODO: Change user id to actual user id
    final uinfo = await LocalDatabase.getGroupSpecificUserInfo(
        "userId", widget.group.groupId);
    setState(() {
      groupInfo = ginfo;
      userInfo = uinfo;
      _isGroupInfoLoading = false;
    });
  }

  Future<void> _leaveGroup() async {
    // await LocalDatabase.leaveGroup(widget.group.id);
    // Navigator.pop(context);
  }

  Future<void> _changeMemberRole(int index, GroupRole role) async {
    setState(() {
      _isMemberInfoLoading = index;
    });
    String userID = groupInfo["members"][index]["userId"];
    Map<String, dynamic> response = await API.broadcastChangeRole(
        widget.group.groupId, userID, userInfo["userId"], role);
    if (response["success"] == true) {
      await LocalDatabase.updateRoles([
        {
          "groupId": widget.group.groupId,
          "userId": userID,
          "role": role,
        }
      ]);
      setState(() {
        groupInfo["members"][index]["role"] = role;
        _isMemberInfoLoading = -1;
      });
    }
  }

  Future<void> _kickMember(int index) async {
    setState(() {
      _isMemberInfoLoading = index;
    });
    String userID = groupInfo["members"][index]["userId"];
    Map<String, dynamic> response = await API.broadcastKick(
        widget.group.groupId, userID, userInfo["userId"]
    );
    if (response["success"] == true) {
      await LocalDatabase.removeMembers([
        {
          "groupId": widget.group.groupId,
          "userId": userID,
        }
      ]);
      setState(() {
        groupInfo["members"].removeAt(index);
        _isMemberInfoLoading = -1;
      });
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
                  child: ElevatedButton(
                    onPressed: () {
                      // leave group
                    },
                    child: const Text("Leave group"),
                  ),
                ),
                // Button to add members
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // add members
                    },
                    child: const Text("Add members"),
                  ),
                ),
              ],
            ),
    );
  }
}
