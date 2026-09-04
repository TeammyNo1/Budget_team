import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';
import '../widgets/period_switcher.dart';
import '../widgets/tx_tile.dart';
import '../widgets/wave_header.dart';
import 'transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _query = '';
  String? _filterCategory;
  TxType? _filterType;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = _filter(app.transactions);
    final groups = _groupByDay(list);

    return Column(
      children: [
        OceanHeader(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.white),
                  SizedBox(width: 8),
                  Text('รายการทั้งหมด',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 14),
              const PeriodSwitcher(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'ค้นหาจากโน้ตหรือหมวดหมู่',
              prefixIcon: Icon(Icons.search, color: Beach.inkSoft),
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _Filter(
                label: 'ทั้งหมด',
                selected: _filterType == null && _filterCategory == null,
                onTap: () => setState(() {
                  _filterType = null;
                  _filterCategory = null;
                }),
              ),
              _Filter(
                label: 'รายรับ',
                selected: _filterType == TxType.income,
                onTap: () => setState(() {
                  _filterType = TxType.income;
                  _filterCategory = null;
                }),
              ),
              _Filter(
                label: 'รายจ่าย',
                selected: _filterType == TxType.expense,
                onTap: () => setState(() {
                  _filterType = TxType.expense;
                  _filterCategory = null;
                }),
              ),
              for (final c in Categories.expense)
                _Filter(
                  label: c.name,
                  selected: _filterCategory == c.id,
                  onTap: () => setState(() {
                    _filterCategory = _filterCategory == c.id ? null : c.id;
                    _filterType = null;
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: app.loadingTx
              ? const Center(child: CircularProgressIndicator())
              : groups.isEmpty
                  ? const _Empty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      itemCount: groups.length,
                      itemBuilder: (context, i) {
                        final g = groups[i];
                        return _DayGroup(
                          day: g.key,
                          items: g.value,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  List<Tx> _filter(List<Tx> src) {
    return src.where((t) {
      if (_filterType != null && t.type != _filterType) return false;
      if (_filterCategory != null && t.categoryId != _filterCategory) {
        return false;
      }
      if (_query.isEmpty) return true;
      return t.note.toLowerCase().contains(_query) ||
          t.category.name.toLowerCase().contains(_query);
    }).toList();
  }

  List<MapEntry<DateTime, List<Tx>>> _groupByDay(List<Tx> src) {
    final m = <DateTime, List<Tx>>{};
    for (final t in src) {
      final k = DateTime(t.date.year, t.date.month, t.date.day);
      m.putIfAbsent(k, () => []).add(t);
    }
    final entries = m.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return entries;
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.day, required this.items});
  final DateTime day;
  final List<Tx> items;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (s, t) => s + t.signed);
    final today = DateTime.now();
    final isToday = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Row(
              children: [
                Text(
                  isToday
                      ? 'วันนี้'
                      : DateFormat('EEEE d MMM y', 'th').format(day),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Beach.inkSoft,
                  ),
                ),
                const Spacer(),
                Text(
                  '${total >= 0 ? '+' : '−'}${money(total.abs())}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: total >= 0 ? Beach.palm : Beach.coral,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Beach.shell,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Beach.sandDeep),
            ),
            child: Column(
              children: [
                for (final t in items)
                  TxTile(
                    tx: t,
                    showDate: false,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailScreen(tx: t),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? Beach.seaDeep : Beach.shell,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? Beach.seaDeep : Beach.sandDeep),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Beach.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.beach_access, size: 56, color: Beach.sandDeep),
          SizedBox(height: 10),
          Text('ยังไม่มีรายการที่ตรงกับที่เลือก',
              style: TextStyle(color: Beach.inkSoft)),
        ],
      ),
    );
  }
}
