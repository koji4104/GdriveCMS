import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/controllers/menu_controller.dart';
import '/controllers/content_controller.dart';
import '/models/content.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/commons/widgets.dart';

import '../../../constants.dart';

class StorageCapacity extends ConsumerWidget {
  StorageCapacity({
    Key? key,
  }) : super(key: key);

  List<ContentData> files = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    files = ref.watch(gdriveProvider).files;
    ref.watch(menuProvider);

    double videoBytes = 0;
    double imageBytes = 0;
    double otherBytes = 0;
    double freeBytes = 0;
    double totalBytes = 1024 * 1024 * 1024;
    int videoCount = 0;
    int imageCount = 0;
    int otherCount = 0;

    for (ContentData d in files) {
      if (d.mimeType != null) {
        String m = d.mimeType!;
        if (m.contains('video')) {
          videoBytes += d.bytes;
          videoCount++;
        } else if (m.contains('image')) {
          imageBytes += d.bytes;
          imageCount++;
        } else {
          otherBytes += d.bytes;
          otherCount++;
        }
      }
    }
    freeBytes = totalBytes - videoBytes - imageBytes - otherBytes;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: myTheme.cardColor,
        borderRadius: DEF_BORDER_RADIUS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Storage Capacity",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Chart(value1: videoBytes, value2: imageBytes, value3: otherBytes, total: 1024 * 1024 * 1024),
          StorageCapacityCard(
            iconData: Icons.videocam,
            title: "Videos",
            bytes: videoBytes,
            numOfFiles: videoCount,
          ),
          StorageCapacityCard(
            iconData: Icons.image_outlined,
            title: "Images",
            bytes: imageBytes,
            numOfFiles: imageCount,
          ),
          StorageCapacityCard(
            iconData: Icons.text_snippet,
            title: "Other",
            bytes: otherBytes,
            numOfFiles: otherCount,
          ),
          StorageCapacityCard(
            iconData: Icons.fiber_manual_record_outlined,
            title: "Free",
            bytes: freeBytes,
            numOfFiles: 0,
          ),
        ],
      ),
    );
  }
}

class StorageCapacityCard extends ConsumerWidget {
  StorageCapacityCard({
    Key? key,
    required this.title,
    required this.iconData,
    required this.bytes,
    required this.numOfFiles,
  }) : super(key: key);

  final String title;
  final double bytes;
  final int numOfFiles;
  final IconData iconData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(menuProvider);
    return Container(
      margin: EdgeInsets.only(top: 6),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: myTheme.cardColor,
        border: Border.all(width: 1, color: myTheme.dividerColor),
        borderRadius: DEF_BORDER_RADIUS,
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Icon(iconData),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ProgressLine(
                    color: myTheme.iconTheme.color,
                    percentage: 25,
                  ),
                  Row(children: [
                    Text(
                      "$numOfFiles Files",
                      style: myTheme.textTheme.caption!.copyWith(color: myTheme.iconTheme.color),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      (bytes / 1024 / 1024).toInt().toString() + ' MB',
                      style: myTheme.textTheme.caption!.copyWith(color: myTheme.iconTheme.color),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Chart extends StatelessWidget {
  Chart({
    Key? key,
    required value1,
    required value2,
    required value3,
    required total,
  }) : super(key: key) {
    this.value1 = value1;
    this.value2 = value2;
    this.value3 = value3;
    this.total = total;
  }

  double value1 = 0;
  double value2 = 0;
  double value3 = 0;
  double total = 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              sections: paiChartSelectionDatas(),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${((value1 + value2 + value3) / 1024 / 1024).toInt()} MB'),
                Text('of ${(total / 1024 / 1024).toInt()} MB')
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> paiChartSelectionDatas() {
    return [
      PieChartSectionData(
        color: Color(0xFF888888),
        value: value1,
        showTitle: false,
        radius: 12,
      ),
      PieChartSectionData(
        color: Color(0xFF000088),
        value: value2,
        showTitle: false,
        radius: 12,
      ),
      PieChartSectionData(
        color: Color(0xFF008800),
        value: value3,
        showTitle: false,
        radius: 12,
      ),
      PieChartSectionData(
        color: Color(0xFF000000),
        value: total - value1 - value2 - value3,
        showTitle: false,
        radius: 10,
      ),
    ];
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    Key? key,
    this.color = primaryColor,
    required this.percentage,
  }) : super(key: key);

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4, bottom: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 5,
            decoration: BoxDecoration(
              color: myTheme.backgroundColor,
              borderRadius: DEF_BORDER_RADIUS,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => Container(
              width: constraints.maxWidth * (percentage! / 100),
              height: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: DEF_BORDER_RADIUS,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
