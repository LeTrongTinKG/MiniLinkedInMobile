import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Clay-inspired Executive Minimalist Palette
  static const Color primary = Color(0xFF2952CC);
  static const Color primaryContainer = Color(0xFFEEF2FF); // Indigo nhạt 50
  static const Color onPrimaryContainer = Color(0xFF1E40AF); // Indigo đậm 800
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color salary = Color(0xFF10B981); // Emerald 500
  static const Color accent = Color(0xFFC2410C);
  static const Color accentContainer = Color(0xFFFAEFEA);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color iconMuted = Color(0xFF94A3B8); // Slate 400

  // 3-Level Confidence Micro-Tokens
  static const Color verified = Color(0xFF10B981); // Emerald 500
  static const Color evidence = Color(0xFF6366F1); // Indigo 500
  static const Color selfClaimed = Color(0xFF64748B); // Slate 500

  // 8 stable logo colors: [background, foreground]
  static const List<List<Color>> _logoPalette = [
    [Color(0xFFDCE4F7), Color(0xFF1E3E9E)], // blue
    [Color(0xFFCCF0EC), Color(0xFF0D6B62)], // teal
    [Color(0xFFE9D8FF), Color(0xFF5B21B6)], // purple
    [Color(0xFFFFE4CC), Color(0xFF92400E)], // terracotta
    [Color(0xFFFFD6E4), Color(0xFF9D174D)], // deep pink
    [Color(0xFFD4EDDA), Color(0xFF155724)], // moss green
    [Color(0xFFFFF0CC), Color(0xFF78500A)], // amber
    [Color(0xFFDEE3EC), Color(0xFF1E3A5F)], // slate blue
  ];

  static List<Color> logoColorsFor(String companyName) {
    int hash = 5381;
    for (final c in companyName.codeUnits) {
      hash = ((hash << 5) + hash) ^ c;
      hash = hash & 0x7FFFFFFF;
    }
    return _logoPalette[hash % _logoPalette.length];
  }
}
