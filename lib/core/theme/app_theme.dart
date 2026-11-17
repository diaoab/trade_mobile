import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_color.dart';

/// Thème unique, sombre (style fintech) : l'app ne suit pas le réglage
/// clair / sombre du téléphone.
class AppTheme {
  AppTheme._();

  static ThemeData theme() {
    const c = AppColor.nuit;
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      extensions: const [c],
      scaffoldBackgroundColor: c.fond,
      canvasColor: c.fond,
      colorScheme: base.colorScheme.copyWith(
        primary: c.encre,
        onPrimary: c.surEncre,
        secondary: c.encre,
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
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerColor: c.separateur,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.encre.withValues(alpha: 0.16),
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.encre : c.texteMoyen, size: 24),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? c.encre : c.texteMoyen,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: c.separateur,
      ),
      dialogTheme: DialogThemeData(backgroundColor: c.surface, surfaceTintColor: Colors.transparent),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.encre : c.champ),
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.surEncre : c.texteMoyen),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.encre),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.encre,
        selectionColor: c.encre.withValues(alpha: 0.3),
        selectionHandleColor: c.encre,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.champ,
        contentTextStyle: TextStyle(color: c.texte),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Anciens points d'entrée : même thème sombre.
  static ThemeData light() => theme();
  static ThemeData dark() => theme();
}
