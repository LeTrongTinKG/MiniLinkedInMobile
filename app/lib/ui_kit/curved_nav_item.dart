import 'package:flutter/material.dart';

/// Item điều hướng trong CurvedMenu / CurvedDrawer
class CurvedNavItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;

  const CurvedNavItem({
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
  });
}

