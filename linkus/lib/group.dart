import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/link_list.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/groupinfo.dart';
import 'package:linkus/message_popup.dart';

class GroupPage extends StatefulWidget {
  final Group group;
  const GroupPage({super.key, required this.group});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {

  List<Link> _links = [];
  bool _areLinksLoading = true;

  Future<void> _loadLinks() async {
    final links = await LocalDatabase.fetchLinks(widget.group.id);
    setState(() {
      _links = links;
      _areLinksLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> showpopup() async {
    return showDialog(
      context: context,
      builder: (context) {
        return MessagePopUp(groupId: widget.group.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat'),
        actions: [
          IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                // navigate to group info page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupInfoPage(group: widget.group)),
                );
              }),
        ],
      ),
      body: _areLinksLoading ? const Loading() : LinkList(links: _links),
      floatingActionButton: FloatingActionButton(
        onPressed: showpopup,
        child: const Icon(Icons.add),
      ),
    );
  }
}
