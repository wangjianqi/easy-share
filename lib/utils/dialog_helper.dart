import 'package:flutter/material.dart';

Future<void> showClearContentDialog(
  BuildContext context, {
  required VoidCallback onClearText,
  required VoidCallback onClearAll,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('清除内容'),
      content: const Text('您想要清除哪些内容？'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClearText();
          },
          child: const Text('仅清除文本'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClearAll();
          },
          child: const Text('清除所有内容'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
      ],
    ),
  );
}

Future<bool?> showMarkdownPromptDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // User must choose an option
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('检测到 Markdown'),
        content: const Text(
          '粘贴的内容看起来像是 Markdown 格式。您希望应用 Markdown 样式进行预览吗？\n\n（您可以随时切换回原始 Markdown 或进行编辑。）',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('否，保持纯文本'),
            onPressed: () {
              Navigator.of(dialogContext).pop(false); // Do not apply styling
            },
          ),
          ElevatedButton(
            // Make 'Yes' more prominent
            onPressed: () {
              Navigator.of(dialogContext).pop(true); // Apply styling
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.primary,
              foregroundColor: Theme.of(dialogContext).colorScheme.onPrimary,
            ),
            // Make 'Yes' more prominent
            child: const Text('是，应用样式'),
          ),
        ],
      );
    },
  );
}
