import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagePage extends StatelessWidget {
  final String title;
  final String description;
  final String sender;
  final int likes;
  final int dislikes;
  final String link;
  final DateTime timestamp;

  const MessagePage({super.key, 
    required this.title,
    required this.description,
    required this.sender,
    required this.likes,
    required this.dislikes,
    required this.link,
    required this.timestamp,
  });

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
      body: Column(
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
