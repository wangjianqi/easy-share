import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<void> showImagePreviewDialog({
  required BuildContext context,
  required Uint8List imageBytes,
  required Future<void> Function() onConfirm,
  VoidCallback? onCancel,
}) {
  final theme = Theme.of(context); // Get theme data
  final screenWidth = MediaQuery.of(context).size.width;

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button!
    builder: (BuildContext dialogContext) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth > 600 ? 40.0 : 20.0,
          vertical: 24.0,
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.9, // 使用屏幕宽度的90%
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 10.0),
                child: Text(
                  '图片预览',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Scrollbar(
                    thumbVisibility: true, // Always show scrollbar thumb
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding back inside scrollview
                      child: ClipRRect(
                        // Add rounded corners to the image
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        onCancel?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.textTheme.bodyLarge?.color?.withOpacity(0.7), // Subdued color
                      ),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8), // Space between buttons
                    ElevatedButton(
                      // Use ElevatedButton for primary action
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        await onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Consistent corner radius
                        ),
                      ),
                      // Use ElevatedButton for primary action
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
