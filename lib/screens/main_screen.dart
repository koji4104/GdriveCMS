import '/responsive.dart';
import 'dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '/controllers/menu_controller.dart';
import '/models/menu.dart';
import '/controllers/content_controller.dart';
import 'content_screen.dart';
import 'gdrive_adapter.dart';

class MainScreen extends ConsumerWidget {
  late WidgetRef ref;
  late BuildContext context;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.ref = ref;
    this.context = context;
    int screenType = ref
        .watch(menuProvider)
        .data
        .screenType;
    ref.watch(menuProvider);

    return
      Scaffold(
        key: ref
            .read(menuProvider)
            .scaffoldKey,
        backgroundColor:Theme.of(context).scaffoldBackgroundColor,
        drawerScrimColor:Theme.of(context).primaryColor,
        drawer: SideBar(),
        body: SafeArea(child:
        Responsive.isMobile(context) == true ?
        Column(children: [
          headerMenu(context, ref),
          Expanded(child: getScreen(screenType))
        ]) :
        Row(children: [
          SideBar(),
          Expanded(child: Column(children: [
            headerMenu(context, ref),
            Expanded(child: getScreen(screenType))
          ]))
        ]),
        ),
      );
  }

  Widget getScreen(int type){
    if(type==0) return DashboardScreen();
    else if(type==1) return ContentScreen();
    else return Container();
  }

  Widget headerMenu(BuildContext context, WidgetRef ref) {
    return Container(
        color: Theme.of(context).primaryColor,
        child: Row(children: [
          if (Responsive.isMobile(context) == true)
            IconButton(
                iconSize: 32,
                icon: Icon(Icons.menu, size: 32, color: Theme.of(context).iconTheme.color),
                onPressed: () {
                  ref
                      .read(menuProvider)
                      .scaffoldKey
                      .currentState!
                      .openDrawer();
                }
            ),

          Expanded(child: SizedBox(width: 1)),

          headerButtons(),

          PopupMenuButton(
            icon: Icon(Icons.adaptive.more, color: null),
            enableFeedback: ref.watch(menuProvider).data.isDark,
            offset: Offset(0, 50),
            itemBuilder: (BuildContext context) =>
            [
              PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.dark_mode_outlined),
                    title: Text('Darkmode'),
                    onTap: () {
                      ref.read(menuProvider).switchDarkMode();
                    },
                  )
              ),
            ],
          )
        ])
    );
  }

  Widget headerButtons() {
    ref.watch(gdriveProvider);
    return PopupMenuButton(
      icon: Icon(Icons.account_circle, color: null),
      enableFeedback: ref.watch(menuProvider).data.isDark,
      offset: Offset(0, 50),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
            child: ListTile(
              title: Text(ref.read(gdriveProvider).getAccountName()),
            )
        ),
        PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () {
                ref.read(gdriveProvider).loginSilently();
              },
            )
        ),
        PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Other user'),
              onTap: () {
                ref.read(gdriveProvider).loginWithGoogle();
              },
            )
        ),
        PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                ref.read(gdriveProvider).logout();
              },
            )
        ),
      ],
    );
  }
}

/// SideBar
class SideBar extends ConsumerWidget {
  SideBar({Key? key}) : super(key: key);

  final double IconSize = 28;
  int _selcted = 1;
  int _type = 2;
  late WidgetRef ref;
  late BuildContext context;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this._selcted = ref.watch(menuProvider).data.screenType;
    this._type = ref.watch(menuProvider).data.sideMenuType;
    this.ref = ref;
    this.context = context;
    ref.watch(menuProvider);

    return Container(
        width: _type == 2 ? 180 : 50,
        color: Theme.of(context).primaryColor,
        child: Drawer(
          backgroundColor: Theme.of(context).primaryColor,
          child: ListView(
            children: [
              if(_type != 0)
                ListTile(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  onTap: () {
                    ref.read(menuProvider).switchSideMenu();
                  },
                  leading: Icon(Icons.menu, size: this.IconSize, color: Theme.of(context).iconTheme.color),
                  tileColor: Theme.of(context).primaryColor,
                  title: null,
                ),
              MyListTile(
                title: "Dashboard",
                icondata: Icons.insert_chart,
                screenType: 0,
              ),
              MyListTile(
                title: "Contents",
                icondata: Icons.article,
                screenType: 1,
              ),
              MyListTile(
                title: "Settings",
                icondata: Icons.settings,
                screenType: 2,
              ),
            ],
          ),
        )
    );
  }

  Widget MyListTile({
    required String title,
    required IconData icondata,
    required int screenType,
  }) {
    Color? col = _selcted == screenType ?
    null : Theme.of(context).disabledColor;
    Icon icon = Icon(icondata, size: this.IconSize, color: col);
    Text text = Text(title, style: TextStyle(color: col));
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      leading: icon,
      title: _type == 2 ? text : null,
      tileColor: Theme.of(context).primaryColor,
      onTap: () {
          this.ref
              .read(menuProvider).setScreenType(screenType);
      },
    );
  }
}