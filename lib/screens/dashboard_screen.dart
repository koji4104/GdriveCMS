import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '/constants.dart';

import 'components/storage_capacity.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/controllers/menu_controller.dart';
import '/models/content.dart';
import '/controllers/content_controller.dart';
import '/commons/widgets.dart';

class DashboardScreen extends ConsumerWidget {
  late WidgetRef ref;
  late BuildContext context;
  List<ContentData> files = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.ref = ref;
    this.context = context;
    files = ref.watch(gdriveProvider).files;
    ref.watch(menuProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          topButtons(),
          SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 2, child: fileList()),
            SizedBox(width: 10),
            Expanded(flex: 1, child: StorageCapacity()),
          ])
        ]),
      ),
    );
  }

  Widget topButtons() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MyIconButton(
        icon: Icon(Icons.autorenew),
        onPressed: () async {
          ref.read(gdriveProvider).getFiles();
        },
      ),
    ]);
  }

  Widget fileList() {
    TextStyle ts = TextStyle(color: myTheme.textTheme.bodyMedium!.color);
    List<ContentData> recents = files;

    recents.sort((a, b) {
      if (a.createdTime! != null && b.createdTime != null)
        return b.createdTime!.compareTo(a.createdTime!);
      else
        return 1;
    });

    return DataTable2(
      columnSpacing: 8,
      minWidth: 400,
      dataRowHeight: DEF_ROW_HEIGHT,
      headingTextStyle: myTheme.textTheme.bodyMedium,
      dataTextStyle: myTheme.textTheme.bodyMedium,
      decoration: BoxDecoration(
        color: myTheme.cardColor,
        borderRadius: DEF_BORDER_RADIUS,
      ),
      columns: [
        DataColumn(label: Text("Name")),
        DataColumn(label: Text("Date")),
        DataColumn(label: Text("Size")),
      ],
      rows: List.generate(
        files.length > 5 ? 5 : files.length,
        (index) => getRow(files[index]),
      ),
    );
  }

  DataRow getRow(ContentData cont) {
    TextStyle ts = myTheme.textTheme.bodyMedium!;
    Color? col = myTheme.textTheme.bodyMedium!.color;
    Icon icon = Icon(Icons.text_snippet, size: DEF_ROW_ICONSIZE, color: col);
    String sTime = cont.createdTime != null ? DateFormat('yyyy/MM/dd').format(cont.createdTime!) : '';
    if (cont.mimeType != null) {
      if (cont.mimeType!.contains('video'))
        icon = Icon(Icons.videocam, size: DEF_ROW_ICONSIZE, color: col);
      else if (cont.mimeType!.contains('image')) icon = Icon(Icons.image, size: DEF_ROW_ICONSIZE, color: col);
    }
    return DataRow(
      color: MaterialStateProperty.resolveWith((states) {
        return myTheme.canvasColor;
      }),
      cells: [
        DataCell(
          Row(
            children: [
              icon,
              SizedBox(width: 4),
              Expanded(child: Text(cont.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        DataCell(Text(sTime)),
        DataCell(Text((cont.bytes / 1024).toInt().toString() + ' KB')),
      ],
    );
  }
}
