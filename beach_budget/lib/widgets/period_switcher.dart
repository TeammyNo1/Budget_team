import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';

/// แถบเลือก วัน / สัปดาห์ / เดือน / ปี + ปุ่มเลื่อนช่วงเวลา
class PeriodSwitcher extends StatelessWidget {
  const PeriodSwitcher({super.key, this.onLight = true});

  /// true = วางบนพื้นหลังสีทะเล (ตัวอักษรขาว)
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final fg = onLight ? Colors.white : Beach.ink;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: onLight ? Colors.white.withOpacity(.18) : Beach.foam,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: Period.values.map((p) {
              final selected = app.range.period == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () => app.setPeriod(p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: selected
                          ? (onLight ? Colors.white : Beach.seaDeep)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      p.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: selected
                            ? (onLight ? Beach.seaDeep : Colors.white)
                            : fg.withOpacity(.85),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _NavBtn(
              icon: Icons.chevron_left,
              color: fg,
              onTap: () => app.shiftRange(-1),
            ),
            Expanded(
              child: GestureDetector(
                onTap: app.jumpToToday,
                child: Column(
                  children: [
                    Text(
                      app.range.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (!app.range.isCurrent)
                      Text(
                        'แตะเพื่อกลับมาปัจจุบัน',
                        style: TextStyle(
                            color: fg.withOpacity(.7), fontSize: 11),
                      ),
                  ],
                ),
              ),
            ),
            _NavBtn(
              icon: Icons.chevron_right,
              color: fg,
              onTap: () => app.shiftRange(1),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      splashRadius: 22,
    );
  }
}
