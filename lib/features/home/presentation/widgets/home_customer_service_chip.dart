import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeCustomerServiceChip extends StatelessWidget {
  const HomeCustomerServiceChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 94,
        decoration: BoxDecoration(
          color: HomePalette.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: HomePalette.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.support_agent_rounded,
              color: HomePalette.gold,
              size: 23,
            ),
            SizedBox(height: 6),
            Text(
              '客服',
              style: TextStyle(
                color: HomePalette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
