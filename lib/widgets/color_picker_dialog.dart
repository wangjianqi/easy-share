import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<void> showColorPickerDialog({
  required BuildContext context,
  required Color initialColor,
  required Function(Color) onColorChanged,
  String title = '选择颜色', // Default title
}) {
  Color pickedColor = initialColor;
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: initialColor,
          onColorChanged: (color) {
            pickedColor = color; // Store locally, apply on confirm
          },
          enableAlpha: false,
          displayThumbColor: true,
          pickerAreaHeightPercent: 0.8,
        ),
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
            onColorChanged(pickedColor);
          },
          child: const Text('确定'),
        ),
      ],
    ),
  );
}
