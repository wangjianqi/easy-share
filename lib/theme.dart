import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme() {
    const primaryColor = Color(0xFFFF5729);
    // const surfaceColor = Color(0xFFF8F9FA); // A light grey for surface
    // const backgroundColor = Colors.white; // For main background of content

    return ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          // primary: primaryColor,
          // surface: surfaceColor,
          // background: backgroundColor,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(
            // Apply base text theme
            // ThemeData.light().textTheme.copyWith(
            //   bodyLarge: GoogleFonts.nunito(fontSize: 16),
            //   bodyMedium: GoogleFonts.nunito(fontSize: 14),
            //   titleLarge: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 22),
            //   labelLarge: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16), // For buttons
            // ),
            ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          // backgroundColor: surfaceColor, // Consistent AppBar background
          // foregroundColor: Colors.black87, // For AppBar icons and title
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Increased vertical padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // backgroundColor: primaryColor,
            // foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Increased vertical padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // side: BorderSide(color: primaryColor),
            // foregroundColor: primaryColor,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0, // Keeping cards flat as per original design
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            // side: BorderSide(color: Colors.grey.shade200, width: 1), // Default card border
          ),
          // color: Colors.white, // Default card color
          margin: EdgeInsets.zero, // Original cards might not have outer margins
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          // Consistent with original
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: GoogleFonts.nunito(color: Colors.grey.shade500),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // margin: const EdgeInsets.fromLTRB(10, 0, 10, 10), // Set in code, or here if always the same
          // backgroundColor: Colors.grey[800],
          // contentTextStyle: GoogleFonts.nunito(color: Colors.white),
        ),
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4, // Slight elevation for popup menus
        ));
  }
}
