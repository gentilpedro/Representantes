import 'package:flutter/material.dart';

/// Paleta semântica sensível ao tema (claro/escuro). Widgets devem ler as
/// cores via `context.colors.xxx` em vez de [AppColors] estático, para que a
/// troca de [ThemeMode] realmente mude a aparência da UI.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.error,
    required this.errorSoft,
    required this.info,
    required this.infoSoft,
    required this.neutralSoft,
  });

  final Color primary;
  final Color primaryDark;
  final Color primarySoft;

  final Color background;
  final Color surface;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color success;
  final Color successSoft;

  final Color warning;
  final Color warningSoft;

  final Color error;
  final Color errorSoft;

  final Color info;
  final Color infoSoft;

  final Color neutralSoft;

  static const light = AppPalette(
    primary: Color(0xFF2563EB),
    primaryDark: Color(0xFF1D4ED8),
    primarySoft: Color(0xFFEFF4FF),
    background: Color(0xFFF5F6F8),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
    success: Color(0xFF16A34A),
    successSoft: Color(0xFFDCFCE7),
    warning: Color(0xFFD97706),
    warningSoft: Color(0xFFFEF3C7),
    error: Color(0xFFDC2626),
    errorSoft: Color(0xFFFEE2E2),
    info: Color(0xFF2563EB),
    infoSoft: Color(0xFFDBEAFE),
    neutralSoft: Color(0xFFF3F4F6),
  );

  static const dark = AppPalette(
    primary: Color(0xFF3B82F6),
    primaryDark: Color(0xFF60A5FA),
    primarySoft: Color(0xFF1E3A5F),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    border: Color(0xFF334155),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    success: Color(0xFF4ADE80),
    successSoft: Color(0xFF14532D),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF78350F),
    error: Color(0xFFF87171),
    errorSoft: Color(0xFF7F1D1D),
    info: Color(0xFF3B82F6),
    infoSoft: Color(0xFF1E2F4D),
    neutralSoft: Color(0xFF243044),
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primarySoft,
    Color? background,
    Color? surface,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? error,
    Color? errorSoft,
    Color? info,
    Color? infoSoft,
    Color? neutralSoft,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      error: error ?? this.error,
      errorSoft: errorSoft ?? this.errorSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      neutralSoft: neutralSoft ?? this.neutralSoft,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      neutralSoft: Color.lerp(neutralSoft, other.neutralSoft, t)!,
    );
  }
}

/// Acesso rápido à paleta do tema atual: `context.colors.primary`.
extension AppPaletteContext on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;
}
