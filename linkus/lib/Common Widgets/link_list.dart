import 'package:flutter/material.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/link.dart';

class LinkList extends StatefulWidget {
  final List<ShortLink> links;
  const LinkList({super.key, required this.links});

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
