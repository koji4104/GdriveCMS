import '/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screens/main_screen.dart';
import 'controllers/menu_controller.dart';
import 'models/menu.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    myTheme = ref.watch(menuProvider).data.isDark ? myDarkTheme : myLightTheme;
    return MaterialApp(
      routes: {},
      debugShowCheckedModeBanner: false,
      title: 'GdriveCMS',
      theme: myTheme,
      home: MainScreen(),
    );
  }
}
