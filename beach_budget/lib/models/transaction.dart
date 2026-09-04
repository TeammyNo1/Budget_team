import 'package:cloud_firestore/cloud_firestore.dart';

import 'category.dart';

class Tx {
  final String id;
  final TxType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String note;
  final String? slipUrl; // รูปสลิปใน Firebase Storage
  final String? slipPath; // path ใน Storage ไว้ลบตอนลบรายการ
  final String? debtId; // ถ้าเป็นการจ่ายหนี้ ผูกกับก้อนหนี้ไหน
  final DateTime createdAt;

  const Tx({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note = '',
    this.slipUrl,
    this.slipPath,
    this.debtId,
    required this.createdAt,
  });

  /// รายจ่ายเป็นลบ รายรับเป็นบวก — ใช้รวมยอดคงเหลือ
  double get signed => type == TxType.income ? amount : -amount;

  Category get category => Categories.byId(categoryId);

  factory Tx.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Tx(
      id: doc.id,
      type: TxTypeX.fromKey(d['type'] as String?),
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      categoryId: d['categoryId'] as String? ?? 'other_expense',
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: d['note'] as String? ?? '',
      slipUrl: d['slipUrl'] as String?,
      slipPath: d['slipPath'] as String?,
      debtId: d['debtId'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.key,
        'amount': amount,
        'categoryId': categoryId,
        'date': Timestamp.fromDate(date),
        'note': note,
        'slipUrl': slipUrl,
        'slipPath': slipPath,
        'debtId': debtId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  Tx copyWith({
    TxType? type,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    String? slipUrl,
    String? slipPath,
    String? debtId,
    bool clearSlip = false,
    bool clearDebt = false,
  }) {
    return Tx(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      slipUrl: clearSlip ? null : (slipUrl ?? this.slipUrl),
      slipPath: clearSlip ? null : (slipPath ?? this.slipPath),
      debtId: clearDebt ? null : (debtId ?? this.debtId),
      createdAt: createdAt,
    );
  }
}
