import 'package:flutter/material.dart';

import 'design/app_theme.dart';
import 'features/home/home_screen.dart';

/// Wurzel-Widget: Theme (hell/dunkel), Routing.
class FeierabendApp extends StatelessWidget {
  const FeierabendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feierabend Rechner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
