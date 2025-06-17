import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove any existing snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      // behavior: SnackBarBehavior.floating, // Already set in theme
      // shape: RoundedRectangleBorder( // Already set in theme
      //   borderRadius: BorderRadius.circular(10),
      // ),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Standard margin
      duration: const Duration(seconds: 2),
    ),
  );
}
