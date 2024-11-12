import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeAnalysisWidget extends GetView<HomeController> {
  final Color _talentLineColor = const Color(0xFF0CB9C1);
  final Color _teachingLineColor = const Color(0xFFF48924);
  late final RxInt _selectedMonthIndex =
      RxInt(controller.analysisChartData.keys.length - 1);
  final List<String> _shortStatuses = [
    'APP',
    'ACC',
    'APD',
    'REA',
    'FIN',
    'COM'
  ];
  HomeAnalysisWidget({super.key});
  List<LineChartBarData> _lineBarsData() {
    List<LineChartBarData> lineBarsData = [];
    final String selectedMonthShort =
        controller.analysisChartData.keys.toList()[_selectedMonthIndex.value];
    controller.analysisChartData[selectedMonthShort]!.forEach((key, value) {
      lineBarsData.add(
        LineChartBarData(
          isCurved: true,
          preventCurveOverShooting: true,
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
          color: key == 'talent' ? _talentLineColor : _teachingLineColor,
          barWidth: 5,
          spots: value.entries.map((e) {
            final idx =
                controller.statuses.indexOf(e.key.toString().capitalizeFirst);
            return FlSpot(idx.toDouble(), e.value.toDouble());
          }).toList(),
          dotData: const FlDotData(show: false),
        ),
      );
    });
    return lineBarsData;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Center(
              child: Column(
            children: [
              Text(
                'Monthly review',
                style: Get.textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                ),
              ),
              DropdownButton(
                underline: const SizedBox(),
                dropdownColor: const Color(0xFF363633),
                borderRadius: BorderRadius.circular(10),
                isDense: true,
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                items: List.generate(controller.analysisChartData.keys.length,
                    (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(
                      controller.analysisChartData.keys
                          .toList()[index]
                          .capitalizeFirst,
                      style: Get.textTheme.bodyMedium!.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  );
                }),
                onChanged: (value) => _selectedMonthIndex.value = value!,
                value: _selectedMonthIndex.value,
              ),
            ],
          )),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: _lineBarsData(),
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: const FlGridData(show: false),
                lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 12,
                  getTooltipItems: (touchedSpots) =>
                      List.generate(touchedSpots.length, (index) {
                    final touchedSpot = touchedSpots[index];
                    final line = _lineBarsData()[index];
                    final lineColor = line.color;
                    return LineTooltipItem(
                      '${line.spots[touchedSpot.spotIndex].y.toInt()} ${_shortStatuses[touchedSpot.spotIndex]}',
                      Get.textTheme.labelSmall!.copyWith(
                          color: lineColor, fontWeight: FontWeight.w600),
                    );
                  }),
                  getTooltipColor: (touchedSpot) => const Color(0xFF363633),
                )),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: AxisSide.bottom,
                          fitInside: SideTitleFitInsideData.fromTitleMeta(
                            meta,
                            distanceFromEdge: 0,
                          ),
                          child: Text(
                            _shortStatuses[value.toInt()],
                            style: Get.theme.textTheme.labelSmall!.copyWith(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          space: 20,
                          axisSide: AxisSide.left,
                          child: Text(
                            '${value.toInt()}',
                            style: Get.theme.textTheme.labelSmall!.copyWith(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
