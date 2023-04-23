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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
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
          ),
        ],
      ),
      body: _areLinksLoading
          ? const Loading()
          : LinkList(links: _links, user: widget.user),
      floatingActionButton: _isMember
          ? FloatingActionButton(
              onPressed: showNewMessagePopUp,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
