import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For text style if needed

Future<void> showFontSizeDialog({
  required BuildContext context,
  required double initialSize,
  required Function(double) onSizeChanged,
}) {
  double currentSize = initialSize;
  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      // Use StatefulBuilder for local state of slider
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('调整字体大小'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '当前: ${currentSize.toStringAsFixed(1)}',
                style: GoogleFonts.nunito(fontSize: currentSize), // Example text with current size
              ),
              const SizedBox(height: 20),
              Slider(
                value: currentSize,
                min: 10, // Adjusted min for practical use
                max: 40, // Adjusted max for practical use
                divisions: 30, // (40-10) / 1 step
                label: currentSize.round().toString(),
                onChanged: (value) {
                  setDialogState(() {
                    currentSize = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onSizeChanged(currentSize);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    ),
  );
}
