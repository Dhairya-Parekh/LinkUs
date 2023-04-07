import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';

class GroupInfoPage extends StatefulWidget {
  final Group group;
  const GroupInfoPage({super.key, required this.group});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> { // group description
  Map<String, dynamic> groupInfo = {};
  bool _isGroupInfoLoading = true;

  Future<void> _loadGroupInfo() async {
    final info = await LocalDatabase.getGroupInfo(widget.group.id);
    setState(() {
      groupInfo = info;
      _isGroupInfoLoading = false;
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
                            ? PopupMenuButton<String>(
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
                                },
                                itemBuilder: (BuildContext context) {
                                  return groupInfo["isAdmin"]
                                      ? <PopupMenuEntry<String>>[
                                          const PopupMenuItem<String>(
                                            value: "Make member",
                                            child: Text("Make member"),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: "Make admin",
                                            child: Text("Make admin"),
                                          ),
                                        ]
                                      : <PopupMenuEntry<String>>[
                                          const PopupMenuItem<String>(
                                            value: "Leave group",
                                            child: Text("Leave group"),
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
              ],
            ),
    );
  }
}
