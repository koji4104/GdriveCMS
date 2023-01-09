import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

/// Radius
const DEFAULT_RADIUS = 6.0;

/// e.g.
/// Theme.of(context).backgroundColor
/// Theme.of(context).disabledColor
/// Theme.of(context).textTheme.bodyMedium!.color
ThemeData myDarkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Color(0xFF000000),
  backgroundColor: Color(0xFF000000),
  //canvasColor: Color(0xFF000000),
  cardColor: Color(0xFF333333),
  primaryColor:Color(0xFF222230),
  dividerColor: Color(0xFF555555),
  selectedRowColor: Color(0xFF555555),
);
ThemeData myLightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Color(0xFFeeeeee),
  backgroundColor: Color(0xFFeeeeee),
  //canvasColor: Color(0xFFFFFFFF),
  cardColor: Color(0xFFffffff),
  primaryColor:Color(0xFFfffaf0),
  dividerColor: Color(0xFFdddddd),
  selectedRowColor: Color(0xFFbbbbbb),
);