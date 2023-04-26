import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Theme/theme_constant.dart';
import 'package:linkus/create_group_popup.dart';
import 'package:linkus/home.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  User? user;
  bool _isLoading = true;

  _showAddMembersPopUp() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return CreateGroupPopup(user: user!);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUser().then((user) {
      if (user != null) {
        LocalDatabase.setupLocalDatabase(user.userId);
        setState(() {
          this.user = user;
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
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                CustomTheme.of(context).gradientStart,
                CustomTheme.of(context).gradientEnd,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            child: _isLoading
                ? const Loading()
                : Stack(
                    children: [
                      HomePage(user: user!),
                    ],
                  )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddMembersPopUp();
          },
          backgroundColor: CustomTheme.of(context).secondary,
          child: Icon(Icons.group, color: CustomTheme.of(context).onSecondary),
        ));
  }
}
