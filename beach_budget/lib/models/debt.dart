import 'package:cloud_firestore/cloud_firestore.dart';

/// ก้อนหนี้ที่ติดตามยอดคงเหลือ เช่น "พี่ 5,200"
class Debt {
  final String id;
  final String name; // เจ้าหนี้ เช่น พี่ / เพื่อน A
  final double principal; // ยอดตั้งต้น
  final double paid; // จ่ายไปแล้วสะสม
  final double monthlyPlan; // ตั้งใจจ่ายเดือนละเท่าไหร่ (0 = ไม่กำหนด)
  final String note;
  final DateTime createdAt;
  final bool archived;

  const Debt({
    required this.id,
    required this.name,
    required this.principal,
    this.paid = 0,
    this.monthlyPlan = 0,
    this.note = '',
    required this.createdAt,
    this.archived = false,
  });

  double get remaining => (principal - paid).clamp(0, double.infinity);
  bool get isCleared => remaining <= 0.004;
  double get progress =>
      principal <= 0 ? 1 : (paid / principal).clamp(0.0, 1.0);

  factory Debt.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Debt(
      id: doc.id,
      name: d['name'] as String? ?? 'ไม่ระบุ',
      principal: (d['principal'] as num?)?.toDouble() ?? 0,
      paid: (d['paid'] as num?)?.toDouble() ?? 0,
      monthlyPlan: (d['monthlyPlan'] as num?)?.toDouble() ?? 0,
      note: d['note'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      archived: d['archived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'principal': principal,
        'paid': paid,
        'monthlyPlan': monthlyPlan,
        'note': note,
        'createdAt': Timestamp.fromDate(createdAt),
        'archived': archived,
      };
}
