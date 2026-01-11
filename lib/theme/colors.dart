import 'package:flutter/material.dart';

// Definícia farebnej palety pre svetlý režim aplikácie
class AppColors {
  // Farba pozadia celej aplikácie
  static const Color background = Color(0xFFF5F0E6);
  // Farba panelov, kariet, AppBaru
  static const Color panel = Color(0xFFE6D8C3);
  // Hlavná akcentová farba (napr. tlačidlá, zvýraznenia)
  static const Color accent = Color(0xFF7A1C1C);
  // Jemnejší akcent (napr. ikony, highlighty)
  static const Color accentSoft = Color(0xFFD85B5B);
  // Farba hlavného textu
  static const Color text = Color(0xFF3B2E2A);
  // Farba pre úspešné akcie (napr. potvrdenie)
  static const Color success = Color(0xFFB6C4A2);
  // Farba pre disabled prvky (text, ikony)
  static const Color disabled = Color(0x6149454F);  
  // Sekundárny text, popisy ikon
  static const Color small = Color(0xFF49454F);  
}

// Definícia farebnej palety pre tmavý režim aplikácie
class AppDarkColors {
  // Farba pozadia v tmavom režime (teplá tmavá hnedo-sivá)
  static const Color background = Color(0xFF1E1B18);   // tmavá teplá hnedo-sivá (nie čistá čierna)
  // Farba panelov, kariet, AppBaru v tmavom režime
  static const Color panel = Color(0xFF2A2622);  // panely, karty, AppBar
  // Hlavná akcentová farba v tmavom režime
  static const Color accent = Color(0xFFB94A4A);  // tmavý variant vínovej – menej saturovaný
  // Jemnejší akcent v tmavom režime
  static const Color accentSoft = Color(0xFFE07A7A);  // jemný akcent (ikony, highlight)
  // Farba hlavného textu v tmavom režime
  static const Color text = Color(0xFFE8E1D8);  // hlavný text – teplá svetlá béžová
  // Farba pre úspešné akcie v tmavom režime
  static const Color success = Color(0xFF8FA37A);  // utlmená zelená
  // Farba pre disabled prvky v tmavom režime
  static const Color disabled = Color(0x669A938B);  // disabled text / ikony
  // Sekundárny text, popisy ikon v tmavom režime
  static const Color small = Color(0xFFB0AAA3);  // sekundárny text, icon labels
}
