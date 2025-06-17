import 'package:flutter/material.dart';

class FooterInputSection extends StatelessWidget {
  final TextEditingController footerTextController;
  final bool showFooterInImage;
  final ValueChanged<String>? onFooterTextChanged;
  final ValueChanged<bool> onShowFooterInImageChanged;

  const FooterInputSection({
    super.key,
    required this.footerTextController,
    required this.showFooterInImage,
    this.onFooterTextChanged,
    required this.onShowFooterInImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder for footerTextController to rebuild on text change for hint text update etc.
    return ListenableBuilder(
      listenable: footerTextController,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '底部附加文本',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Switch(
                      value: showFooterInImage,
                      onChanged: onShowFooterInImageChanged,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: footerTextController,
                    decoration: const InputDecoration(
                      hintText: '自定义底部显示的文本内容',
                      prefixIcon: Icon(Icons.text_snippet_rounded),
                    ),
                    onChanged: (value) {
                      onFooterTextChanged?.call(value);
                    }),
                const SizedBox(height: 8),
                Text(
                  showFooterInImage ? '此文本将显示在生成的图片底部' : '此文本仅为备注，不显示在图片中',
                  style: TextStyle(
                    color: showFooterInImage ? Theme.of(context).colorScheme.primary.withOpacity(0.8) : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
