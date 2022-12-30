import 'package:flutter/material.dart';

import 'package:data_table_2/data_table_2.dart';

import '/constants.dart';

import 'components/storage_capacity.dart';
import 'gdrive_adapter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/controllers/menu_controller.dart';
import '/models/menu.dart';
import '/models/content.dart';
import '/controllers/content_controller.dart';

class DashboardScreen extends ConsumerWidget {
  late WidgetRef ref;
  late BuildContext context;
  List<ContentData> files = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.ref = ref;
    this.context = context;
    files = ref
        .watch(gdriveProvider)
        .files;
    ref.watch(menuProvider);

    return SafeArea(child:
    SingleChildScrollView(padding: EdgeInsets.all(8), child:
    Column(children: [
      topButtons(),
      Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: fileList(),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: StorageCapacity(),
            ),
          ])
    ]),
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
    TextStyle ts = TextStyle(color:Theme.of(context).textTheme.bodyMedium!.color);
    return DataTable2(
        columnSpacing: defaultPadding,
        minWidth: 400,
        headingTextStyle:Theme.of(context).textTheme.bodyMedium,
        dataTextStyle:Theme.of(context).textTheme.bodyMedium,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(6),
        ),
        columns: [
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Size")),
        ],
        rows: List.generate(
          files.length,
              (index) => getRow(files[index]),
        )
    );
  }

  DataRow getRow(ContentData cont) {
    TextStyle ts = TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color);
    Icon icon = Icon(Icons.text_snippet, size: 30, color: Theme.of(context).canvasColor);
    if (cont.mimeType != null) {
      if (cont.mimeType!.contains('video'))
        icon = Icon(Icons.videocam, size: 30, color: Theme.of(context).canvasColor);
      else if (cont.mimeType!.contains('image'))
      icon = Icon(Icons.image, size: 30, color: Theme.of(context).canvasColor);
    }
    return DataRow(
      color: MaterialStateProperty.resolveWith((states) {
        return Theme.of(context).canvasColor;
      }),
      cells: [
        DataCell(
          Row(children: [
            icon,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(cont.name),
            ),
          ],),
        ),
        DataCell(Text(cont.createdTime!.toString(), style: ts)),
        DataCell(Text((cont.bytes / 1024).toInt().toString() + ' KB', style: ts)),
      ],);
  }
}