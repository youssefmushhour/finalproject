import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/ui/dashboard_screen.dart';

void main() {
  runApp(const MasroufyApp());
}

class MasroufyApp extends StatelessWidget {
  const MasroufyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Masroufy',
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(), // هنا بنقوله ابدأ بالداشبورد
    );
  }
}