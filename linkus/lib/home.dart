import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/db.dart';

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
      // appBar: AppBar(
      //   title: const Text("Home"),
      // ),
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
          _areGroupsLoading
              ? const Loading()
              : Expanded(
                  child: ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return GestureDetector(
                        onTap: () {
                          // Replace with navigation to group page
                          print("Navigating to group ${group.name}");
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
