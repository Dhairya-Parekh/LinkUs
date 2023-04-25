import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/link_list.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/groupinfo.dart';
import 'package:linkus/message_popup.dart';

class GroupPage extends StatefulWidget {
  final Group group;
  final User user;
  const GroupPage({super.key, required this.group, required this.user});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<ShortLink> _links = [];
  bool _areLinksLoading = true;
  bool _isMember = true;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLinks() async {
    final links = await LocalDatabase.fetchLinks(widget.group.groupId);
    final uinfo = await LocalDatabase.getGroupSpecificUserInfo(
        widget.user.userId, widget.group.groupId);
    setState(() {
      _links = links;
      _areLinksLoading = false;
      _isMember = uinfo["isMember"];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> showNewMessagePopUp() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return MessagePopUp(groupId: widget.group.groupId, user: widget.user);
      },
    );

    if (result == true) {
      // Reload the data
      setState(() {
        _areLinksLoading = true;
      });
      await _loadLinks();
    }
  }

  void showSortOptionsPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Time'),
                onTap: () {
                  // Handle sort by time
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Sort by Reacts'),
                onTap: () {
                  // Handle sort by reaction
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // navigate to group info page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupInfoPage(
                  group: widget.group,
                  user: widget.user,
                ),
              ),
            );
          },
          child: Text(widget.group.groupName),
        ),
        leading: Visibility(
          visible: !_showSearchBar,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          Visibility(
            visible: !_showSearchBar,
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                switch (result) {
                  case 'search':
                    setState(() {
                      _showSearchBar = true;
                    });
                    break;
                  case 'sort':
                    // handle sort action
                    showSortOptionsPopUp();
                    break;
                  case 'filter':
                    // handle filter action
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'search',
                  child: Text('Search'),
                ),
                PopupMenuItem<String>(
                  value: 'sort',
                  child: Text('Sort'),
                ),
                PopupMenuItem<String>(
                  value: 'filter',
                  child: Text('Filter'),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _showSearchBar,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 30)),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Icon(Icons.clear),
                      onTap: () {
                        setState(() {
                          _showSearchBar = false;
                          _searchController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _areLinksLoading
          ? const Loading()
          : LinkList(
              links: _links, user: widget.user, groupId: widget.group.groupId),
      floatingActionButton: _isMember
          ? FloatingActionButton(
              onPressed: showNewMessagePopUp,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
