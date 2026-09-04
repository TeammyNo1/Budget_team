import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/plan.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserSettings _draft = const UserSettings();
  bool _ready = false;
  bool _saving = false;

  /// รับค่าจาก Firestore ครั้งแรกที่ข้อมูลมาถึง แล้วปล่อยให้ผู้ใช้แก้ในเครื่องต่อ
  void _syncOnce(UserSettings live) {
    if (_ready) return;
    if (live.seeded || live.salary > 0 || live.lines.isNotEmpty) {
      _draft = live;
      _ready = true;
    } else {
      _draft = live;
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<AppState>().db.saveSettings(_draft.copyWith(seeded: true));
    if (mounted) {
      setState(() => _saving = false);
      navigator.pop();
      messenger
          .showSnackBar(const SnackBar(content: Text('บันทึกการตั้งค่าแล้ว')));
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncOnce(context.watch<AppState>().settings);

    final user = AuthService.instance.currentUser;
    final month = DateRange.of(Period.month, DateTime.now());
    final foodBudget = month.workdays * _draft.foodWorkday +
        month.holidays * _draft.foodHoliday;

    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          SectionCard(
            title: 'บัญชี',
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Beach.foam,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, color: Beach.sea)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'ผู้ใช้',
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                      Text(user?.email ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: Beach.inkSoft)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await AuthService.instance.signOut();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('ออกจากระบบ',
                      style: TextStyle(color: Beach.coral)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: 'รายได้',
            subtitle: 'รายได้สุทธิ ${baht(_draft.netIncome)}',
            child: Column(
              children: [
                _NumField(
                  label: 'เงินเดือน (ก่อนหัก)',
                  value: _draft.salary,
                  onChanged: (v) =>
                      setState(() => _draft = _draft.copyWith(salary: v)),
                ),
                const SizedBox(height: 12),
                _NumField(
                  label: 'หักประกันสังคม',
                  value: _draft.socialSecurity,
                  onChanged: (v) => setState(
                      () => _draft = _draft.copyWith(socialSecurity: v)),
                ),
                const SizedBox(height: 12),
                _NumField(
                  label: 'หักอื่น ๆ',
                  value: _draft.otherDeduction,
                  onChanged: (v) => setState(
                      () => _draft = _draft.copyWith(otherDeduction: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: 'ค่ากิน',
            subtitle:
                'เดือนนี้ ${month.workdays} วันทำงาน + ${month.holidays} วันหยุด = ${baht(foodBudget)}',
            child: Row(
              children: [
                Expanded(
                  child: _NumField(
                    label: 'วันทำงาน / วัน',
                    value: _draft.foodWorkday,
                    onChanged: (v) => setState(
                        () => _draft = _draft.copyWith(foodWorkday: v)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumField(
                    label: 'วันหยุด / วัน',
                    value: _draft.foodHoliday,
                    onChanged: (v) => setState(
                        () => _draft = _draft.copyWith(foodHoliday: v)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: 'สูตรแบ่งรายจ่าย',
            subtitle: 'รวม ${baht(_draft.linesTotal)} ต่อเดือน',
            trailing: IconButton(
              onPressed: () => _editLine(null),
              icon: const Icon(Icons.add_circle_outline, color: Beach.sea),
            ),
            child: Column(
              children: [
                for (final l in _draft.lines)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Beach.categoryColor(
                                Categories.colorIndexOf(l.categoryId))
                            .withOpacity(.13),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        Categories.byId(l.categoryId).icon,
                        size: 18,
                        color: Beach.categoryColor(
                            Categories.colorIndexOf(l.categoryId)),
                      ),
                    ),
                    title: Text(l.label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      l.isRange
                          ? 'หมวด ${Categories.byId(l.categoryId).name} · ประมาณ ${l.rangeText}'
                          : 'หมวด ${Categories.byId(l.categoryId).name}',
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(moneyInt(l.amount),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800)),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          onPressed: () => _editLine(l),
                        ),
                      ],
                    ),
                    onTap: () => _editLine(l),
                  ),
                if (_draft.lines.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('ยังไม่มีรายการ — กด + เพื่อเพิ่ม',
                        style: TextStyle(color: Beach.inkSoft)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: 'เริ่มใหม่',
            child: OutlinedButton.icon(
              onPressed: () => setState(
                  () => _draft = UserSettings.starter()),
              icon: const Icon(Icons.restart_alt),
              label: const Text('โหลดสูตรตั้งต้นกลับมา'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white),
                  )
                : const Text('บันทึกการตั้งค่า'),
          ),
        ),
      ),
    );
  }

  Future<void> _editLine(PlanLine? line) async {
    final labelCtrl = TextEditingController(text: line?.label ?? '');
    final amountCtrl = TextEditingController(
        text: line == null ? '' : _plain(line.amount));
    final minCtrl = TextEditingController(
        text: line?.minAmount == null ? '' : _plain(line!.minAmount!));
    final maxCtrl = TextEditingController(
        text: line?.maxAmount == null ? '' : _plain(line!.maxAmount!));
    var catId = line?.categoryId ?? 'other_expense';

    final result = await showModalBottomSheet<_LineResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Beach.sand,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
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
                Text(line == null ? 'เพิ่มรายการในสูตร' : 'แก้ไขรายการ',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(
                      labelText: 'ชื่อรายการ', hintText: 'เช่น ค่าเน็ต'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  decoration:
                      const InputDecoration(labelText: 'ยอดต่อเดือน (บาท)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        decoration: const InputDecoration(
                            labelText: 'ต่ำสุด (ถ้ามี)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        decoration: const InputDecoration(
                            labelText: 'สูงสุด (ถ้ามี)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('ผูกกับหมวดหมู่',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in Categories.expense)
                      ChoiceChip(
                        label: Text(c.name,
                            style: const TextStyle(fontSize: 12.5)),
                        selected: catId == c.id,
                        labelStyle: TextStyle(
                            color: catId == c.id ? Colors.white : Beach.ink),
                        onSelected: (_) => setSheet(() => catId = c.id),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (line != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(
                              ctx, const _LineResult(delete: true)),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Beach.coral),
                          child: const Text('ลบ'),
                        ),
                      ),
                    if (line != null) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {
                          final label = labelCtrl.text.trim();
                          if (label.isEmpty) return;
                          Navigator.pop(
                            ctx,
                            _LineResult(
                              line: PlanLine(
                                id: line?.id ?? UniqueKeyish.next(),
                                label: label,
                                categoryId: catId,
                                amount:
                                    double.tryParse(amountCtrl.text.trim()) ??
                                        0,
                                minAmount:
                                    double.tryParse(minCtrl.text.trim()),
                                maxAmount:
                                    double.tryParse(maxCtrl.text.trim()),
                              ),
                            ),
                          );
                        },
                        child: const Text('ตกลง'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == null) return;
    final lines = [..._draft.lines];
    if (result.delete && line != null) {
      lines.removeWhere((x) => x.id == line.id);
    } else if (result.line != null) {
      final i = lines.indexWhere((x) => x.id == result.line!.id);
      if (i >= 0) {
        lines[i] = result.line!;
      } else {
        lines.add(result.line!);
      }
    }
    setState(() => _draft = _draft.copyWith(lines: lines));
  }

  static String _plain(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

class _LineResult {
  final PlanLine? line;
  final bool delete;
  const _LineResult({this.line, this.delete = false});
}

/// ช่องกรอกตัวเลขที่ sync กับ state ด้านนอก
class _NumField extends StatefulWidget {
  const _NumField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<_NumField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.value == 0 ? '' : _SettingsScreenState._plain(widget.value),
    );
  }

  @override
  void didUpdateWidget(covariant _NumField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // อัปเดตช่องเฉพาะเมื่อค่าถูกเปลี่ยนจากข้างนอก (เช่น กดโหลดสูตรตั้งต้น)
    final typed = double.tryParse(_ctrl.text.trim()) ?? 0;
    if (typed != widget.value) {
      _ctrl.text =
          widget.value == 0 ? '' : _SettingsScreenState._plain(widget.value);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(labelText: widget.label, prefixText: '฿ '),
      onChanged: (v) => widget.onChanged(double.tryParse(v.trim()) ?? 0),
    );
  }
}
