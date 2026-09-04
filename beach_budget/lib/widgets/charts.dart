import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';

/// โดนัทสัดส่วนรายจ่ายแยกตามหมวด พร้อมคำอธิบายด้านข้าง
class CategoryDonut extends StatefulWidget {
  const CategoryDonut({super.key, required this.data, required this.total});

  final List<MapEntry<String, double>> data;
  final double total;

  @override
  State<CategoryDonut> createState() => _CategoryDonutState();
}

class _CategoryDonutState extends State<CategoryDonut> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty || widget.total <= 0) {
      return const _EmptyChart(text: 'ยังไม่มีรายจ่ายในช่วงนี้');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        _touched = response?.touchedSection
                                ?.touchedSectionIndex ??
                            -1;
                      });
                    },
                  ),
                  sections: [
                    for (var i = 0; i < widget.data.length; i++)
                      PieChartSectionData(
                        value: widget.data[i].value,
                        color: Beach.categoryColor(
                            Categories.colorIndexOf(widget.data[i].key)),
                        radius: _touched == i ? 30 : 24,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _touched >= 0 && _touched < widget.data.length
                        ? Categories.byId(widget.data[_touched].key).name
                        : 'รวมจ่าย',
                    style: const TextStyle(
                        fontSize: 11, color: Beach.inkSoft),
                  ),
                  Text(
                    moneyInt(_touched >= 0 && _touched < widget.data.length
                        ? widget.data[_touched].value
                        : widget.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: Beach.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.data.length && i < 6; i++)
                _LegendRow(
                  color: Beach.categoryColor(
                      Categories.colorIndexOf(widget.data[i].key)),
                  name: Categories.byId(widget.data[i].key).name,
                  amount: widget.data[i].value,
                  percent: widget.data[i].value / widget.total,
                ),
              if (widget.data.length > 6)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'และอีก ${widget.data.length - 6} หมวด',
                    style: const TextStyle(fontSize: 11, color: Beach.inkSoft),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.name,
    required this.amount,
    required this.percent,
  });

  final Color color;
  final String name;
  final double amount;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          Text(
            moneyInt(amount),
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 34,
            child: Text(
              '${(percent * 100).round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, color: Beach.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// กราฟแท่งรายจ่ายรายวัน ตลอดช่วงเวลาที่เลือก
class DailyBars extends StatelessWidget {
  const DailyBars({super.key, required this.range, required this.daily});

  final DateRange range;
  final Map<DateTime, double> daily;

  @override
  Widget build(BuildContext context) {
    final buckets = _buckets();
    if (buckets.isEmpty) return const _EmptyChart(text: 'ยังไม่มีข้อมูล');

    final maxY = buckets.fold<double>(0, (m, b) => b.value > m ? b.value : m);
    if (maxY <= 0) return const _EmptyChart(text: 'ยังไม่มีรายจ่ายในช่วงนี้');

    return SizedBox(
      height: 170,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 2 <= 0 ? 1 : maxY / 2,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Beach.sandDeep, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 2 <= 0 ? 1 : maxY / 2,
                getTitlesWidget: (v, meta) => Text(
                  v >= 1000
                      ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k'
                      : v.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10, color: Beach.inkSoft),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= buckets.length) {
                    return const SizedBox.shrink();
                  }
                  final step = (buckets.length / 8).ceil();
                  if (buckets.length > 10 && i % step != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      buckets[i].label,
                      style:
                          const TextStyle(fontSize: 10, color: Beach.inkSoft),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Beach.seaDeep,
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                '${buckets[group.x].label}\n${baht(rod.toY)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < buckets.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: buckets[i].value,
                    width: buckets.length > 20 ? 6 : 14,
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Beach.sea, Beach.lagoon],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<_Bucket> _buckets() {
    final out = <_Bucket>[];
    switch (range.period) {
      case Period.day:
        // แสดง 7 วันย้อนหลังเพื่อให้เห็นแนวโน้ม
        for (var i = 6; i >= 0; i--) {
          final d = range.start.subtract(Duration(days: i));
          out.add(_Bucket(DateFormat('E', 'th').format(d), daily[d] ?? 0));
        }
        break;
      case Period.week:
        for (var d = range.start;
            d.isBefore(range.end);
            d = d.add(const Duration(days: 1))) {
          out.add(_Bucket(DateFormat('E', 'th').format(d), daily[d] ?? 0));
        }
        break;
      case Period.month:
        for (var d = range.start;
            d.isBefore(range.end);
            d = d.add(const Duration(days: 1))) {
          out.add(_Bucket('${d.day}', daily[d] ?? 0));
        }
        break;
      case Period.year:
        for (var m = 1; m <= 12; m++) {
          var sum = 0.0;
          daily.forEach((k, v) {
            if (k.year == range.start.year && k.month == m) sum += v;
          });
          out.add(_Bucket(
              DateFormat('MMM', 'th').format(DateTime(range.start.year, m)),
              sum));
        }
        break;
    }
    return out;
  }
}

class _Bucket {
  final String label;
  final double value;
  const _Bucket(this.label, this.value);
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.waves, color: Beach.sandDeep, size: 40),
            const SizedBox(height: 8),
            Text(text,
                style: const TextStyle(color: Beach.inkSoft, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
