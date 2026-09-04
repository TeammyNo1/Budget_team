import 'package:flutter/material.dart';

enum TxType { income, expense }

extension TxTypeX on TxType {
  String get key => this == TxType.income ? 'income' : 'expense';
  String get label => this == TxType.income ? 'รายรับ' : 'รายจ่าย';
  static TxType fromKey(String? k) =>
      k == 'income' ? TxType.income : TxType.expense;
}

/// หมวดหมู่ถูกฝังไว้ในแอป (ไม่ต้องแก้ผ่าน Firestore) เพื่อความง่าย
class Category {
  final String id;
  final String name;
  final IconData icon;
  final TxType type;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
}

class Categories {
  static const expense = <Category>[
    Category(id: 'rent', name: 'ค่าหอ', icon: Icons.apartment, type: TxType.expense),
    Category(id: 'electric', name: 'ค่าไฟ', icon: Icons.bolt, type: TxType.expense),
    Category(id: 'water', name: 'ค่าน้ำ', icon: Icons.water_drop, type: TxType.expense),
    Category(id: 'fuel', name: 'ค่าน้ำมัน', icon: Icons.local_gas_station, type: TxType.expense),
    Category(id: 'laundry', name: 'ซักผ้า', icon: Icons.local_laundry_service, type: TxType.expense),
    Category(id: 'food', name: 'ค่ากิน', icon: Icons.restaurant, type: TxType.expense),
    Category(id: 'supplies', name: 'ของใช้', icon: Icons.shopping_basket, type: TxType.expense),
    Category(id: 'debt', name: 'จ่ายหนี้', icon: Icons.handshake, type: TxType.expense),
    Category(id: 'health', name: 'สุขภาพ', icon: Icons.medical_services, type: TxType.expense),
    Category(id: 'fun', name: 'เที่ยว/บันเทิง', icon: Icons.beach_access, type: TxType.expense),
    Category(id: 'saving', name: 'เก็บออม', icon: Icons.savings, type: TxType.expense),
    Category(id: 'other_expense', name: 'อื่น ๆ', icon: Icons.more_horiz, type: TxType.expense),
  ];

  static const income = <Category>[
    Category(id: 'salary', name: 'เงินเดือน', icon: Icons.payments, type: TxType.income),
    Category(id: 'ot', name: 'OT / เบี้ยเลี้ยง', icon: Icons.more_time, type: TxType.income),
    Category(id: 'bonus', name: 'โบนัส', icon: Icons.card_giftcard, type: TxType.income),
    Category(id: 'side', name: 'งานเสริม', icon: Icons.work_outline, type: TxType.income),
    Category(id: 'refund', name: 'ได้เงินคืน', icon: Icons.reply, type: TxType.income),
    Category(id: 'other_income', name: 'อื่น ๆ', icon: Icons.more_horiz, type: TxType.income),
  ];

  static List<Category> of(TxType type) =>
      type == TxType.income ? income : expense;

  static const _fallback = Category(
    id: 'unknown',
    name: 'ไม่ระบุ',
    icon: Icons.help_outline,
    type: TxType.expense,
  );

  static Category byId(String id) {
    for (final c in expense) {
      if (c.id == id) return c;
    }
    for (final c in income) {
      if (c.id == id) return c;
    }
    return _fallback;
  }

  /// ดัชนีสีคงที่ต่อหมวด เพื่อให้กราฟใช้สีเดิมเสมอ
  static int colorIndexOf(String id) {
    final i = expense.indexWhere((c) => c.id == id);
    if (i >= 0) return i;
    final j = income.indexWhere((c) => c.id == id);
    return j >= 0 ? j + 3 : 0;
  }
}
