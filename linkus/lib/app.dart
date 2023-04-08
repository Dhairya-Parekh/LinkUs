import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/home.dart';
import 'package:linkus/profile.dart';
import 'package:linkus/createGroup.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;
  String username = "user";
  List<Widget> _tabs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUsername().then((username) {
      if (username != null) {
        setState(() {
          this.username = username;
          _tabs = [
            HompePage(username: username),
            CreateGroupPage(username: username),
            const ProfilePage(),
          ];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App $username'),
      ),
      body: _isLoading ? const Loading() : _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

