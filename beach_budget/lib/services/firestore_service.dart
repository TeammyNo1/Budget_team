import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/debt.dart';
import '../models/plan.dart';
import '../models/transaction.dart';

/// โครงสร้างข้อมูลใน Firestore
///   users/{uid}/settings/main        -> UserSettings
///   users/{uid}/transactions/{id}    -> Tx
///   users/{uid}/debts/{id}           -> Debt
class FirestoreService {
  FirestoreService(this.uid);
  final String uid;

  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _settingsRef =>
      _db.collection('users').doc(uid).collection('settings').doc('main');

  CollectionReference<Map<String, dynamic>> get _txRef =>
      _db.collection('users').doc(uid).collection('transactions');

  CollectionReference<Map<String, dynamic>> get _debtRef =>
      _db.collection('users').doc(uid).collection('debts');

  // ---------- settings ----------

  Stream<UserSettings> watchSettings() =>
      _settingsRef.snapshots().map(UserSettings.fromDoc);

  Future<void> saveSettings(UserSettings s) =>
      _settingsRef.set(s.toMap(), SetOptions(merge: true));

  /// ครั้งแรกที่ล็อกอิน ใส่สูตรตั้งต้นให้เลย จะได้ไม่เริ่มจากหน้าว่าง
  Future<void> seedIfEmpty() async {
    final snap = await _settingsRef.get();
    if (snap.exists && (snap.data()?['seeded'] == true)) return;
    await _settingsRef.set(UserSettings.starter().toMap(), SetOptions(merge: true));

    final debts = await _debtRef.limit(1).get();
    if (debts.docs.isEmpty) {
      final now = DateTime.now();
      for (final d in [
        Debt(id: '', name: 'พี่', principal: 5200, monthlyPlan: 5200, createdAt: now),
        Debt(id: '', name: 'เพื่อน', principal: 800, monthlyPlan: 800, createdAt: now),
        Debt(id: '', name: 'เพื่อนอีกคน', principal: 1500, monthlyPlan: 1500, createdAt: now),
      ]) {
        await _debtRef.add(d.toMap());
      }
    }
  }

  // ---------- transactions ----------

  /// รายการทั้งหมดในช่วงเวลา [from, to)
  Stream<List<Tx>> watchTransactions(DateTime from, DateTime to) {
    return _txRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThan: Timestamp.fromDate(to))
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Tx.fromDoc).toList());
  }

  Stream<List<Tx>> watchRecent({int limit = 50}) {
    return _txRef
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(Tx.fromDoc).toList());
  }

  Future<String> addTransaction(Tx tx) async {
    final ref = await _txRef.add(tx.toMap());
    if (tx.debtId != null) {
      await _applyDebtDelta(tx.debtId!, tx.amount);
    }
    return ref.id;
  }

  Future<void> updateTransaction(Tx before, Tx after) async {
    await _txRef.doc(after.id).set(after.toMap(), SetOptions(merge: false));
    // ปรับยอดหนี้ให้ตรงกับของใหม่
    if (before.debtId != null) {
      await _applyDebtDelta(before.debtId!, -before.amount);
    }
    if (after.debtId != null) {
      await _applyDebtDelta(after.debtId!, after.amount);
    }
  }

  Future<void> deleteTransaction(Tx tx) async {
    await _txRef.doc(tx.id).delete();
    if (tx.debtId != null) {
      await _applyDebtDelta(tx.debtId!, -tx.amount);
    }
  }

  /// เปลี่ยนยอด "จ่ายแล้ว" ของก้อนหนี้แบบ atomic
  Future<void> _applyDebtDelta(String debtId, double delta) async {
    final ref = _debtRef.doc(debtId);
    await _db.runTransaction((t) async {
      final snap = await t.get(ref);
      if (!snap.exists) return;
      final paid = (snap.data()?['paid'] as num?)?.toDouble() ?? 0;
      final next = (paid + delta).clamp(0, double.infinity);
      t.update(ref, {'paid': next});
    });
  }

  // ---------- debts ----------

  Stream<List<Debt>> watchDebts() => _debtRef
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(Debt.fromDoc).toList());

  Future<void> addDebt(Debt d) => _debtRef.add(d.toMap());

  Future<void> updateDebt(Debt d) =>
      _debtRef.doc(d.id).set(d.toMap(), SetOptions(merge: true));

  Future<void> deleteDebt(String id) => _debtRef.doc(id).delete();
}
