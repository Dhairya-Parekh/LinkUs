import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/home.dart';
import 'package:linkus/profile.dart';
import 'package:linkus/create_group.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;
  User? user;
  List<Widget> _tabs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUser().then((user) {
      if (user != null) {
        LocalDatabase.setupLocalDatabase(user.userId);
        setState(() {
          this.user = user;
          _tabs = [
            HomePage(user: user),
            CreateGroupPage(user: user),
            ProfilePage(user: user),
          ];
          _isLoading = false;
        });
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.group),
            label: 'Create Group',
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
