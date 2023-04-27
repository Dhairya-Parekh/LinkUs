import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/bookmark_list.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Theme/theme_constant.dart';
import 'dart:math';

class ProfilePage extends StatelessWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  Future<void> logout(BuildContext context) async {
    await removeCredentials().then((value) {
      LocalDatabase.closeLocalDatabase();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/welcome', (route) => false);
    });
  }

  // @override
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
        tileMode: TileMode.clamp,
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          CircleAvatar(
            radius: 50,
            backgroundImage:
                AssetImage('assets/images/${Random().nextInt(8) + 1}.png'),
          ),
          const SizedBox(height: 20),
          Text(
            user.username,
            style: TextStyle(
              color: CustomTheme.of(context).onBackground,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.email,
            style: TextStyle(
              color: CustomTheme.of(context).onBackground,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () {
                logout(context);
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: CustomTheme.of(context).error,
                  foregroundColor: CustomTheme.of(context).white,
                  minimumSize: const Size(200, 40)),
              child: const Text('Logout')),
          const SizedBox(height: 20),
          Expanded(
            child: BookmarkList(
              user: user,
            ),
          ),
        ],
      ),
    ));
  }
}
