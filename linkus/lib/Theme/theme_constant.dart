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
  Color gradientStart = Colors.white;
  Color gradientEnd = Colors.white;
}

class CustomTheme{
  static CustomColorScheme lightThemeColorScheme = CustomColorScheme()
  ..primary = const Color(0xFF2A2F4F)
  ..secondary = const Color(0xFFE8175D)
  ..onPrimary = const Color(0xFFCC527A)
  ..onSecondary = const Color(0xFFA8A7A7)
  ..primaryVariant = const Color(0xFFFC913A)
  ..secondaryVariant = const Color(0xFFA84448)
  ..gradientStart = const Color(0xFF547980)
  ..gradientEnd = const Color(0xFF2F9599 )
  ..background = const Color(0xFFF6E1C3)
  ..onBackground = const Color(0xFF355C7D);


  static CustomColorScheme darkThemeColorScheme = CustomColorScheme()
  ..primary = const Color(0xFF2A2F4F)
  ..secondary = const Color(0xFFE8175D)
  ..onPrimary = const Color(0xFFCC527A)
  ..onSecondary = const Color(0xFFA8A7A7)
  ..primaryVariant = const Color(0xFFFC913A)
  ..secondaryVariant = const Color(0xFFA84448)
  ..gradientStart = const Color(0xFF547980)
  ..gradientEnd = const Color(0xFF2F9599 )
  ..background = const Color(0xFFF6E1C3)
  ..onBackground = const Color(0xFF355C7D);

  static CustomColorScheme of(BuildContext context){
    return Theme.of(context).brightness == Brightness.light ? lightThemeColorScheme : darkThemeColorScheme;
  }
}