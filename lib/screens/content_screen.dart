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
    this.files = ref.watch(gdriveProvider).files;
    ref.watch(menuProvider);
    ref.watch(contentProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            topButtons(),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: fileList()),
              SizedBox(width: 10),
              Expanded(flex: 1, child: propertyList()),
            ])
          ],
        ),
      ),
    );
  }

  Widget topButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(Icons.autorenew),
          iconSize: 24.0,
          onPressed: () async {
            ref.read(gdriveProvider).getFiles();
          },
        ),
      ],
    );
  }

  Widget fileList() {
    return DataTable2(
      showCheckboxColumn: false,
      columnSpacing: 8,
      minWidth: 100,
      headingTextStyle: myTheme.textTheme.bodyMedium,
      dataTextStyle: myTheme.textTheme.bodyMedium,
      decoration: BoxDecoration(
        color: myTheme.cardColor,
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
      ),
      columns: [
        DataColumn(label: Text("Name")),
        DataColumn(label: Text("Date")),
        DataColumn(label: Text("Size")),
        DataColumn(label: Text("View")),
      ],
      rows: List.generate(
        files.length,
        (index) => getRow(files[index]),
      ),
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
    Widget icon = Icon(idata, size: 24, color: myTheme.textTheme.bodyMedium!.color);
    String sTime = DateFormat('yyyy/MM/dd').format(cont.createdTime!);

    return DataRow(
      color: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return myTheme.selectedRowColor;
          }
        },
      ),
      onSelectChanged: (_) {
        ref.read(contentProvider).select(cont);
      },
      selected: ref.watch(contentProvider).contains(cont),
      cells: [
        DataCell(
          Row(
            children: [
              icon,
              SizedBox(width: 6),
              Expanded(child: Text(cont.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        DataCell(Text(sTime)),
        DataCell(Text((cont.bytes / 1024).toInt().toString() + ' KB')),
        DataCell(
          MyIconButton(
            icon: Icon(Icons.play_circle_fill, color: null, size: 24),
            onPressed: () {
              if (cont.webViewLink != null) launchUrl(Uri.parse(cont.webViewLink!));
            },
          ),
        )
      ],
    );
  }

  Widget propertyList() {
    List<DataRow> rows = [];
    if (ref.watch(contentProvider).selected != null) {
      ContentData sel = ref.watch(contentProvider).selected!;
      rows = [
        DataRow(cells: [DataCell(Text('name')), DataCell(Text(sel.name))]),
        DataRow(cells: [DataCell(Text('mimeType')), DataCell(Text(sel.mimeType!))]),
        DataRow(cells: [DataCell(Text('kind')), DataCell(Text(sel.kind!))]),
        DataRow(cells: [DataCell(Text('parent')), DataCell(Text(sel.parent!))]),
      ];
    }

    return DataTable2(
      showCheckboxColumn: false,
      columnSpacing: 8,
      minWidth: 100,
      headingTextStyle: myTheme.textTheme.bodyMedium,
      dataTextStyle: myTheme.textTheme.bodyMedium,
      decoration: BoxDecoration(
        color: myTheme.cardColor,
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
      ),
      columns: [
        DataColumn(label: Text("Key")),
        DataColumn(label: Text("Value")),
      ],
      rows: rows,
    );
  }

  Widget MyIconButton(
      {required Icon icon,
      required void Function()? onPressed,
      double? left,
      double? top,
      double? right,
      double? bottom,
      double? iconSize}) {
    Color fgcol = Colors.white;
    Color bgcol = Colors.black54;
    if (iconSize == null) iconSize = 24.0;
    return IconButton(
      icon: icon,
      color: fgcol,
      iconSize: iconSize,
      onPressed: onPressed,
    );
  }
}
