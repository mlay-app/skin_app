import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeBrandHeader extends StatelessWidget {
  const HomeBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: const [
          Text(
            'Peninsula 半岛®',
            style: TextStyle(
              color: HomePalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          Spacer(),
          Text(
            'Mlay',
            style: TextStyle(
              color: HomePalette.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
