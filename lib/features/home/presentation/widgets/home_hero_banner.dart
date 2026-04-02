import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({
    super.key,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  static const _slides = [
    _BannerData(
      title: '绿色焕新计划',
      subtitle: '收护理头 为环保助力',
      assetPath: 'assets/images/home/banner_1.jpg',
    ),
    _BannerData(
      title: '5 档能量精细调节',
      subtitle: '适配不同肌肤区域',
      assetPath: 'assets/images/home/banner_2.jpg',
    ),
    _BannerData(
      title: 'AI 智能护理节奏',
      subtitle: '记录每一次焕新旅程',
      assetPath: 'assets/images/home/banner_3.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
      child: Column(
        children: [
          SizedBox(
            height: 188,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: pageController,
                itemCount: _slides.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        slide.assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF3A342F), Color(0xFF1F1B19)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: HomePalette.textSecondary,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.42),
                              Colors.black.withOpacity(0.06),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.03,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              slide.subtitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: HomePalette.gold,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '了解更多',
                                style: TextStyle(
                                  color: Color(0xFF1A1614),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (index) {
              final isActive = index == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? HomePalette.gold
                      : HomePalette.textSecondary.withOpacity(0.48),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.assetPath,
  });

  final String title;
  final String subtitle;
  final String assetPath;
}
