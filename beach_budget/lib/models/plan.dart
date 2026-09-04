import 'package:cloud_firestore/cloud_firestore.dart';

/// หนึ่งบรรทัดใน "สูตรแบ่งรายจ่าย"
class PlanLine {
  final String id;
  final String label; // ชื่อที่แสดง เช่น "ค่าไฟ"
  final String categoryId; // ผูกกับหมวดไหน ใช้เทียบกับที่จ่ายจริง
  final double amount; // ยอดที่กันไว้ต่อเดือน
  final double? minAmount; // ช่วงประมาณการ (ถ้ามี) เช่น ค่าไฟ 1500-2000
  final double? maxAmount;

  const PlanLine({
    required this.id,
    required this.label,
    required this.categoryId,
    required this.amount,
    this.minAmount,
    this.maxAmount,
  });

  bool get isRange => minAmount != null && maxAmount != null;

  String get rangeText =>
      isRange ? '${minAmount!.toStringAsFixed(0)}–${maxAmount!.toStringAsFixed(0)}' : '';

  factory PlanLine.fromMap(Map<String, dynamic> d) => PlanLine(
        id: d['id'] as String? ?? UniqueKeyish.next(),
        label: d['label'] as String? ?? '',
        categoryId: d['categoryId'] as String? ?? 'other_expense',
        amount: (d['amount'] as num?)?.toDouble() ?? 0,
        minAmount: (d['minAmount'] as num?)?.toDouble(),
        maxAmount: (d['maxAmount'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'categoryId': categoryId,
        'amount': amount,
        'minAmount': minAmount,
        'maxAmount': maxAmount,
      };

  PlanLine copyWith({
    String? label,
    String? categoryId,
    double? amount,
    double? minAmount,
    double? maxAmount,
  }) =>
      PlanLine(
        id: id,
        label: label ?? this.label,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        minAmount: minAmount ?? this.minAmount,
        maxAmount: maxAmount ?? this.maxAmount,
      );
}

/// ตัวช่วยสร้าง id สั้น ๆ ฝั่ง client
class UniqueKeyish {
  static int _n = 0;
  static String next() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_n++}';
}

/// การตั้งค่าทั้งหมดของผู้ใช้ (เก็บเป็น 1 เอกสาร)
class UserSettings {
  final double salary; // เงินเดือนก่อนหัก
  final double socialSecurity; // ประกันสังคม
  final double otherDeduction; // หักอื่น ๆ
  final double foodWorkday; // ค่ากินต่อวันทำงาน
  final double foodHoliday; // ค่ากินต่อวันหยุด
  final int payday; // เงินเดือนออกวันที่
  final List<PlanLine> lines; // สูตรแบ่งรายจ่าย (ไม่รวมค่ากิน/หนี้)
  final bool seeded;

  const UserSettings({
    this.salary = 0,
    this.socialSecurity = 0,
    this.otherDeduction = 0,
    this.foodWorkday = 150,
    this.foodHoliday = 250,
    this.payday = 25,
    this.lines = const [],
    this.seeded = false,
  });

  double get netIncome =>
      (salary - socialSecurity - otherDeduction).clamp(0, double.infinity);

  /// ยอดรวมของสูตร (ไม่รวมค่ากินและหนี้ ซึ่งคำนวณแยก)
  double get linesTotal =>
      lines.fold<double>(0, (s, l) => s + l.amount);

  factory UserSettings.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return UserSettings(
      salary: (d['salary'] as num?)?.toDouble() ?? 0,
      socialSecurity: (d['socialSecurity'] as num?)?.toDouble() ?? 0,
      otherDeduction: (d['otherDeduction'] as num?)?.toDouble() ?? 0,
      foodWorkday: (d['foodWorkday'] as num?)?.toDouble() ?? 150,
      foodHoliday: (d['foodHoliday'] as num?)?.toDouble() ?? 250,
      payday: (d['payday'] as num?)?.toInt() ?? 25,
      seeded: d['seeded'] as bool? ?? false,
      lines: ((d['lines'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => PlanLine.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'salary': salary,
        'socialSecurity': socialSecurity,
        'otherDeduction': otherDeduction,
        'foodWorkday': foodWorkday,
        'foodHoliday': foodHoliday,
        'payday': payday,
        'seeded': seeded,
        'lines': lines.map((l) => l.toMap()).toList(),
      };

  UserSettings copyWith({
    double? salary,
    double? socialSecurity,
    double? otherDeduction,
    double? foodWorkday,
    double? foodHoliday,
    int? payday,
    List<PlanLine>? lines,
    bool? seeded,
  }) =>
      UserSettings(
        salary: salary ?? this.salary,
        socialSecurity: socialSecurity ?? this.socialSecurity,
        otherDeduction: otherDeduction ?? this.otherDeduction,
        foodWorkday: foodWorkday ?? this.foodWorkday,
        foodHoliday: foodHoliday ?? this.foodHoliday,
        payday: payday ?? this.payday,
        lines: lines ?? this.lines,
        seeded: seeded ?? this.seeded,
      );

  /// ค่าเริ่มต้นที่กรอกไว้ให้แล้ว — ผู้ใช้แก้ตัวเลขได้ในหน้าตั้งค่า
  static UserSettings starter() => UserSettings(
        salary: 26000,
        socialSecurity: 875,
        otherDeduction: 0,
        foodWorkday: 150,
        foodHoliday: 250,
        payday: 25,
        seeded: true,
        lines: [
          const PlanLine(id: 'p_rent', label: 'ค่าหอ', categoryId: 'rent', amount: 4000),
          const PlanLine(
              id: 'p_elec',
              label: 'ค่าไฟ',
              categoryId: 'electric',
              amount: 1750,
              minAmount: 1500,
              maxAmount: 2000),
          const PlanLine(id: 'p_water', label: 'ค่าน้ำ', categoryId: 'water', amount: 100),
          const PlanLine(id: 'p_fuel', label: 'ค่าน้ำมัน', categoryId: 'fuel', amount: 300),
          const PlanLine(
              id: 'p_laundry',
              label: 'ซักผ้า (ซัก 60 + อบ 50 × 4 สัปดาห์)',
              categoryId: 'laundry',
              amount: 440),
          const PlanLine(
              id: 'p_supplies',
              label: 'ของใช้ (สบู่ ยาสระผม ผงซักฟอก)',
              categoryId: 'supplies',
              amount: 650,
              minAmount: 500,
              maxAmount: 800),
        ],
      );
}
