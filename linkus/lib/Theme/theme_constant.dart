import 'package:flutter/material.dart';

class CustomColorScheme{
  Color primary = Colors.white;
  Color onPrimary = Colors.white;
  Color primaryVariant = Colors.white;
  Color secondary = Colors.white;
  Color onSecondary = Colors.white;
  Color secondaryVariant = Colors.white;
  Color background = Colors.white;
  Color onBackground = Colors.white;
  Color error = Colors.red;
  Color success = Colors.green;
  Color warning = Colors.yellow;
}

class CustomTheme{
  static CustomColorScheme lightThemeColorScheme = CustomColorScheme()
  ..primary = const Color(0xFF2A2F4F)
  ..secondary = const Color(0xFF917FB3)
  ..onPrimary = const Color(0xFFFDE2F3)
  ..onSecondary = const Color(0xFFE5BEEC)
  ..primaryVariant = const Color(0xFF7A3E65)
  ..secondaryVariant = const Color(0xFFA84448)
  ..background = const Color(0xFFF6E1C3)
  ..onBackground = const Color(0xFFE9A178);


  static CustomColorScheme darkThemeColorScheme = CustomColorScheme()
  ..primary = const Color(0xFF2A2F4F)
  ..secondary = const Color(0xFF917FB3)
  ..onPrimary = const Color(0xFFFDE2F3)
  ..onSecondary = const Color(0xFFE5BEEC)
  ..primaryVariant = const Color(0xFF7A3E65)
  ..secondaryVariant = const Color(0xFFA84448)
  ..background = const Color(0xFFF6E1C3)
  ..onBackground = const Color(0xFFE9A178);

  static CustomColorScheme of(BuildContext context){
    return Theme.of(context).brightness == Brightness.light ? lightThemeColorScheme : darkThemeColorScheme;
  }
}