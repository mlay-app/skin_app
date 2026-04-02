import 'package:flutter/material.dart';

import 'router.dart';

class SkinApp extends StatelessWidget {
  const SkinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Skin Device Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E6B73)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
