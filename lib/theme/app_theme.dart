import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AppTheme {
  static const String fontFamily = 'Pyidaungsu';

  // Dark Theme Palette (Slate / Night)
  static const Color darkBg = Color(0xFF0F172A);        // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);   // Slate 800
  static const Color darkBorder = Color(0xFF334155);    // Slate 700
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  // Light Theme Palette (Clean Slate / Paper)
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);

  // Brand Accents
  static const Color primaryAccent = Color(0xFF6366F1); // Indigo 500
  static const Color crimsonDark = Color(0xFFFB7185);   // Rose 400 (Dark Mode Code)
  static const Color crimsonLight = Color(0xFFE11D48);  // Rose 600 (Light Mode Code)

  // LIGHT THEME
  static ThemeData get lightTheme {
    return ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: primaryAccent,
        surface: lightSurface,
        onSurface: lightTextPrimary,
      ),
      textTheme: ThemeData.light().textTheme.apply(fontFamily: fontFamily),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: lightTextPrimary,
        ),
      ),
      dividerColor: lightBorder,
    );
  }

  // DARK THEME
  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        surface: darkSurface,
        onSurface: darkTextPrimary,
      ),
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: fontFamily),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: darkTextPrimary,
        ),
      ),
      dividerColor: darkBorder,
    );
  }

  // COMPLETE MARKDOWN STYLES
  static MarkdownStyleSheet getMarkdownStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark ? darkBorder : lightBorder;
    final textPrimary = isDark ? darkTextPrimary : lightTextPrimary;
    final textSecondary = isDark ? darkTextSecondary : lightTextSecondary;

    return MarkdownStyleSheet(
      // --- PARAGRAPHS & BASIC TEXT ---
      p: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        height: 1.6,
        color: textSecondary,
      ),
      strong: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      em: TextStyle(
        fontFamily: fontFamily,
        fontStyle: FontStyle.italic,
        color: textSecondary,
      ),

      // --- HEADINGS (H1 through H6) ---
      h1: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4338CA), // Indigo
      ),
      h2: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7), // Sky Blue
      ),
      h3: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669), // Emerald Green
      ),
      h4: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      h5: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      h6: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),

      // --- BLOCKQUOTES (e.g. > Prep time: 15 mins) ---
      blockquote: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.5,
        height: 1.5,
        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
      ),
      blockquoteDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(
            color: isDark ? const Color(0xFF6366F1) : const Color(0xFF4338CA),
            width: 4,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      // --- INLINE CODE & CODEBLOCKS ---
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: isDark ? crimsonDark : crimsonLight,
        backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFFFF1F2),
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      codeblockPadding: const EdgeInsets.all(14),

      // --- LISTS & BULLETS ---
      listBullet: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        color: primaryAccent,
      ),
      listIndent: 24.0,

      // --- HYPERLINKS ---
      a: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB),
        decoration: TextDecoration.underline,
      ),

      // --- HORIZONTAL RULE (---) ---
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 1.5,
          ),
        ),
      ),

      // --- TABLES ---
      tableHead: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: textPrimary,
      ),
      tableBody: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.5,
        color: textSecondary,
      ),
      tableBorder: TableBorder(
        top: BorderSide(color: borderColor, width: 1.5),
        bottom: BorderSide(color: borderColor, width: 1.5),
        left: BorderSide(color: borderColor, width: 1.5),
        right: BorderSide(color: borderColor, width: 1.5),
        horizontalInside: BorderSide(color: borderColor, width: 1.0),
        verticalInside: BorderSide(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      tableColumnWidth: const IntrinsicColumnWidth(),
      tableHeadAlign: TextAlign.left,
      tableCellsDecoration: BoxDecoration(
        color: isDark ? darkBg : lightBg,
      ),
    );
  }
}