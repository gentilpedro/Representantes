import 'package:flutter/material.dart';

/// Paleta categórica validada (skill de dataviz) para uso exclusivo em
/// gráficos — ordem fixa, nunca ciclada arbitrariamente. Ver
/// `references/palette.md` da skill `dataviz` para a instância completa.
class ChartColors {
  ChartColors._();

  static const List<Color> categorical = [
    Color(0xFF2A78D6), // 1 blue
    Color(0xFF1BAF7A), // 2 aqua
    Color(0xFFEDA100), // 3 yellow
    Color(0xFF008300), // 4 green
    Color(0xFF4A3AA7), // 5 violet
    Color(0xFFE34948), // 6 red
    Color(0xFFE87BA4), // 7 magenta
    Color(0xFFEB6834), // 8 orange
  ];

  /// Cinza neutro para buckets "Outros" — não é uma identidade categórica
  /// própria, então fica fora da paleta validada (falha o piso de croma de
  /// propósito: deve sempre vir com rótulo direto, nunca competir por hue).
  static const muted = Color(0xFF898781);
}
