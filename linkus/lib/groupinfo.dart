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
                        "user_id": widget.user.userId,
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
                                // add members
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
                                print("delete group");
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
