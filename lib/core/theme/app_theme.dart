import 'package:flutter/material.dart';

import 'app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _theme(AppColor.clair, Brightness.light);

  static ThemeData dark() => _theme(AppColor.sombre, Brightness.dark);

  static ThemeData _theme(AppColor c, Brightness luminosite) {
    final base = ThemeData(brightness: luminosite, useMaterial3: true);
    return base.copyWith(
      extensions: [c],
      scaffoldBackgroundColor: c.fond,
      colorScheme: base.colorScheme.copyWith(
        primary: c.encre,
        onPrimary: c.surEncre,
        surface: c.fond,
        onSurface: c.texte,
        error: c.baisse,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.fond,
        foregroundColor: c.texte,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: c.separateur,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.fond,
        indicatorColor: c.surface,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c.texte)),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.hausse : c.separateur),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.texteMoyen),
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.texte),
    );
  }
}
