import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '/controllers/menu_controller.dart';
import '/models/menu.dart';
import '/controllers/content_controller.dart';
import '/models/content.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants.dart';

class StorageCapacity extends ConsumerWidget {
  StorageCapacity({
    Key? key,
  }) : super(key: key);

  List<ContentData> files = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    files = ref
        .watch(gdriveProvider)
        .files;
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
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Storage Capacity",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Chart(
              value1: videoBytes,
              value2: imageBytes,
              value3: otherBytes,
              total: 1024 * 1024 * 1024
          ),
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
      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(width: 1, color: Colors.black),
        borderRadius: const BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Icon(iconData),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ProgressLine(
                    color: Colors.green,
                    percentage: 25,
                  ),
                  Row(children: [
                    Text(
                      "$numOfFiles Files",
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption!
                          .copyWith(color: Colors.white70),
                    ),
                    SizedBox(width: 10,),
                    Text(
                      (bytes / 1024 / 1024).toInt().toString() + ' MB',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption!
                          .copyWith(color: Colors.white),
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
                Text(
                    '${((value1 + value2 + value3) / 1024 / 1024).toInt()} MB'
                ),
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
        color: Color(0xFF880000),
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
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) =>
              Container(
                width: constraints.maxWidth * (percentage! / 100),
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
        ),
      ],
    );
  }
}
