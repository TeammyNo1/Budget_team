import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';
import '../widgets/charts.dart';
import '../widgets/period_switcher.dart';
import '../widgets/section_card.dart';
import '../widgets/tx_tile.dart';
import '../widgets/wave_header.dart';
import 'settings_screen.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = AuthService.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        OceanHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                              fontSize: 13),
                        ),
                        Text(
                          user?.displayName?.split(' ').first ?? 'สวัสดี',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const SettingsScreen())),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(.25),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const PeriodSwitcher(),
              const SizedBox(height: 14),
              _BalanceCard(
                income: app.income,
                expense: app.expense,
                balance: app.balance,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _QuickStats(app: app),
        const SizedBox(height: 12),
        SectionCard(
          title: 'รายจ่ายแยกตามหมวด',
          subtitle: app.range.title,
          child: CategoryDonut(
            data: app.expenseByCategory,
            total: app.expense,
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'รายจ่ายรายวัน',
          subtitle: app.range.period == Period.year ? 'รายเดือน' : null,
          child: DailyBars(range: app.range, daily: app.dailyExpense),
        ),
        const SizedBox(height: 12),
        _RecentList(txs: app.transactions),
      ],
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'อรุณสวัสดิ์ ☀️';
    if (h < 17) return 'สวัสดีตอนบ่าย 🌊';
    if (h < 21) return 'เย็นนี้เป็นไงบ้าง 🌅';
    return 'ดึกแล้วนะ 🌙';
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.income,
    required this.expense,
    required this.balance,
  });

  final double income, expense, balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('คงเหลือในช่วงนี้',
              style: TextStyle(
                  color: Colors.white.withOpacity(.85), fontSize: 12.5)),
          const SizedBox(height: 2),
          Text(
            baht(balance),
            style: TextStyle(
              color: balance < 0 ? const Color(0xFFFFD5CC) : Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.south_west,
                  label: 'รายรับ',
                  value: income,
                  tint: const Color(0xFFB9F0DC),
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white.withOpacity(.25),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.north_east,
                  label: 'รายจ่าย',
                  value: expense,
                  tint: const Color(0xFFFFD0C4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(.8), fontSize: 11.5)),
              Text(
                money(value),
                style: TextStyle(
                    color: tint, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// การ์ดเล็ก ๆ สรุปสถานะเทียบกับแผน
class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final foodSpent = app.spentOn('food');
    final foodBudget = app.foodBudget;
    final debtRemaining =
        app.activeDebts.fold<double>(0, (s, d) => s + d.remaining);
    final perDayLeft = _perDayLeft(app);

    return SizedBox(
      height: 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _StatChip(
            icon: Icons.restaurant,
            label: 'ค่ากิน (${app.range.period.label}นี้)',
            value: '${moneyInt(foodSpent)} / ${moneyInt(foodBudget)}',
            progress: foodBudget <= 0 ? 0 : foodSpent / foodBudget,
            color: Beach.sunset,
          ),
          _StatChip(
            icon: Icons.savings,
            label: 'ใช้ได้อีกวันละ',
            value: perDayLeft == null ? '—' : baht(perDayLeft),
            color: Beach.palm,
          ),
          _StatChip(
            icon: Icons.handshake,
            label: 'หนี้คงเหลือ',
            value: baht(debtRemaining),
            color: Beach.coral,
          ),
          _StatChip(
            icon: Icons.receipt_long,
            label: 'จำนวนรายการ',
            value: '${app.transactions.length}',
            color: Beach.sea,
          ),
        ],
      ),
    );
  }

  /// เงินที่ยังใช้ได้ต่อวันในเดือนนี้ = (งบเดือน − ที่จ่ายไปแล้ว) ÷ วันที่เหลือ
  static double? _perDayLeft(AppState app) {
    final month = DateRange.of(Period.month, DateTime.now());
    if (!app.range.isCurrent) return null;
    final budget = app.monthlyPlanTotal;
    if (budget <= 0) return null;
    final now = DateTime.now();
    final daysLeft = month.end.difference(now).inDays + 1;
    if (daysLeft <= 0) return null;
    // ใช้ยอดจ่ายของช่วงที่กำลังดูได้เฉพาะเมื่อดูรายเดือน
    final spent = app.range.period == Period.month ? app.expense : 0;
    return ((budget - spent) / daysLeft).clamp(0, double.infinity).toDouble();
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.progress,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Beach.shell,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Beach.sandDeep),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Beach.inkSoft),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: Beach.sandDeep,
                valueColor: AlwaysStoppedAnimation(
                    progress! > 1 ? Beach.coral : color),
              ),
            )
          else
            const SizedBox(height: 5),
        ],
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.txs});
  final List<Tx> txs;

  @override
  Widget build(BuildContext context) {
    final recent = txs.take(6).toList();
    return SectionCard(
      title: 'รายการล่าสุด',
      child: recent.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('ยังไม่มีรายการในช่วงนี้ — กดปุ่ม "บันทึก" ได้เลย',
                    style: TextStyle(color: Beach.inkSoft, fontSize: 13)),
              ),
            )
          : Column(
              children: [
                for (final t in recent)
                  TxTile(
                    tx: t,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailScreen(tx: t),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
