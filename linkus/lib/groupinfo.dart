import 'package:flutter/material.dart';

class GroupInfoPage extends StatefulWidget {
  const GroupInfoPage({super.key});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  bool isAdmin = false; // assuming the current user is an admin
  List<String> members = [
    "John Doe",
    "Jane Doe",
    "Alice Smith",
    "Bob Johnson",
  ]; // list of members
  final String description =
      "This is a group for discussing Flutter development."; // group description

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Info"),
      ),
      body: Column(
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
              itemCount: members.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(members[index]),
                  trailing: isAdmin
                ? PopupMenuButton<String>(
                    onSelected: (String value) {
                      // change member role
                      setState(() {
                        if (value == "Make admin") {
                          members.insert(0, members.removeAt(index));
                        } else {
                          members.add(members.removeAt(index));
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return isAdmin
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
              description,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
