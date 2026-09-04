import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/debt.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';
import '../widgets/section_card.dart';
import '../widgets/wave_header.dart';
import 'add_transaction_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final active = app.debts.where((d) => !d.archived && !d.isCleared).toList();
    final cleared = app.debts.where((d) => d.archived || d.isCleared).toList();

    final totalRemaining =
        active.fold<double>(0, (s, d) => s + d.remaining);
    final totalPrincipal =
        app.debts.fold<double>(0, (s, d) => s + d.principal);
    final totalPaid = app.debts.fold<double>(0, (s, d) => s + d.paid);

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        OceanHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('หนี้ที่ต้องเคลียร์',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    onPressed: () => _editDebt(context, null),
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white),
                    tooltip: 'เพิ่มก้อนหนี้',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ยอดคงเหลือทั้งหมด',
                        style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontSize: 12.5)),
                    Text(
                      baht(totalRemaining),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: totalPrincipal <= 0
                            ? 0
                            : (totalPaid / totalPrincipal).clamp(0.0, 1.0),
                        minHeight: 9,
                        backgroundColor: Colors.white.withOpacity(.25),
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFB9F0DC)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'จ่ายไปแล้ว ${money(totalPaid)} จากทั้งหมด ${money(totalPrincipal)}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(.85), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (active.isEmpty)
          SectionCard(
            child: Column(
              children: [
                const Icon(Icons.celebration, size: 40, color: Beach.palm),
                const SizedBox(height: 10),
                const Text('ไม่มีหนี้ค้างแล้ว สบายใจได้เลย 🌴',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => _editDebt(context, null),
                  child: const Text('เพิ่มก้อนหนี้ใหม่'),
                ),
              ],
            ),
          ),
        for (final d in active) ...[
          _DebtCard(debt: d),
          const SizedBox(height: 12),
        ],
        if (cleared.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text('เคลียร์แล้ว',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: Beach.inkSoft)),
          ),
          for (final d in cleared) ...[
            _DebtCard(debt: d, dimmed: true),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt, this.dimmed = false});
  final Debt debt;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? .6 : 1,
      child: SectionCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Beach.coral.withOpacity(.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    debt.isCleared ? Icons.check_circle : Icons.handshake,
                    color: debt.isCleared ? Beach.palm : Beach.coral,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debt.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15.5)),
                      Text(
                        debt.note.isNotEmpty
                            ? debt.note
                            : 'ตั้งต้น ${money(debt.principal)}'
                                '${debt.monthlyPlan > 0 ? ' · ตั้งใจจ่ายเดือนละ ${moneyInt(debt.monthlyPlan)}' : ''}',
                        style: const TextStyle(
                            fontSize: 11.5, color: Beach.inkSoft),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      baht(debt.remaining),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: debt.isCleared ? Beach.palm : Beach.coral,
                      ),
                    ),
                    const Text('คงเหลือ',
                        style: TextStyle(fontSize: 10.5, color: Beach.inkSoft)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: debt.progress,
                minHeight: 7,
                backgroundColor: Beach.sandDeep,
                valueColor: AlwaysStoppedAnimation(
                    debt.isCleared ? Beach.palm : Beach.lagoon),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('จ่ายแล้ว ${money(debt.paid)} (${(debt.progress * 100).round()}%)',
                    style: const TextStyle(
                        fontSize: 11.5, color: Beach.inkSoft)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _editDebt(context, debt),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('แก้ไข', style: TextStyle(fontSize: 12.5)),
                ),
                if (!debt.isCleared)
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: Beach.foam,
                      foregroundColor: Beach.seaDeep,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(
                          presetCategoryId: 'debt',
                          presetDebtId: debt.id,
                          presetAmount: debt.monthlyPlan > 0
                              ? (debt.monthlyPlan < debt.remaining
                                  ? debt.monthlyPlan
                                  : debt.remaining)
                              : debt.remaining,
                        ),
                      ),
                    ),
                    child: const Text('จ่าย', style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ฟอร์มเพิ่ม/แก้ไขก้อนหนี้
Future<void> _editDebt(BuildContext context, Debt? debt) async {
  final app = context.read<AppState>();
  final nameCtrl = TextEditingController(text: debt?.name ?? '');
  final principalCtrl =
      TextEditingController(text: debt == null ? '' : moneyPlain(debt.principal));
  final paidCtrl =
      TextEditingController(text: debt == null ? '0' : moneyPlain(debt.paid));
  final planCtrl = TextEditingController(
      text: debt == null ? '' : moneyPlain(debt.monthlyPlan));
  final noteCtrl = TextEditingController(text: debt?.note ?? '');

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Beach.sand,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(debt == null ? 'เพิ่มก้อนหนี้' : 'แก้ไขก้อนหนี้',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'เจ้าหนี้ / ชื่อก้อนหนี้',
                  hintText: 'เช่น พี่, เพื่อน A'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: principalCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              decoration: const InputDecoration(labelText: 'ยอดตั้งต้น (บาท)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: paidCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              decoration: const InputDecoration(
                labelText: 'จ่ายไปแล้ว (บาท)',
                helperText: 'ปกติแอปจะบวกให้เองเมื่อบันทึกรายการ "จ่ายหนี้"',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: planCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              decoration: const InputDecoration(
                  labelText: 'ตั้งใจจ่ายเดือนละ (บาท)',
                  helperText: 'ใช้คำนวณในหน้าสูตรแบ่งรายจ่าย'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'โน้ต'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (debt != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await app.db.deleteDebt(debt.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Beach.coral),
                      child: const Text('ลบ'),
                    ),
                  ),
                if (debt != null) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final principal =
                          double.tryParse(principalCtrl.text.trim()) ?? 0;
                      final paid = double.tryParse(paidCtrl.text.trim()) ?? 0;
                      final plan = double.tryParse(planCtrl.text.trim()) ?? 0;

                      if (debt == null) {
                        await app.db.addDebt(Debt(
                          id: '',
                          name: name,
                          principal: principal,
                          paid: paid,
                          monthlyPlan: plan,
                          note: noteCtrl.text.trim(),
                          createdAt: DateTime.now(),
                        ));
                      } else {
                        await app.db.updateDebt(Debt(
                          id: debt.id,
                          name: name,
                          principal: principal,
                          paid: paid,
                          monthlyPlan: plan,
                          note: noteCtrl.text.trim(),
                          createdAt: debt.createdAt,
                          archived: debt.archived,
                        ));
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('บันทึก'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

String moneyPlain(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
