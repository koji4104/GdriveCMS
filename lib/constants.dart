import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

/// e.g.
/// Theme.of(context).backgroundColor
/// Theme.of(context).disabledColor
/// Theme.of(context).textTheme.bodyMedium!.color
ThemeData myDarkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Color(0xFF000000),
  backgroundColor: Color(0xFF000000),
  //canvasColor: Color(0xFF000000),
  cardColor: Color(0xFF333333),
);
ThemeData myLightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Color(0xFFFFFFFF),
  backgroundColor: Color(0xFFFFFFFF),
  //canvasColor: Color(0xFFFFFFFF),
  cardColor: Color(0xFFFFFFFF),
);