import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key, required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('产品教程', Icons.menu_book_rounded),
      ('旅程日志', Icons.receipt_long_rounded),
      ('焕新计划', Icons.autorenew_rounded),
      ('推荐有礼', Icons.card_giftcard_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      child: Row(
        children: items
            .map(
              (item) => Expanded(
                child: _ActionItem(
                  label: item.$1,
                  icon: item.$2,
                  onTap: () => onTap(item.$1),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HomePalette.card,
                border: Border.all(color: HomePalette.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: HomePalette.gold, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: HomePalette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
