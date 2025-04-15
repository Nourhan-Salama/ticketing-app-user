// constants.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF2A2AC0);
  static const accentColor = Color(0xFF4CAF50);
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
  static const background = Color(0xFFF5F5F5);
}

class TextStyles {
  static const h1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    height: 1.45,
    color: AppColors.textPrimary,
  );
  
  static const h2 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.38,
    color: AppColors.textPrimary,
  );
  
  static const body1 = TextStyle(
    fontSize: 20,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  static const button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}