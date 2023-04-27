import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Theme/theme_constant.dart';
import 'package:linkus/link_popup.dart';

class BookmarkList extends StatefulWidget {
  final User user;
  const BookmarkList({super.key, required this.user});

  @override
  State<BookmarkList> createState() => _BookmarkListState();
}

class _BookmarkListState extends State<BookmarkList> {
  List<ShortLink> bookmarks = [];
  bool _isBookmarksLoading = true;

  // Fetch bookmarks from API
  Future<void> loadBookmarks() async {
    final response = await LocalDatabase.fetchBookmarks();
    setState(() {
      bookmarks = response;
      _isBookmarksLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  showLinkPopUp(String linkId, User user) async {
    await showModalBottomSheet(
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
    setState(() {
      _isBookmarksLoading = true;
    });
    loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return _isBookmarksLoading
        ? const Loading()
        : bookmarks.isEmpty
            ? Center(
                child: Text(
                  'No Bookmarks Found',
                  style: TextStyle(
                    color: CustomTheme.of(context).onBackground,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  ShortLink link = bookmarks[index];
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
                        )),
                  );
                },
              );
  }
}
