import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// พาเลตต์ "ชายหาด" — ทรายครีม + ฟ้าน้ำทะเล
class Beach {
  // ทราย / ครีม
  static const sand = Color(0xFFF7EFE1); // พื้นหลังหลัก (ทรายแห้ง)
  static const sandDeep = Color(0xFFEADFC8); // ทรายเปียก / เส้นขอบ
  static const shell = Color(0xFFFFFBF3); // การ์ด (เปลือกหอย)

  // ทะเล
  static const seaDeep = Color(0xFF0E5C73); // น้ำลึก (primary)
  static const sea = Color(0xFF1D8AA6); // น้ำทะเล
  static const lagoon = Color(0xFF3FBFC4); // น้ำตื้น / accent
  static const foam = Color(0xFFD6F0EE); // ฟองคลื่น

  // สถานะ
  static const coral = Color(0xFFE2725B); // รายจ่าย (ปะการัง)
  static const palm = Color(0xFF2E8B6F); // รายรับ (ใบปาล์ม)
  static const sunset = Color(0xFFE9A23B); // เตือน / ใกล้เกินงบ

  static const ink = Color(0xFF1B3A44); // ตัวอักษรหลัก
  static const inkSoft = Color(0xFF5E7B84); // ตัวอักษรรอง

  /// ไล่สีท้องฟ้า→ทะเล ใช้เป็นหัวหน้าจอ
  static const oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [seaDeep, sea, lagoon],
  );

  /// สีประจำหมวดหมู่ (ใช้ในกราฟวงกลม)
  static const categoryPalette = <Color>[
    Color(0xFF1D8AA6),
    Color(0xFF3FBFC4),
    Color(0xFFE2725B),
    Color(0xFFE9A23B),
    Color(0xFF2E8B6F),
    Color(0xFF7C6BAD),
    Color(0xFF0E5C73),
    Color(0xFFD98CA6),
    Color(0xFF8FB339),
    Color(0xFF6B8E9E),
  ];

  static Color categoryColor(int index) =>
      categoryPalette[index % categoryPalette.length];
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Beach.sand,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Beach.sea,
        brightness: Brightness.light,
      ).copyWith(
        primary: Beach.seaDeep,
        secondary: Beach.lagoon,
        surface: Beach.shell,
        error: Beach.coral,
        onPrimary: Colors.white,
        onSurface: Beach.ink,
      ),
    );

    final text = GoogleFonts.notoSansThaiTextTheme(base.textTheme).apply(
      bodyColor: Beach.ink,
      displayColor: Beach.ink,
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Beach.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: Beach.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Beach.shell,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Beach.sandDeep),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Beach.sandDeep),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Beach.sea, width: 1.6),
        ),
        labelStyle: const TextStyle(color: Beach.inkSoft),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Beach.seaDeep,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Beach.seaDeep,
          side: const BorderSide(color: Beach.sandDeep),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Beach.foam,
        selectedColor: Beach.seaDeep,
        side: const BorderSide(color: Beach.sandDeep),
        labelStyle: const TextStyle(color: Beach.ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Beach.shell,
        indicatorColor: Beach.foam,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Beach.sandDeep, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Beach.seaDeep,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
