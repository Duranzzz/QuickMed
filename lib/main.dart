import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/triage_provider.dart';
import 'ui/screens/role_selection_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TriageProvider()),
      ],
      child: const QuickMedApp(),
    ),
  );
}

class QuickMedApp extends StatelessWidget {
  const QuickMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickMed MVP',
      theme: AppTheme.lightTheme,
      home: const RoleSelectionScreen(),
    );
  }
}
