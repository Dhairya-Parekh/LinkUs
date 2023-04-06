import 'package:flutter/material.dart';
import 'package:linkus/Helper%20Files/db.dart';

class LinkList extends StatefulWidget {
  final List<Link> links;
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
        Link message = widget.links[index];
        return ListTile(
          title: Text(message.sender),
          subtitle: Text(message.title),
          trailing: Text(message.time.toString()),
        );
      },
    );
  }
}
