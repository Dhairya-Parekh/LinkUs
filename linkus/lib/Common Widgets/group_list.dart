import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Theme/theme_constant.dart';
import 'package:linkus/link_popup.dart';

class GroupMessageList extends StatefulWidget {
  final User user;
  final List<Link> links;
  final String groupId;
  const GroupMessageList(
      {super.key,
      required this.user,
      required this.links,
      required this.groupId});

  @override
  State<GroupMessageList> createState() => _GroupMessageListState();
}

class _GroupMessageListState extends State<GroupMessageList> {
  void _showOptions(BuildContext context, Link link) async {
    final canDeleteGlobal = await _canDeleteGlobal(link);
    List<Widget> options = [];
    options.add(
      ListTile(
        leading: const Icon(Icons.delete),
        title: const Text("Delete for me"),
        onTap: () {
          _deleteLocal(link);
          Navigator.pop(context, "delete_for_me");
        },
      ),
    );
    if (canDeleteGlobal) {
      options.add(
        ListTile(
          leading: const Icon(Icons.delete_forever),
          title: const Text("Delete for everyone"),
          onTap: () {
            _deleteGlobal(link);
            Navigator.pop(context, "delete_for_everyone");
          },
        ),
      );
    }
    options.add(
      ListTile(
        leading: const Icon(Icons.forward),
        title: const Text("Forward"),
        onTap: () {
          // _forwardLink(link);
          Navigator.pop(context, "forward");
        },
      ),
    );
    // ignore: use_build_context_synchronously
    await showModalBottomSheet(
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

  showLinkPopUp(String linkId, User user) async {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (context) {
          return LinkPopUp(user: user, linkId: linkId);
        });
  }

  @override
  Widget build(BuildContext context) {
    return widget.links.isEmpty
        ? Center(
            child: Text(
              'No Links Found',
              style: TextStyle(
                color: CustomTheme.of(context).onBackground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : ListView.builder(
            itemCount: widget.links.length,
            itemBuilder: (context, index) {
              Link link = widget.links[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showLinkPopUp(link.linkId, widget.user);
                      },
                      onLongPress: () {
                        _showOptions(context, link);
                      },
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CustomTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    link.title,
                                    style: TextStyle(
                                      color: CustomTheme.of(context)
                                          .primaryVariant,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat("dd MMMM")
                                        .format(link.timeStamp.toLocal()),
                                    style: TextStyle(
                                      color:
                                          CustomTheme.of(context).onPrimary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    link.senderName,
                                    style: TextStyle(
                                      color:
                                          CustomTheme.of(context).onPrimary,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat("h:mm a")
                                        .format(link.timeStamp.toLocal()),
                                    style: TextStyle(
                                      color:
                                          CustomTheme.of(context).onPrimary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    )
                  ),
              );
            },
          );
  }
}
