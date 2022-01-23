import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsCard extends StatefulWidget {
  final String title;
  final Color textColor;
  final Color backgroundColor;
  final IconData? icon;
  final Future<dynamic> primaryFuture;
  final String? primaryUnit;
  final Future<dynamic>? secondaryFuture;
  final String? secondaryPrefix;
  final String? secondarySuffix;
  final Future<List<num>>? graphFuture;

  const StatisticsCard({
    Key? key,
    required this.primaryFuture,
    required this.title,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.icon,
    this.primaryUnit,
    this.secondaryFuture,
    this.secondaryPrefix,
    this.secondarySuffix,
    this.graphFuture,
  }) : super(key: key);

  @override
  _StatisticsCardState createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {
  late Future<dynamic>? primaryFuture;
  late Future<dynamic>? secondaryFuture;
  late Future<List<num>>? graphFuture;

  @override
  void initState() {
    super.initState();
    primaryFuture = widget.primaryFuture;
    secondaryFuture = widget.secondaryFuture;
    graphFuture = widget.graphFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.icon != null
                    ? Icon(
                        widget.icon,
                        color: widget.textColor,
                      )
                    : Container(),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headline6?.copyWith(color: widget.textColor),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FutureBuilder(
                      future: primaryFuture,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return Text(
                          snapshot.hasData ? (snapshot.data.toString() + (widget.primaryUnit != null ? " " + widget.primaryUnit! : "")) : "...",
                          style: Theme.of(context).textTheme.subtitle2?.copyWith(color: widget.textColor, fontSize: 20.0),
                        );
                      },
                    ),
                    secondaryFuture != null
                        ? FutureBuilder(
                            future: secondaryFuture,
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              return Text(
                                snapshot.hasData
                                    ? ((widget.secondaryPrefix != null ? widget.secondaryPrefix! + " " : "") +
                                        snapshot.data.toString() +
                                        (widget.secondarySuffix != null ? " " + widget.secondarySuffix! : ""))
                                    : "...",
                                style: Theme.of(context).textTheme.subtitle2?.copyWith(color: widget.textColor),
                              );
                            },
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
            graphFuture != null
                ? FutureBuilder(
                    future: graphFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 8.0),
                          child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                        );
                      }

                      List<FlSpot> spots = [];
                      bool notZero = false; // Used to hide graph when all datapoints are zero
                      for (var i = 0; i < snapshot.data.length; i++) {
                        spots.add(FlSpot(i.toDouble(), snapshot.data[i].toDouble()));
                        if (snapshot.data[i] != 0) notZero = true;
                      }

                      return Padding(
                        padding: notZero ? const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 8.0) : const EdgeInsets.all(0.0),
                        child: SizedBox(
                          height: notZero ? 200 : 0,
                          child: !notZero
                              ? Container()
                              : LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                        fitInsideHorizontally: true,
                                        fitInsideVertically: true,
                                        tooltipBgColor: widget.textColor.withOpacity(0.8),
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map<LineTooltipItem>((touchedSpot) {
                                            return LineTooltipItem(
                                              "Day ${(touchedSpot.x + 1).toInt()}: " + touchedSpot.y.toInt().toString(),
                                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        isStrokeCapRound: true,
                                        colors: [widget.textColor],
                                        barWidth: 2,
                                        dotData: FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          colors: [
                                            widget.textColor,
                                          ].map((color) => color.withOpacity(0.3)).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      );
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
