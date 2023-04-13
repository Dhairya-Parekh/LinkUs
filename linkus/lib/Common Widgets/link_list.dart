import 'package:flutter/material.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/link.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';


class LinkList extends StatefulWidget {
  final List<ShortLink> links;
  final User user;
  const LinkList(
      {super.key,
      required this.links,
      required this.user});

  @override
  State<LinkList> createState() => _LinkListState();
}

class _LinkListState extends State<LinkList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.links.length,
      itemBuilder: (BuildContext context, int index) {
        ShortLink message = widget.links[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LinkPage(
                  linkId: message.linkId,
                  user: widget.user
                ),
              ),
            );
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
