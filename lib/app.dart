import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/router/app_router.dart';
import 'package:ableone_app/core/theme/app_theme.dart';
import 'package:ableone_app/config/app_config.dart';
import 'package:ableone_app/features/accessibility/data/repositories/accessibility_repository_impl.dart';

class AbleOneApp extends ConsumerWidget {
  const AbleOneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final accessSettings = ref.watch(accessibilitySettingsProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: accessSettings.highContrastMode ? AppTheme.highContrastTheme : AppTheme.lightTheme,
      darkTheme: accessSettings.highContrastMode ? AppTheme.highContrastTheme : AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
