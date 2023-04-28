import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Theme/theme_constant.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPopUp extends StatefulWidget {
  final User user;
  final String linkId;
  const LinkPopUp({super.key, required this.user, required this.linkId});

  @override
  State<LinkPopUp> createState() => _LinkPopUpState();
}

class _LinkPopUpState extends State<LinkPopUp> {
  bool _isLoading = true;
  Map<String, dynamic> linkInfosys = {};
  Link linkInfo = Link(
    linkId: "",
    link: "",
    senderName: "",
    title: "",
    timeStamp: DateTime.now(),
    info: "",
    tags: [],
    likes: 0,
    dislikes: 0,
    hasLiked: false,
    hasDisliked: false,
    hasBookmarked: false,
  );

  Future<void> loadLink() async {
    final response =
        await LocalDatabase.getLinkInfo(widget.linkId);
    setState(() {
      _isLoading = false;
      linkInfosys = response;
      linkInfo = Link(
        linkId: widget.linkId,
        link: response['link'],
        senderName: response['senderName'],
        title: response['title'],
        timeStamp: response['timeStamp'],
        info: response['info'],
        tags: response['tags'],
        likes: response['likes'],
        dislikes: response['dislikes'],
        hasLiked: response['hasLiked'],
        hasDisliked: response['hasDisliked'],
        hasBookmarked: response['hasBookmarked'],
        groupId: response['groupId'],
      );
    });
  }

  void _launchURL() async {
    await canLaunchUrl(Uri.parse(linkInfo.link)).then(
      (value) async {
        if (value) {
          await launchUrl(Uri.parse(linkInfo.link));
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Error"),
                  content: const Text(
                      "Invalid URL. Please ask the sender to resend the link."),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("OK"))
                  ],
                );
              });
        }
      },
    );
  }

  void _toggleBookmark() async {
    if (linkInfo.hasBookmarked) {
      await LocalDatabase.updateBookmarks(widget.linkId, "unbookmark");
    } else {
      await LocalDatabase.updateBookmarks(widget.linkId, "bookmark");
    }
    setState(() {
      linkInfo.hasBookmarked = !linkInfo.hasBookmarked;
    });
  }

  void _toggleLike() async {
    final reactChar = linkInfo.hasLiked ? "n" : "l";
    try {
      await API.broadcastReact(
          widget.user.userId, widget.linkId, linkInfo.groupId!, reactChar);
      await LocalDatabase.updateReactions([
        {
          "link_id": widget.linkId,
          "react": reactChar,
          "sender_id": widget.user.userId,
        }
      ]);
      setState(() {
        if (linkInfo.hasLiked) {
          linkInfo.likes--;
        } else {
          linkInfo.likes++;
          if (linkInfo.hasDisliked) {
            linkInfo.dislikes--;
          }
        }
        linkInfo.hasLiked = !linkInfo.hasLiked;
        linkInfo.hasDisliked = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'An error occurred while broadcasting the react. Check your internet connection and try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _toggleDislike() async {
    final reactChar = linkInfo.hasDisliked ? "n" : "d";
    try {
      await API.broadcastReact(
          widget.user.userId, widget.linkId, linkInfo.groupId!, reactChar);
      await LocalDatabase.updateReactions([
        {
          "link_id": widget.linkId,
          "react": reactChar,
          "sender_id": widget.user.userId,
        }
      ]);
      setState(() {
        if (linkInfo.hasDisliked) {
          linkInfo.dislikes--;
        } else {
          linkInfo.dislikes++;
          if (linkInfo.hasLiked) {
            linkInfo.likes--;
          }
        }
        linkInfo.hasDisliked = !linkInfo.hasDisliked;
        linkInfo.hasLiked = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'An error occurred while broadcasting the react. Check your internet connection and try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadLink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.of(context).primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: _isLoading
          ? const Loading()
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    Text(
                      linkInfo.title,
                      style: TextStyle(
                        color: CustomTheme.of(context).primaryVariant,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          linkInfo.senderName,
                          style: TextStyle(
                            color: CustomTheme.of(context).onPrimary,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat("h:mm a, dd MMMM")
                              .format(linkInfo.timeStamp.toLocal()),
                          style: TextStyle(
                            color: CustomTheme.of(context).onPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var tag in linkInfo.tags)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: CustomTheme.of(context).secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color:
                                          CustomTheme.of(context).onSecondary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          linkInfo.info,
                          style: TextStyle(
                            color: CustomTheme.of(context).onPrimary,
                            fontSize: 15,
                          ),
                        )),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    TextButton(
                        onPressed: _launchURL,
                        child: Text(
                          linkInfo.link,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 15,
                          ),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: _toggleLike,
                              icon: linkInfo.hasLiked
                                  ? const Icon(Icons.thumb_up_alt)
                                  : const Icon(Icons.thumb_up_alt_outlined),
                            ),
                            Text(linkInfo.likes.toString()),
                          ],
                        ),
                        IconButton(
                          onPressed: _toggleBookmark,
                          icon: linkInfo.hasBookmarked
                              ? const Icon(Icons.bookmark)
                              : const Icon(Icons.bookmark_border),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _toggleDislike,
                              icon: linkInfo.hasDisliked
                                  ? const Icon(Icons.thumb_down_alt)
                                  : const Icon(Icons.thumb_down_alt_outlined),
                            ),
                            Text(linkInfo.dislikes.toString()),
                          ],
                        )
                      ],
                    )
                  ]),
                )
              ],
            ),
    );
  }
}
