import 'package:intl/intl.dart';

enum Period { day, week, month, year }

extension PeriodX on Period {
  String get label => switch (this) {
        Period.day => 'วัน',
        Period.week => 'สัปดาห์',
        Period.month => 'เดือน',
        Period.year => 'ปี',
      };
}

/// ช่วงเวลาแบบ [start, end) พร้อมวิธีเลื่อนไปข้างหน้า/ถอยหลัง
class DateRange {
  final DateTime start;
  final DateTime end;
  final Period period;

  const DateRange(this.start, this.end, this.period);

  factory DateRange.of(Period p, DateTime anchor) {
    final a = DateTime(anchor.year, anchor.month, anchor.day);
    switch (p) {
      case Period.day:
        return DateRange(a, a.add(const Duration(days: 1)), p);
      case Period.week:
        // สัปดาห์เริ่มวันจันทร์
        final start = a.subtract(Duration(days: a.weekday - 1));
        return DateRange(start, start.add(const Duration(days: 7)), p);
      case Period.month:
        final start = DateTime(a.year, a.month, 1);
        return DateRange(start, DateTime(a.year, a.month + 1, 1), p);
      case Period.year:
        return DateRange(DateTime(a.year, 1, 1), DateTime(a.year + 1, 1, 1), p);
    }
  }

  DateRange shift(int steps) {
    switch (period) {
      case Period.day:
        return DateRange.of(period, start.add(Duration(days: steps)));
      case Period.week:
        return DateRange.of(period, start.add(Duration(days: 7 * steps)));
      case Period.month:
        return DateRange.of(period, DateTime(start.year, start.month + steps, 1));
      case Period.year:
        return DateRange.of(period, DateTime(start.year + steps, 1, 1));
    }
  }

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  bool get isCurrent => contains(DateTime.now());

  /// จำนวนวันในช่วง
  int get days => end.difference(start).inDays;

  /// จำนวนวันจันทร์–ศุกร์ในช่วง (ใช้คิดค่ากิน)
  int get workdays {
    var n = 0;
    for (var d = start; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      if (d.weekday <= DateTime.friday) n++;
    }
    return n;
  }

  int get holidays => days - workdays;

  /// เศษวันที่ผ่านมาแล้วของช่วงนี้ (0–1) ใช้เทียบว่าจ่ายเร็วไปไหม
  double get elapsedFraction {
    final now = DateTime.now();
    if (!now.isAfter(start)) return 0;
    if (!now.isBefore(end)) return 1;
    return now.difference(start).inMinutes / end.difference(start).inMinutes;
  }

  String get title {
    final th = 'th';
    switch (period) {
      case Period.day:
        return DateFormat('d MMMM y', th).format(start);
      case Period.week:
        final last = end.subtract(const Duration(days: 1));
        if (start.month == last.month) {
          return '${DateFormat('d', th).format(start)}–${DateFormat('d MMM y', th).format(last)}';
        }
        return '${DateFormat('d MMM', th).format(start)} – ${DateFormat('d MMM y', th).format(last)}';
      case Period.month:
        return DateFormat('MMMM y', th).format(start);
      case Period.year:
        return DateFormat('y', th).format(start);
    }
  }
}

final _money = NumberFormat('#,##0.##', 'th');
final _moneyInt = NumberFormat('#,##0', 'th');

String money(num v) => _money.format(v);
String moneyInt(num v) => _moneyInt.format(v);
String baht(num v) => '฿${_money.format(v)}';
