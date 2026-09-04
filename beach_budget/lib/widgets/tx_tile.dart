import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../utils/period.dart';

/// แถวรายการหนึ่งรายการ — มีไอคอนหมวด ชื่อ โน้ต และป้ายบอกว่ามีสลิป
class TxTile extends StatelessWidget {
  const TxTile({super.key, required this.tx, this.onTap, this.showDate = true});

  final Tx tx;
  final VoidCallback? onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TxType.income;
    final color = Beach.categoryColor(Categories.colorIndexOf(tx.categoryId));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(.13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(tx.category.icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tx.category.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      if (tx.slipUrl != null) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.receipt_long,
                            size: 13, color: Beach.inkSoft),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    [
                      if (showDate)
                        DateFormat('d MMM', 'th').format(tx.date),
                      if (tx.note.isNotEmpty) tx.note,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Beach.inkSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isIncome ? '+' : '−'}${money(tx.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: isIncome ? Beach.palm : Beach.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
