import 'package:flutter/material.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/link.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import '../Helper Files/api.dart';

class LinkList extends StatefulWidget {
  final List<Link> links;
  final User user;
  final String groupId;
  const LinkList(
      {super.key,
      required this.links,
      required this.user,
      required this.groupId});

  @override
  State<LinkList> createState() => _LinkListState();
}

class _LinkListState extends State<LinkList> {
  void _showOptions(BuildContext context, Link link) async {
    final canDeleteGlobal = await _canDeleteGlobal(link);
    List<Widget> options = [];
    options.add(
      ListTile(
        leading: Icon(Icons.delete),
        title: Text("Delete for me"),
        onTap: () {
          _deleteLocal(link);
          Navigator.pop(context, "delete_for_me");
        },
      ),
    );
    if (canDeleteGlobal) {
      options.add(
        ListTile(
          leading: Icon(Icons.delete_forever),
          title: Text("Delete for everyone"),
          onTap: () {
            _deleteGlobal(link);
            Navigator.pop(context, "delete_for_everyone");
          },
        ),
      );
    }
    options.add(
      ListTile(
        leading: Icon(Icons.forward),
        title: Text("Forward"),
        onTap: () {
          // _forwardLink(link);
          Navigator.pop(context, "forward");
        },
      ),
    );
    final result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options,
          ),
        );
      },
    );
  }

  Future<bool> _canDeleteGlobal(Link link) async {
    if (link.senderName == widget.user.username ||
        await LocalDatabase.isGroupAdmin(widget.user.userId, widget.groupId)) {
      return true;
    }
    return false;
  }

  Future<void> _deleteLocal(Link link) async {
    await LocalDatabase.deleteLink(link);
    setState(() {
      widget.links.remove(link);
    });
  }

  Future<void> _deleteGlobal(Link link) async {
    final Map<String, dynamic> response = await API.broadcastDelete(
      widget.user.userId,
      link.linkId,
      widget.groupId,
    );
    if (response["success"]) {
      await _deleteLocal(link);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.links.length,
      itemBuilder: (BuildContext context, int index) {
        Link message = widget.links[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LinkPage(linkId: message.linkId, user: widget.user),
              ),
            );
          },
          onLongPress: () {
            _showOptions(context, message);
          },
          child: ListTile(
            title: Text(message.senderName),
            subtitle: Text(message.title),
            trailing: Text(message.timeStamp.toString()),
          ),
        );
      },
    );
  }
}
