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

  Future<void> _loadGroupInfo() async {
    final info = await LocalDatabase.getGroupInfo(widget.group.id);
    setState(() {
      groupInfo = info;
      _isGroupInfoLoading = false;
    });
  }

  Future<void> _leaveGroup() async {
    // await LocalDatabase.leaveGroup(widget.group.id);
    // Navigator.pop(context);
  }

  Future<void> _changeMemberRole(int index, String role) async {
    setState(() {
      _isMemberInfoLoading = index;
    });
    int userID =
        await LocalDatabase.getUserId(groupInfo["members"][index]["name"]);
    Map<String, dynamic> response =
        await API.changeRole(widget.group.id, userID, role);
    if (response["success"] == true) {
      await LocalDatabase.changeRole(widget.group.id, userID, role);
      setState(() {
        groupInfo["members"][index]["role"] = role;
        _isMemberInfoLoading = -1;
      });
    }
  }

  Future<void> _kickMember(int index) async {
    // await LocalDatabase.kickMember(
    //     widget.group.id, groupInfo["members"][index]["id"]);
    // setState(() {
    //   groupInfo["members"].removeAt(index);
    // });
    setState(() {
      _isMemberInfoLoading = index;
    });
    int userID =
        await LocalDatabase.getUserId(groupInfo["members"][index]["name"]);
    Map<String, dynamic> response = await API.kickUser(widget.group.id, userID);
    if (response["success"] == true) {
      await LocalDatabase.kickUser(widget.group.id, userID);
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
        title: Text(widget.group.name),
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
                        title: Text(groupInfo["members"][index]["name"]),
                        trailing: groupInfo["isAdmin"]
                            ? _isMemberInfoLoading == index
                                ? const CircularProgressIndicator()
                                : _isMemberInfoLoading != -1
                                    ? null
                                    : PopupMenuButton<String>(
                                        onSelected: (String value) {
                                          // change member role
                                          // setState(() {
                                          //   if (value == "Make admin") {
                                          //     groupInfo["members"].insert(
                                          //         0, groupInfo["members"].removeAt(index));
                                          //   } else {
                                          //     groupInfo["members"].add(groupInfo["members"].removeAt(index));
                                          //   }
                                          // });
                                          if (value == "Make admin") {
                                            _changeMemberRole(index, "admin");
                                          } else if (value == "Make member") {
                                            _changeMemberRole(index, "member");
                                          } else {
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
                        subtitle: Text(groupInfo["members"][index]["role"]),
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
                    groupInfo["description"],
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
