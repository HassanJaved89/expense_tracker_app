import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app/app_theme.dart';
import 'core/app/splash_screen.dart';
import 'features/expense/provider/expense_provider.dart';
import 'features/expense/view/screens/expense_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expenso Track',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system, // Automatically switch based on system preference
        home: const SplashScreen(home: ExpenseHomeScreen()),
        routes: {
          '/home': (context) => const ExpenseHomeScreen(),
        },
      ),
    );
  }
}
