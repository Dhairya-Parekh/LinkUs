import 'package:flutter/material.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/link.dart';

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
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessagePage(
                  title: message.title,
                  description: message.description,
                  sender: message.sender,
                  likes: message.likes,
                  dislikes: message.dislikes,
                  link: message.link,
                  timestamp: message.time,
                ),
              ),
            );
          },
          child: ListTile(
            title: Text(message.sender),
            subtitle: Text(message.title),
            trailing: Text(message.time.toString()),
          ),
        );
      },
    );
  }
}
