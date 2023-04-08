import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPage extends StatefulWidget {
  final String linkId;
  const LinkPage({super.key, required this.linkId});

  @override
  State<LinkPage> createState() => _LinkPageState();
}

class _LinkPageState extends State<LinkPage> {
  String title = "";
  String description = "";
  String sender = "";
  int likes = 0;
  int dislikes = 0;
  String link = "";
  DateTime timestamp = DateTime.now();
  bool isLoading = true;

  Future<void> _loadLinkInfo() async {
    final linkInfo = await LocalDatabase.getLinkInfo(widget.linkId);
    setState(() {
      title = linkInfo["title"];
      description = linkInfo["info"];
      sender = linkInfo["senderName"];
      likes = linkInfo["likes"];
      dislikes = linkInfo["dislikes"];
      link = linkInfo["link"];
      timestamp = linkInfo["timeStamp"];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLinkInfo();
  }

  void _launchURL() async {
    if (await canLaunchUrl(Uri.parse(link))) {
      await launchUrl(Uri.parse(link));
    } else {
      throw 'Could not launch $link';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message'),
      ),
      body: isLoading
          ? const Loading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'From: $sender',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_up),
                        label: Text(likes.toString()),
                      ),
                      const SizedBox(width: 8.0),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_down),
                        label: Text(dislikes.toString()),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Sent on: ${timestamp.toString()}',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _launchURL,
                    child: Text(
                      link,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
