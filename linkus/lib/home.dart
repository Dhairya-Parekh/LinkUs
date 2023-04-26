import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Theme/theme_constant.dart';
import 'package:linkus/group.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/profile.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Group> groups = [];
  bool _areGroupsLoading = true;
  List<Group> _searchedGroups = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final fetchedGroups = await LocalDatabase.fetchGroups();
    setState(() {
      groups = fetchedGroups;
      _searchedGroups = fetchedGroups;
      _areGroupsLoading = false;
    });
  }

  void _searchGroups(String query) {
    if(query.isEmpty){
      setState(() {
        _searchedGroups = groups;
      });
    } else {
      setState(() {
        _searchedGroups = groups
            .where((group) =>
                group.groupName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _areGroupsLoading = true;
    });
    // get userid and last updated time
    final String userId = widget.user.userId;
    final DateTime lastFetched = await getLastFetched(userId);
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
      List<Map<String, dynamic>> changeRoleActions = [];

      for (Map<String, dynamic> changeRoleAction in changeRole) {
        Map<String, dynamic> newChangeRoleAction = {};
        newChangeRoleAction['user_id'] = changeRoleAction['affected_id'];
        newChangeRoleAction['group_id'] = changeRoleAction['group_id'];
        newChangeRoleAction['role'] = changeRoleAction['affected_role'] == 'adm'
            ? GroupRole.admin
            : changeRoleAction['affected_role'] == 'mem'
                ? GroupRole.member
                : null;
        changeRoleActions.add(newChangeRoleAction);
      }

      // // update local database
      await LocalDatabase.getAdded(getAdded);
      // await LocalDatabase.addUsers(addUser);
      await LocalDatabase.removeMembers(removeMember);
      await LocalDatabase.updateRoles(changeRoleActions);
      await LocalDatabase.updateMessages(newMessages);
      // await LocalDatabase.deleteMessages(deleteMessages);
      await LocalDatabase.updateReactions(react);
      // // update last fetched time
      await setLastFetched(userId, DateTime.parse(updates['time_stamp']));
      // // reload groups
      await _loadGroups();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Hello",
                            style: TextStyle(
                                fontSize: 25,
                                color: CustomTheme.of(context).onSecondary)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePage(user: widget.user)));
                          },
                          child: Text("@${widget.user.username}",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: CustomTheme.of(context).onPrimary)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                          color: CustomTheme.of(context).secondary,
                          shape: BoxShape.circle),
                      child: IconButton(
                        onPressed: _refresh,
                        icon: Icon(
                          Icons.refresh,
                          color: CustomTheme.of(context).onSecondary,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: CustomTheme.of(context).secondary,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: TextField(
                      onChanged: _searchGroups,
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search topics',
                        hintStyle: TextStyle(
                          color: CustomTheme.of(context).onSecondary,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: CustomTheme.of(context).onSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _areGroupsLoading
                    ? const Loading()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _searchedGroups.isEmpty ? Center(
                          child: Text("No groups found",
                            style: TextStyle(
                              fontSize: 20,
                              color: CustomTheme.of(context).onSecondary
                            )
                          ),
                        )
                        : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _searchedGroups.length,
                          itemBuilder: (context, index) {
                            final group = _searchedGroups[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupPage(
                                      group: group,
                                      user: widget.user,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: CustomTheme.of(context).primary,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        group.groupName,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color:
                                              CustomTheme.of(context).onPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              )
            ],
          ),
        ));
  }
}
