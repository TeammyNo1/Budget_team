import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.tx});
  final Tx tx;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    // ดึงเวอร์ชันล่าสุดจาก state เผื่อเพิ่งแก้ไข
    final current = app.transactions.firstWhere(
      (t) => t.id == tx.id,
      orElse: () => tx,
    );
    final isIncome = current.type == TxType.income;
    final color = isIncome ? Beach.palm : Beach.coral;
    final debt = app.debtById(current.debtId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddTransactionScreen(existing: current),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Beach.coral),
            onPressed: () => _confirmDelete(context, app, current),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(current.category.icon, size: 30, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  '${isIncome ? '+' : '−'}${baht(current.amount)}',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  '${current.type.label} · ${current.category.name}',
                  style: const TextStyle(color: Beach.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _Row(
            icon: Icons.event,
            label: 'วันที่',
            value: DateFormat('EEEE d MMMM y · HH:mm', 'th')
                .format(current.date),
          ),
          if (current.note.isNotEmpty)
            _Row(icon: Icons.notes, label: 'โน้ต', value: current.note),
          if (debt != null)
            _Row(
              icon: Icons.handshake,
              label: 'ตัดจากหนี้',
              value: '${debt.name} · เหลือ ${baht(debt.remaining)}',
            ),
          _Row(
            icon: Icons.schedule,
            label: 'บันทึกเมื่อ',
            value: DateFormat('d MMM y HH:mm', 'th').format(current.createdAt),
          ),
          if (current.slipUrl != null) ...[
            const SizedBox(height: 20),
            const Text('สลิป / ใบเสร็จ',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.black,
                  insetPadding: const EdgeInsets.all(12),
                  child: InteractiveViewer(
                    child: Image.network(current.slipUrl!),
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  current.slipUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Beach.sandDeep,
                    alignment: Alignment.center,
                    child: const Text('โหลดรูปไม่สำเร็จ'),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AppState app, Tx tx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบรายการนี้?'),
        content: const Text(
            'ยอดจะถูกนำออกจากสรุป และถ้าผูกกับหนี้ ยอดหนี้จะถูกคืนกลับให้'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ', style: TextStyle(color: Beach.coral)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await app.storage.deleteSlip(tx.slipPath);
    await app.db.deleteTransaction(tx);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Beach.inkSoft),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Beach.inkSoft)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
