import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';

enum React { like, dislike }

class LinkPage extends StatefulWidget {
  final String linkId;
  final User user;
  const LinkPage({super.key, required this.linkId, required this.user});

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
  bool hasLiked = false;
  bool hasDisliked = false;
  // ignore: prefer_typing_uninitialized_variables
  late final tags;
  // ignore: prefer_typing_uninitialized_variables

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
      tags = linkInfo["tags"];
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

  void _pressReactButton(React react) async {
    final react_char = (react == React.like)
        ? (hasLiked ? 'n' : 'l')
        : (hasDisliked ? 'n' : 'd');

    final linkInfo = await LocalDatabase.getLinkInfo(widget.linkId);
    final jsonResponse = await API.broadcastReact(
        linkInfo["senderId"], widget.linkId, linkInfo["groupId"], react_char);

    Map<String, dynamic> reaction = {
      'user_id': widget.user.userId,
      'link_id': widget.linkId,
      'react': react_char
    };

    List<Map<String, dynamic>> newReactions = [reaction];
    LocalDatabase.updateReactions(newReactions);

    setState(() {
      if (react == React.like) {
        hasLiked = react_char == 'l';
        hasDisliked = (react_char == 'n') ? hasDisliked : false;
      } else {
        hasDisliked = react_char == 'd';
        hasLiked = (react_char == 'n') ? hasLiked : false;
      }
    });

    await _loadLinkInfo();
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
                        onPressed: () async {
                          _pressReactButton(React.like);
                        },
                        icon: const Icon(Icons.thumb_up),
                        label: Text(likes.toString()),
                      ),
                      const SizedBox(width: 8.0),
                      TextButton.icon(
                        onPressed: () async {
                          _pressReactButton(React.dislike);
                        },
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
                // Added tags to the widget tree
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: tags.map<Widget>((item) {
                      return Chip(
                        label: Text(
                          item.toString(),
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        backgroundColor: Colors.grey[300],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
