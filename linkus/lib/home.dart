import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/group.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'dart:convert';

class HompePage extends StatefulWidget {
  final User user;
  const HompePage({super.key, required this.user});

  @override
  State<HompePage> createState() => _HompePageState();
}

class _HompePageState extends State<HompePage> {
  List<Group> groups = [];
  bool _areGroupsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final fetchedGroups = await LocalDatabase.fetchGroups();
    setState(() {
      groups = fetchedGroups;
      _areGroupsLoading = false;
    });
  }

  Future<void> _refresh() async {
    // get userid and last updated time
    final String userId = widget.user.userId;
    final DateTime lastFetched = await getLastFetched();
    // fetch updates from server
    final Map<String, dynamic> updates =
        await API.getUpdates(lastFetched, userId);
    print(updates);
    try {
      // Cast List<dynamic> to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> newMessages = updates['new_messages']
          .map<Map<String, dynamic>>(
              (message) => message as Map<String, dynamic>)
          .toList();
      final List<Map<String, dynamic>> deleteMessages =
          updates['delete_messages']
              .map<Map<String, dynamic>>(
                  (message) => message as Map<String, dynamic>)
              .toList();
      final List<Map<String, dynamic>> react = updates['react']
          .map<Map<String, dynamic>>(
              (message) => message as Map<String, dynamic>)
          .toList();
      final List<Map<String, dynamic>> changeRole = updates['change_role']
          .map<Map<String, dynamic>>(
              (message) => message as Map<String, dynamic>)
          .toList();
      final List<Map<String, dynamic>> removeMember = updates['remove_member']
          .map<Map<String, dynamic>>(
              (message) => message as Map<String, dynamic>)
          .toList();
      final List<Map<String, dynamic>> addUser = updates['add_user']
          .map<Map<String, dynamic>>(
              (message) => message as Map<String, dynamic>)
          .toList();
      final List<Map<String, dynamic>> getAdded = updates['get_added']
          .map<Map<String, dynamic>>(
              (message) => message as Map<String, dynamic>)
          .toList();
      // // // Modify the Jsons
      // List<Map<String, dynamic>> changeRoleActions = [];

      // for (Map<String, dynamic> changeRoleAction in changeRole) {
      //   Map<String, dynamic> newChangeRoleAction = {};
      //   newChangeRoleAction['userId'] = changeRoleAction['affectedId'];
      //   newChangeRoleAction['groupId'] = changeRoleAction['groupId'];
      //   newChangeRoleAction['role'] = changeRoleAction['affectedRole'] == 'adm'
      //       ? GroupRole.admin
      //       : changeRoleAction['affectedRole'] == 'mem'
      //           ? GroupRole.member
      //           : null;
      //   changeRoleActions.add(newChangeRoleAction);
      // }

      // // update local database
      // await LocalDatabase.updateMessages(newMessages);
      // await LocalDatabase.deleteMessages(deleteMessages);
      // await LocalDatabase.updateReactions(react);
      // await LocalDatabase.updateRoles(changeRoleActions);
      // await LocalDatabase.removeMembers(removeMember);
      // await LocalDatabase.addUsers(addUser);
      // await LocalDatabase.getAdded(getAdded);
      // // update last fetched time
      await setLastFetched(DateTime.parse(updates['time_stamp']));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Hello, ${widget.user.username}!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(onPressed: _refresh, child: const Text("Refresh")),
          const Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for groups...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _areGroupsLoading
                ? const Loading()
                : Container(
                    color: Colors.grey[200],
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return GestureDetector(
                          onTap: () {
                            // Replace with navigation to group page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupPage(group: group),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                                4.0), // reduce padding around card
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    8), // reduce padding inside card
                                child: Text(
                                  group.groupName,
                                  style: const TextStyle(
                                      fontSize: 14), // reduce font size
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
