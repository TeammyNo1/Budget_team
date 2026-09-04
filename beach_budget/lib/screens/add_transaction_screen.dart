import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.existing,
    this.presetCategoryId,
    this.presetDebtId,
    this.presetAmount,
  });

  /// ถ้าส่งมา = โหมดแก้ไข
  final Tx? existing;

  /// ค่าตั้งต้นสำหรับการบันทึกใหม่ (เช่น กด "จ่าย" จากหน้าหนี้)
  final String? presetCategoryId;
  final String? presetDebtId;
  final double? presetAmount;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TxType _type = TxType.expense;
  String _categoryId = 'food';
  DateTime _date = DateTime.now();
  String? _debtId;

  File? _newSlip; // สลิปที่เพิ่งเลือก ยังไม่อัปโหลด
  String? _slipUrl; // สลิปเดิมที่อัปโหลดแล้ว
  String? _slipPath;
  bool _removeSlip = false;

  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _categoryId = e.categoryId;
      _date = e.date;
      _debtId = e.debtId;
      _slipUrl = e.slipUrl;
      _slipPath = e.slipPath;
      _amountCtrl.text = e.amount == e.amount.roundToDouble()
          ? e.amount.toStringAsFixed(0)
          : e.amount.toString();
      _noteCtrl.text = e.note;
    } else {
      if (widget.presetCategoryId != null) {
        _categoryId = widget.presetCategoryId!;
      }
      _debtId = widget.presetDebtId;
      final a = widget.presetAmount;
      if (a != null && a > 0) {
        _amountCtrl.text =
            a == a.roundToDouble() ? a.toStringAsFixed(0) : a.toString();
      }
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _amount =>
      double.tryParse(_amountCtrl.text.replaceAll(',', '').trim()) ?? 0;

  Future<void> _pickSlip() async {
    final app = context.read<AppState>();
    final source = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Beach.shell,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Beach.sandDeep,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Beach.sea),
              title: const Text('ถ่ายรูปสลิป'),
              onTap: () => Navigator.pop(ctx, true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Beach.sea),
              title: const Text('เลือกจากคลังภาพ'),
              onTap: () => Navigator.pop(ctx, false),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    final file = await app.storage.pickSlip(fromCamera: source);
    if (file != null && mounted) {
      setState(() {
        _newSlip = file;
        _removeSlip = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('th'),
    );
    if (picked == null) return;
    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? _date.hour,
        time?.minute ?? _date.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_amount <= 0) {
      _toast('ใส่จำนวนเงินก่อนนะ');
      return;
    }
    setState(() => _saving = true);
    final app = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      String? url = _removeSlip ? null : _slipUrl;
      String? path = _removeSlip ? null : _slipPath;

      if (_newSlip != null) {
        final up = await app.storage.uploadSlip(_newSlip!);
        // ลบสลิปเดิมทิ้งถ้ามีการเปลี่ยนรูป
        if (_slipPath != null) await app.storage.deleteSlip(_slipPath);
        url = up.url;
        path = up.path;
      } else if (_removeSlip && _slipPath != null) {
        await app.storage.deleteSlip(_slipPath);
      }

      final tx = Tx(
        id: widget.existing?.id ?? '',
        type: _type,
        amount: _amount,
        categoryId: _categoryId,
        date: _date,
        note: _noteCtrl.text.trim(),
        slipUrl: url,
        slipPath: path,
        debtId: _categoryId == 'debt' ? _debtId : null,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
      );

      if (_isEdit) {
        await app.db.updateTransaction(widget.existing!, tx);
      } else {
        await app.db.addTransaction(tx);
      }

      if (mounted) {
        navigator.pop(true);
        messenger.showSnackBar(
          SnackBar(content: Text(_isEdit ? 'แก้ไขแล้ว' : 'บันทึกแล้ว 🌊')),
        );
      }
    } catch (e) {
      if (mounted) _toast('บันทึกไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final cats = Categories.of(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'แก้ไขรายการ' : 'บันทึกรายการ'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          _TypeToggle(
            type: _type,
            onChanged: (t) => setState(() {
              _type = t;
              _categoryId = Categories.of(t).first.id;
              _debtId = null;
            }),
          ),
          const SizedBox(height: 20),
          _AmountField(controller: _amountCtrl, type: _type),
          const SizedBox(height: 22),

          const _Label('หมวดหมู่'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in cats)
                _CategoryChip(
                  category: c,
                  selected: c.id == _categoryId,
                  onTap: () => setState(() => _categoryId = c.id),
                ),
            ],
          ),

          // เลือกก้อนหนี้เมื่อหมวดเป็น "จ่ายหนี้" — ยอดจะถูกหักออกจากหนี้ก้อนนั้นให้เลย
          if (_categoryId == 'debt') ...[
            const SizedBox(height: 20),
            const _Label('ตัดจากหนี้ก้อนไหน'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _debtId,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.handshake, color: Beach.inkSoft),
              ),
              hint: const Text('ไม่ผูกกับก้อนหนี้'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('ไม่ผูกกับก้อนหนี้'),
                ),
                for (final d in app.debts.where((d) => !d.archived))
                  DropdownMenuItem<String?>(
                    value: d.id,
                    child: Text('${d.name} · เหลือ ${money(d.remaining)}'),
                  ),
              ],
              onChanged: (v) => setState(() => _debtId = v),
            ),
          ],

          const SizedBox(height: 20),
          const _Label('วันที่'),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.event, color: Beach.inkSoft),
              ),
              child: Text(
                DateFormat('EEEE d MMMM y · HH:mm', 'th').format(_date),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _QuickDate(label: 'วันนี้', onTap: () => _setDay(0)),
              _QuickDate(label: 'เมื่อวาน', onTap: () => _setDay(-1)),
              _QuickDate(label: '2 วันก่อน', onTap: () => _setDay(-2)),
            ],
          ),

          const SizedBox(height: 20),
          const _Label('โน้ต (ไม่ใส่ก็ได้)'),
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'เช่น ข้าวมันไก่ + น้ำ, เติมน้ำมัน 91',
            ),
          ),

          const SizedBox(height: 20),
          const _Label('สลิป / ใบเสร็จ (ไม่ใส่ก็ได้)'),
          const SizedBox(height: 8),
          _SlipPicker(
            file: _newSlip,
            url: _removeSlip ? null : _slipUrl,
            onPick: _pickSlip,
            onRemove: () => setState(() {
              _newSlip = null;
              _removeSlip = true;
            }),
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
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white),
                  )
                : Text(_isEdit ? 'บันทึกการแก้ไข' : 'บันทึกรายการ'),
          ),
        ),
      ),
    );
  }

  void _setDay(int offset) {
    final d = DateTime.now().add(Duration(days: offset));
    setState(() => _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute));
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          color: Beach.ink,
        ),
      );
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.type, required this.onChanged});
  final TxType type;
  final ValueChanged<TxType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Beach.foam,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final t in TxType.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: type == t
                        ? (t == TxType.income ? Beach.palm : Beach.coral)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        t == TxType.income
                            ? Icons.south_west
                            : Icons.north_east,
                        size: 17,
                        color: type == t ? Colors.white : Beach.inkSoft,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: type == t ? Colors.white : Beach.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.type});
  final TextEditingController controller;
  final TxType type;

  @override
  Widget build(BuildContext context) {
    final color = type == TxType.income ? Beach.palm : Beach.coral;
    return Column(
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: color.withOpacity(.28),
            ),
            prefixText: '฿ ',
            prefixStyle: TextStyle(
                fontSize: 22, color: color.withOpacity(.7)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final v in [50, 100, 150, 200, 500])
              ActionChip(
                label: Text('+$v'),
                backgroundColor: Beach.foam,
                side: const BorderSide(color: Beach.sandDeep),
                onPressed: () {
                  final cur =
                      double.tryParse(controller.text.trim()) ?? 0;
                  final next = cur + v;
                  controller.text = next == next.roundToDouble()
                      ? next.toStringAsFixed(0)
                      : next.toString();
                  controller.selection = TextSelection.collapsed(
                      offset: controller.text.length);
                },
              ),
            ActionChip(
              label: const Text('ล้าง'),
              backgroundColor: Beach.sand,
              side: const BorderSide(color: Beach.sandDeep),
              onPressed: () => controller.clear(),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Beach.categoryColor(Categories.colorIndexOf(category.id));
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Beach.shell,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : Beach.sandDeep),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon,
                size: 16, color: selected ? Colors.white : color),
            const SizedBox(width: 7),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Beach.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickDate extends StatelessWidget {
  const _QuickDate({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        backgroundColor: Beach.foam,
        side: const BorderSide(color: Beach.sandDeep),
        onPressed: onTap,
      );
}

class _SlipPicker extends StatelessWidget {
  const _SlipPicker({
    required this.file,
    required this.url,
    required this.onPick,
    required this.onRemove,
  });

  final File? file;
  final String? url;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = file != null || url != null;

    if (!hasImage) {
      return InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Beach.shell,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Beach.sandDeep),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, color: Beach.sea, size: 26),
              SizedBox(height: 8),
              Text('แนบรูปสลิป / ใบเสร็จ',
                  style: TextStyle(fontSize: 13, color: Beach.inkSoft)),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: file != null
                ? Image.file(file!, fit: BoxFit.cover)
                : Image.network(url!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _RoundBtn(icon: Icons.edit, onTap: onPick),
              const SizedBox(width: 6),
              _RoundBtn(icon: Icons.close, onTap: onRemove),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.55),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: Colors.white),
        ),
      );
}
