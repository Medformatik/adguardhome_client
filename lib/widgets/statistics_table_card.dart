import 'package:adguard_home_client/main.dart';
import 'package:flutter/material.dart';

class StatisticsTableCard extends StatefulWidget {
  final String title;
  final Color textColor;
  final Color backgroundColor;
  final IconData? icon;
  final String keyColumn;
  final String valueColumn;
  final Future<Map<String, int>> future;
  final Future<int>? totalFuture;

  const StatisticsTableCard({
    super.key,
    required this.title,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.icon,
    required this.keyColumn,
    required this.valueColumn,
    required this.future,
    this.totalFuture,
  });

  @override
  State<StatisticsTableCard> createState() => _StatisticsTableCardState();
}

class _StatisticsTableCardState extends State<StatisticsTableCard> {
  late Future<Map<String, int>> future;
  late Future<int>? totalFuture;

  @override
  void initState() {
    super.initState();
    future = widget.future;
    totalFuture = widget.totalFuture;
  }

  List<DataColumn> getColumns(BoxConstraints constraints) {
    double columnWidth(double factor) => constraints.maxWidth * factor;

    List<DataColumn> columns = [
      DataColumn(
        label: SizedBox(
          width: totalFuture != null ? columnWidth(0.6) : columnWidth(0.8),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              widget.keyColumn,
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth(0.2),
          child: Padding(
            padding: totalFuture != null ? const EdgeInsets.all(0) : const EdgeInsets.only(right: 16.0),
            child: Text(
              widget.valueColumn,
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ),
        numeric: true,
      ),
    ];
    if (totalFuture != null) {
      columns.add(
        DataColumn(
          label: SizedBox(
            width: columnWidth(0.2),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                '',
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ),
          numeric: true,
        ),
      );
    }
    return columns;
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: widget.textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return SizedBox(
                  height: 200,
                  child: !snapshot.hasData
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                              return DataTable(
                                horizontalMargin: 0,
                                columnSpacing: 0,
                                headingRowColor: WidgetStateProperty.all<Color>(widget.textColor.withValues(alpha: 0.2)),
                                columns: getColumns(constraints),
                                rows: snapshot.data.entries.map<DataRow>((row) {
                                  List<DataCell> cells = [
                                    DataCell(
                                      SizedBox(
                                        width: constraints.maxWidth * (totalFuture != null ? 0.6 : 0.8),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            row.key,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: constraints.maxWidth * .2,
                                        child: Padding(
                                          padding: totalFuture != null ? const EdgeInsets.all(0) : const EdgeInsets.only(right: 16.0),
                                          child: Text(
                                            row.value.toString(),
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ];
                                  if (totalFuture != null) {
                                    cells.add(DataCell(
                                      SizedBox(
                                        width: constraints.maxWidth * .2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 16.0),
                                          child: FutureBuilder(
                                            future: totalFuture,
                                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                              return Text(
                                                snapshot.hasData ? '${adGuardHome!.stats.round(((row.value / snapshot.data) * 100), 1)} %' : '',
                                                overflow: TextOverflow.visible,
                                                softWrap: true,
                                                textAlign: TextAlign.end,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ));
                                  }
                                  return DataRow(cells: cells);
                                }).toList(),
                              );
                            },
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
