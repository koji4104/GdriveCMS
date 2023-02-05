import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

/// Radius 6.0
const DEFAULT_RADIUS = 6.0;

ThemeData myTheme = myDarkTheme;

/// e.g.
/// - myTheme.backgroundColor
/// - myTheme.cardColor
/// - myTheme.textTheme.bodyMedium (size 14)
/// - myTheme.textTheme.titleMedium (size 16)
ThemeData myDarkTheme = ThemeData.dark().copyWith(
  pageTransitionsTheme: MyPageTransitionsTheme(),
  backgroundColor: Color(0xFF000000),
  scaffoldBackgroundColor: Color(0xFF000000),
  //canvasColor: Color(0xFF000000),
  cardColor: Color(0xFF333333),
  primaryColor: Color(0xFF222230),
  dividerColor: Color(0xFF555555),
  selectedRowColor: Color(0xFF555555),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Color(0xFFffffff))),
  ),
);
ThemeData myLightTheme = ThemeData.light().copyWith(
  pageTransitionsTheme: MyPageTransitionsTheme(),
  backgroundColor: Color(0xFFeeeeee),
  scaffoldBackgroundColor: Color(0xFFeeeeee),
  //canvasColor: Color(0xFFFFFFFF),
  cardColor: Color(0xFFffffff),
  primaryColor: Color(0xFFfffaf0),
  dividerColor: Color(0xFFdddddd),
  selectedRowColor: Color(0xFFbbbbbb),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Color(0xFFffffff))),
  ),
);

// Swipe to cancel. From left to right.
class MyPageTransitionsTheme extends PageTransitionsTheme {
  const MyPageTransitionsTheme();
  static const PageTransitionsBuilder builder = CupertinoPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return builder.buildTransitions<T>(route, context, animation, secondaryAnimation, child);
  }
}
