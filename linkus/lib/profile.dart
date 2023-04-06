import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/link_list.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Helper%20Files/db.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
  List<Link> bookmarks = [];
  bool _isUserInfoLoading = true;
  bool _isBookmarksLoading = true;

  // Fetch bookmarks from API
  Future<void> loadBookmarks() async {
    final response = await LocalDatabase.fetchBookmarks();
    setState(() {
      bookmarks = response;
      _isBookmarksLoading = false;
    });
  }

  // Get user information from shared preferences
  Future<void> loadUserInfo() async {
    final userInfo = await getUserInfo();
    setState(() {
      username = userInfo["username"];
      email = userInfo["email"];
      _isUserInfoLoading = false;
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
    loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isBookmarksLoading || _isUserInfoLoading
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
                  username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: LinkList(links: bookmarks),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement logout functionality
                    logout();
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
    );
  }
}
