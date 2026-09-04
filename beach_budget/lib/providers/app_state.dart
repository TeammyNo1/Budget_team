import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/category.dart';
import '../models/debt.dart';
import '../models/plan.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../utils/period.dart';

/// เก็บสถานะรวมของแอป: ช่วงเวลาที่กำลังดู, รายการ, หนี้, การตั้งค่า
class AppState extends ChangeNotifier {
  AppState(this.uid)
      : db = FirestoreService(uid),
        storage = StorageService(uid) {
    _range = DateRange.of(Period.month, DateTime.now());
    _listenSettings();
    _listenDebts();
    _listenTransactions();
    db.seedIfEmpty();
  }

  final String uid;
  final FirestoreService db;
  final StorageService storage;

  late DateRange _range;
  DateRange get range => _range;

  UserSettings _settings = const UserSettings();
  UserSettings get settings => _settings;

  List<Debt> _debts = const [];
  List<Debt> get debts => _debts;
  List<Debt> get activeDebts =>
      _debts.where((d) => !d.archived && !d.isCleared).toList();

  List<Tx> _txs = const [];
  List<Tx> get transactions => _txs;

  bool _loadingTx = true;
  bool get loadingTx => _loadingTx;

  StreamSubscription? _settingsSub, _debtsSub, _txSub;

  void _listenSettings() {
    _settingsSub = db.watchSettings().listen((s) {
      _settings = s;
      notifyListeners();
    });
  }

  void _listenDebts() {
    _debtsSub = db.watchDebts().listen((d) {
      _debts = d;
      notifyListeners();
    });
  }

  void _listenTransactions() {
    _txSub?.cancel();
    _loadingTx = true;
    notifyListeners();
    _txSub = db.watchTransactions(_range.start, _range.end).listen((list) {
      _txs = list;
      _loadingTx = false;
      notifyListeners();
    });
  }

  void setPeriod(Period p) {
    _range = DateRange.of(p, DateTime.now());
    _listenTransactions();
  }

  void shiftRange(int steps) {
    _range = _range.shift(steps);
    _listenTransactions();
  }

  void jumpToToday() {
    _range = DateRange.of(_range.period, DateTime.now());
    _listenTransactions();
  }

  // ---------- ตัวเลขสรุป ----------

  double get income => _txs
      .where((t) => t.type == TxType.income)
      .fold<double>(0, (s, t) => s + t.amount);

  double get expense => _txs
      .where((t) => t.type == TxType.expense)
      .fold<double>(0, (s, t) => s + t.amount);

  double get balance => income - expense;

  /// รวมรายจ่ายแยกตามหมวด เรียงจากมากไปน้อย
  List<MapEntry<String, double>> get expenseByCategory {
    final m = <String, double>{};
    for (final t in _txs) {
      if (t.type != TxType.expense) continue;
      m[t.categoryId] = (m[t.categoryId] ?? 0) + t.amount;
    }
    final list = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  /// ยอดจ่ายจริงของหมวดหนึ่ง ในช่วงที่กำลังดู
  double spentOn(String categoryId) => _txs
      .where((t) => t.type == TxType.expense && t.categoryId == categoryId)
      .fold<double>(0, (s, t) => s + t.amount);

  /// รายจ่ายรวมรายวันในช่วงปัจจุบัน (ใช้วาดกราฟแท่ง)
  Map<DateTime, double> get dailyExpense {
    final m = <DateTime, double>{};
    for (final t in _txs) {
      if (t.type != TxType.expense) continue;
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      m[key] = (m[key] ?? 0) + t.amount;
    }
    return m;
  }

  /// งบค่ากินของช่วงนี้ = วันทำงาน×เรทวันทำงาน + วันหยุด×เรทวันหยุด
  double get foodBudget =>
      _range.workdays * _settings.foodWorkday +
      _range.holidays * _settings.foodHoliday;

  /// งบหนี้ต่อเดือนตามแผน
  double get debtPlanTotal =>
      activeDebts.fold<double>(0, (s, d) => s + (d.monthlyPlan > 0 ? d.monthlyPlan : 0));

  /// งบรายจ่ายรวมทั้งเดือนตามสูตร (สูตรคงที่ + ค่ากิน + หนี้)
  double get monthlyPlanTotal =>
      _settings.linesTotal + _monthFoodBudget + debtPlanTotal;

  double get _monthFoodBudget {
    final m = DateRange.of(Period.month, DateTime.now());
    return m.workdays * _settings.foodWorkday +
        m.holidays * _settings.foodHoliday;
  }

  /// เหลือเก็บตามสูตร = รายได้สุทธิ − งบรายจ่ายทั้งหมด
  double get plannedSaving => _settings.netIncome - monthlyPlanTotal;

  Debt? debtById(String? id) {
    if (id == null) return null;
    for (final d in _debts) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _debtsSub?.cancel();
    _txSub?.cancel();
    super.dispose();
  }
}
