import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';
import '../widgets/section_card.dart';
import '../widgets/wave_header.dart';
import 'settings_screen.dart';

/// หน้า "สูตรแบ่งรายจ่าย" — เทียบแผนกับที่จ่ายจริงของ *เดือนปัจจุบัน*
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final month = DateRange.of(Period.month, DateTime.now());

    return StreamBuilder<List<Tx>>(
      stream: app.db.watchTransactions(month.start, month.end),
      builder: (context, snap) {
        final txs = snap.data ?? const <Tx>[];
        double spent(String catId) => txs
            .where((t) => t.type == TxType.expense && t.categoryId == catId)
            .fold<double>(0, (s, t) => s + t.amount);

        final s = app.settings;
        final foodBudget =
            month.workdays * s.foodWorkday + month.holidays * s.foodHoliday;
        final debtBudget = app.debtPlanTotal;
        final planTotal = s.linesTotal + foodBudget + debtBudget;
        final saving = s.netIncome - planTotal;

        final totalSpent = txs
            .where((t) => t.type == TxType.expense)
            .fold<double>(0, (a, t) => a + t.amount);

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
                        child: Text(
                          'สูตรแบ่งรายจ่าย',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                        icon: const Icon(Icons.tune, color: Colors.white),
                        tooltip: 'แก้สูตร',
                      ),
                    ],
                  ),
                  Text(
                    month.title,
                    style: TextStyle(color: Colors.white.withOpacity(.85)),
                  ),
                  const SizedBox(height: 16),
                  _WaterfallCard(
                    salary: s.salary,
                    sso: s.socialSecurity,
                    other: s.otherDeduction,
                    net: s.netIncome,
                    planned: planTotal,
                    saving: saving,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'ใช้ไปแล้วเดือนนี้',
              subtitle:
                  'ผ่านมา ${(month.elapsedFraction * 100).round()}% ของเดือน',
              child: _OverallBar(
                spent: totalSpent,
                budget: planTotal,
                elapsed: month.elapsedFraction,
              ),
            ),
            const SizedBox(height: 12),

            SectionCard(
              title: 'รายจ่ายคงที่',
              trailing: Text(baht(s.linesTotal),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: Beach.seaDeep)),
              child: Column(
                children: [
                  if (s.lines.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('ยังไม่ได้ตั้งสูตร — กดไอคอนตั้งค่าด้านบน',
                          style: TextStyle(color: Beach.inkSoft)),
                    ),
                  for (final l in s.lines)
                    _PlanRow(
                      label: l.label,
                      hint: l.isRange ? 'ประมาณ ${l.rangeText}' : null,
                      icon: Categories.byId(l.categoryId).icon,
                      color: Beach.categoryColor(
                          Categories.colorIndexOf(l.categoryId)),
                      budget: l.amount,
                      spent: spent(l.categoryId),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            SectionCard(
              title: 'ค่ากิน',
              subtitle:
                  'วันทำงาน ${month.workdays} วัน × ${moneyInt(s.foodWorkday)} + วันหยุด ${month.holidays} วัน × ${moneyInt(s.foodHoliday)}',
              trailing: Text(baht(foodBudget),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: Beach.seaDeep)),
              child: _PlanRow(
                label: 'ค่ากินทั้งเดือน',
                icon: Icons.restaurant,
                color: Beach.sunset,
                budget: foodBudget,
                spent: spent('food'),
              ),
            ),
            const SizedBox(height: 12),

            SectionCard(
              title: 'จ่ายหนี้',
              trailing: Text(baht(debtBudget),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: Beach.seaDeep)),
              child: Column(
                children: [
                  if (app.activeDebts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('ไม่มีหนี้ค้าง 🎉',
                          style: TextStyle(color: Beach.inkSoft)),
                    ),
                  for (final d in app.activeDebts)
                    _PlanRow(
                      label: d.name,
                      hint: 'ยอดคงเหลือ ${money(d.remaining)}',
                      icon: Icons.handshake,
                      color: Beach.coral,
                      budget: d.monthlyPlan > 0 ? d.monthlyPlan : d.remaining,
                      spent: txs
                          .where((t) => t.debtId == d.id)
                          .fold<double>(0, (a, t) => a + t.amount),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            SectionCard(
              title: 'เหลือเก็บตามแผน',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (saving >= 0 ? Beach.palm : Beach.coral)
                          .withOpacity(.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      saving >= 0 ? Icons.savings : Icons.warning_amber,
                      color: saving >= 0 ? Beach.palm : Beach.coral,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          baht(saving),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: saving >= 0 ? Beach.palm : Beach.coral,
                          ),
                        ),
                        Text(
                          saving >= 0
                              ? 'รายได้สุทธิ ${money(s.netIncome)} − แผนจ่าย ${money(planTotal)}'
                              : 'แผนจ่ายเกินรายได้อยู่ ${money(saving.abs())} — ลองลดบางก้อนดู',
                          style: const TextStyle(
                              fontSize: 12, color: Beach.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WaterfallCard extends StatelessWidget {
  const _WaterfallCard({
    required this.salary,
    required this.sso,
    required this.other,
    required this.net,
    required this.planned,
    required this.saving,
  });

  final double salary, sso, other, net, planned, saving;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.25)),
      ),
      child: Column(
        children: [
          _line('เงินเดือน', salary, bold: true),
          _line('หักประกันสังคม', -sso),
          if (other > 0) _line('หักอื่น ๆ', -other),
          Divider(color: Colors.white.withOpacity(.3), height: 18),
          _line('รายได้สุทธิ', net, bold: true),
          _line('แผนรายจ่ายทั้งเดือน', -planned),
          Divider(color: Colors.white.withOpacity(.3), height: 18),
          _line('เหลือเก็บ', saving, bold: true, highlight: true),
        ],
      ),
    );
  }

  Widget _line(String label, double v,
      {bool bold = false, bool highlight = false}) {
    final negative = v < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(bold ? 1 : .82),
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            '${negative ? '−' : ''}${money(v.abs())}',
            style: TextStyle(
              color: highlight
                  ? (v >= 0 ? const Color(0xFFB9F0DC) : const Color(0xFFFFD0C4))
                  : Colors.white,
              fontSize: bold ? 16 : 13.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverallBar extends StatelessWidget {
  const _OverallBar({
    required this.spent,
    required this.budget,
    required this.elapsed,
  });

  final double spent, budget, elapsed;

  @override
  Widget build(BuildContext context) {
    final ratio = budget <= 0 ? 0.0 : (spent / budget);
    final onTrack = ratio <= elapsed + 0.05;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(baht(spent),
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(width: 6),
            Text('/ ${money(budget)}',
                style: const TextStyle(color: Beach.inkSoft, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (context, c) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: Beach.sandDeep,
                  valueColor: AlwaysStoppedAnimation(
                      ratio > 1 ? Beach.coral : (onTrack ? Beach.sea : Beach.sunset)),
                ),
              ),
              // เส้นบอกว่า "ควรจะใช้ไปเท่าไหร่แล้ว" ตามวันที่ผ่านไป
              Positioned(
                left: (c.maxWidth * elapsed).clamp(0.0, c.maxWidth - 2),
                top: -3,
                child: Container(width: 2, height: 18, color: Beach.ink),
              ),
            ],
          );
        }),
        const SizedBox(height: 10),
        Text(
          budget <= 0
              ? 'ตั้งสูตรก่อนเพื่อดูว่าใช้เร็วไปไหม'
              : ratio > 1
                  ? 'เกินแผนไปแล้ว ${money(spent - budget)}'
                  : onTrack
                      ? 'ยังอยู่ในแผน — เหลืออีก ${money(budget - spent)}'
                      : 'ใช้เร็วกว่าแผนนิดหน่อย เหลือ ${money(budget - spent)}',
          style: TextStyle(
            fontSize: 12.5,
            color: ratio > 1 ? Beach.coral : Beach.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.budget,
    required this.spent,
    this.hint,
  });

  final String label;
  final String? hint;
  final IconData icon;
  final Color color;
  final double budget, spent;

  @override
  Widget build(BuildContext context) {
    final ratio = budget <= 0 ? 0.0 : spent / budget;
    final over = spent > budget;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w600)),
                    if (hint != null)
                      Text(hint!,
                          style: const TextStyle(
                              fontSize: 11, color: Beach.inkSoft)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${moneyInt(spent)} / ${moneyInt(budget)}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: over ? Beach.coral : Beach.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Beach.sandDeep,
              valueColor:
                  AlwaysStoppedAnimation(over ? Beach.coral : color),
            ),
          ),
        ],
      ),
    );
  }
}
