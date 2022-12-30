import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/models/menu.dart';

final menuProvider = ChangeNotifierProvider((ref) => MenuNotifier(ref));
class MenuNotifier extends ChangeNotifier {
  MenuNotifier(ref){}
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  MenuData data = MenuData();

  switchDarkMode(){
    data.isDark = !data.isDark;
    this.notifyListeners();
  }

  switchSideMenu(){
    data.sideMenuType = data.sideMenuType==1 ? 2 : 1;
    this.notifyListeners();
  }

  setScreenType(int type){
    data.screenType = type;
    this.notifyListeners();
  }
}


