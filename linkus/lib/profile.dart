import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/link_list.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Helper%20Files/db.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  //Logout
  Future<void> logout() async {
    await removeCredentials().then((value) {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isBookmarksLoading
          ? const Loading()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/150?img=3'),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.user.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: LinkList(links: bookmarks),
                ),
                ElevatedButton(
                  onPressed: logout,
                  child: const Text('Logout'),
                ),
              ],
            ),
    );
  }
}
