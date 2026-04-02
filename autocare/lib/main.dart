import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'core/database/hive_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager.init();
  await NotificationService.init();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(child: AutoCareApp()),
    ),
  );
}

class AutoCareApp extends StatelessWidget {
  const AutoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoCare - Vehicle Tracker',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
