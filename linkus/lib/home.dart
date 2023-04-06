import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/group.dart';

class HompePage extends StatefulWidget {
  final String username;
  const HompePage({super.key, required this.username});

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
    final fetchedGroups = await fetchGroups();
    setState(() {
      groups = fetchedGroups;
      _areGroupsLoading = false;
    });
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
              "Hello, ${widget.username}!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
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
                : ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return GestureDetector(
                        onTap: () {
                          // Replace with navigation to group page
                          print("Navigating to group ${group.name}");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GroupPage(groupId: index)));
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(group.name),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
