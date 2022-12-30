import 'package:flutter/material.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '/constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/controllers/menu_controller.dart';
import '/models/menu.dart';
import '/controllers/content_controller.dart';
import '/models/content.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentScreen extends ConsumerWidget {
  late WidgetRef ref;
  late BuildContext context;
  List<ContentData> files = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.ref = ref;
    this.context = context;
    this.files = ref
        .watch(gdriveProvider)
        .files;
    ref.watch(menuProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          topButtons(),
          fileList(),
        ],),
      ),
    );
  }

  Widget topButtons() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
              icon: Icon(Icons.autorenew),
              iconSize: 30.0,
              onPressed: () async {
                ref.read(gdriveProvider).getFiles();
              }
          ),
        ]);
  }

  Widget fileList() {
    return DataTable2(
        columnSpacing: defaultPadding,
        minWidth: 600,
        headingTextStyle:Theme.of(context).textTheme.bodyMedium,
        dataTextStyle:Theme.of(context).textTheme.bodyMedium,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        columns: [
          DataColumn(label: Text("Icon")),
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Size")),
          DataColumn(label: Text("Parent")),
          DataColumn(label: Text("View")),
        ],
        rows: List.generate(
          files.length,
              (index) => getRow(files[index]),
        )
    );
  }

  DataRow getRow(ContentData cont) {
    IconData idata = Icons.text_snippet;
    if (cont.mimeType != null) {
      String m = cont.mimeType!;
      if (m.contains('video'))
        idata = Icons.videocam;
      else if (m.contains('image'))
        idata = Icons.image;
      else if (m.contains('folder')) idata = Icons.folder;
    }
    Widget icon = Icon(idata, size: 30, color:Theme.of(context).textTheme.bodyMedium!.color);
    String sTime = DateFormat('yyyy/MM/dd').format(cont.createdTime!);

    return DataRow(
        color: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).cardColor;
        }),
        cells: [
          DataCell(icon),
          DataCell(Text(cont.name.toString())),
          DataCell(Text(sTime)),
          DataCell(Text((cont.bytes / 1024).toInt().toString() + ' KB')),
          DataCell(Text(cont.parent ?? '')),
          DataCell(
            MyIconButton(
                icon: Icon(Icons.play_circle_fill, color: null, size: 30),
                onPressed: () {
                  if (cont.webViewLink != null)
                    launchUrl(
                        Uri.parse(cont.webViewLink!));
                }),
          )
        ]);
  }

  Widget MyIconButton({required Icon icon, required void Function()? onPressed,
    double? left, double? top, double? right, double? bottom, double? iconSize}) {
    Color fgcol = Colors.white;
    Color bgcol = Colors.black54;
    if (iconSize == null)
      iconSize = 38.0;
    return IconButton(
      icon: icon,
      color: fgcol,
      iconSize: iconSize,
      onPressed: onPressed,
    );
  }
}