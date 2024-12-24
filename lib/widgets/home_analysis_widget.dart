import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

// Adjusted Chart UI : grid and left values
// Removed "Monthly review" text
// Added date range input
// Added analysing by dateRange functionality

class HomeAnalysisWidget extends GetView<HomeController> {
  final Color _talentLineColor = const Color(0xFF0CB9C1);
  final Color _teachingLineColor = const Color(0xFFF48924);
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
    controller.analysisChartData['data']!.forEach((key, value) {
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
          Padding(
            padding: const EdgeInsets.only(bottom: 22.0),
            child: Center(
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: Get.theme.colorScheme.outline,
                    width: 0.6,
                  ),
                ),
                onPressed: () => controller.onDateRangeTextClick(context),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  controller.analysisDateRange.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: _lineBarsData(),
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  verticalInterval: 1,
                ),
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
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
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
