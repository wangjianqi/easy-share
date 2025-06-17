import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showQrCodeInput;
  final bool showFooterTextInput;
  final bool showFooterInImage;
  final String currentFontFamily;
  final bool isMarkdownPreviewEnabled;

  // final Map<String, TextStyle Function(TextStyle)> fontOptions; // Manage internally or pass simplified list

  final VoidCallback onPaste;
  final VoidCallback onToggleQrInput;
  final VoidCallback onToggleFooterTextInput;
  final VoidCallback onToggleFooterVisibility;
  final VoidCallback onClearContent;
  final VoidCallback onPickTextColor;
  final VoidCallback onPickBackgroundColor;
  final VoidCallback onShowFontSizeDialog;
  final ValueChanged<String> onChangeFontFamily;
  final VoidCallback onToggleMarkdownPreview;

  const HomeAppBar({
    super.key,
    required this.showQrCodeInput,
    required this.showFooterTextInput,
    required this.showFooterInImage,
    required this.currentFontFamily,
    required this.isMarkdownPreviewEnabled,
    // required this.fontOptions,
    required this.onPaste,
    required this.onToggleQrInput,
    required this.onToggleFooterTextInput,
    required this.onToggleFooterVisibility,
    required this.onClearContent,
    required this.onPickTextColor,
    required this.onPickBackgroundColor,
    required this.onShowFontSizeDialog,
    required this.onChangeFontFamily,
    required this.onToggleMarkdownPreview,
  });

  // Static font options, can be moved to a constants file if preferred
  static final Map<String, TextStyle Function(TextStyle)> _fontOptions = {
    'Nunito': (baseStyle) => GoogleFonts.nunito(textStyle: baseStyle),
    'Roboto': (baseStyle) => GoogleFonts.roboto(textStyle: baseStyle),
    'Open Sans': (baseStyle) => GoogleFonts.openSans(textStyle: baseStyle),
    'Montserrat': (baseStyle) => GoogleFonts.montserrat(textStyle: baseStyle),
    'Source Code Pro': (baseStyle) => GoogleFonts.sourceCodePro(textStyle: baseStyle),
  };

  Widget _buildFontMenuItem(BuildContext context, String fontName) {
    final bool isSelected = currentFontFamily == fontName;
    final TextStyle baseStyle = TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
    );
    final TextStyle fontStyle = _fontOptions.containsKey(fontName) ? _fontOptions[fontName]!(baseStyle) : baseStyle;

    return Row(
      children: [
        Icon(
          isSelected ? Icons.check_circle_outline_rounded : Icons.font_download_rounded, // Provide better feedback
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
          size: 20, // Slightly smaller icon
        ),
        const SizedBox(width: 12),
        Text(
          fontName,
          style: fontStyle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color greyColor = Colors.grey.shade600;

    return AppBar(
      title: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'E',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
      // backgroundColor: Theme.of(context).colorScheme.surface, // From theme
      elevation: 0, // From theme
      actions: [
        IconButton(
          icon: Icon(
            isMarkdownPreviewEnabled ? Icons.article_rounded : Icons.article_outlined,
            color: isMarkdownPreviewEnabled ? primaryColor : greyColor,
          ),
          onPressed: onToggleMarkdownPreview,
          tooltip: isMarkdownPreviewEnabled ? 'Switch to Plain Text Editor' : 'Preview as Markdown',
        ),
        IconButton(
          icon: const Icon(Icons.paste_rounded),
          onPressed: onPaste,
          tooltip: '从剪贴板粘贴',
          color: primaryColor,
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.add_circle_outline_rounded, color: primaryColor),
          tooltip: '添加内容选项',
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: () => Future.microtask(onToggleQrInput), // Use Future.microtask for PopUpMenuItem
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      color: showQrCodeInput ? primaryColor : greyColor,
                    ),
                    const SizedBox(width: 12),
                    const Text('添加/编辑二维码'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => Future.microtask(onToggleFooterTextInput),
                child: Row(
                  children: [
                    Icon(
                      Icons.short_text_rounded,
                      color: showFooterTextInput ? primaryColor : greyColor,
                    ),
                    const SizedBox(width: 12),
                    const Text('添加/编辑底部文本'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () => Future.microtask(onToggleFooterVisibility),
                child: Row(
                  children: [
                    Icon(
                      showFooterInImage ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(showFooterInImage ? '在图片中隐藏底部' : '在图片中显示底部'),
                  ],
                ),
              ),
            ];
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_sweep_rounded),
          onPressed: onClearContent,
          tooltip: '清除内容',
          color: Colors.redAccent.shade200,
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.palette_outlined, color: primaryColor),
          tooltip: '样式选项',
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: () => Future.microtask(onPickTextColor),
                child: Row(
                  children: [
                    Icon(Icons.format_color_text_rounded, color: primaryColor),
                    const SizedBox(width: 12),
                    const Text('文字颜色'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => Future.microtask(onPickBackgroundColor),
                child: Row(
                  children: [
                    Icon(Icons.format_paint_rounded, color: primaryColor),
                    const SizedBox(width: 12),
                    const Text('背景颜色'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => Future.microtask(onShowFontSizeDialog),
                child: Row(
                  children: [
                    Icon(Icons.format_size_rounded, color: primaryColor),
                    const SizedBox(width: 12),
                    const Text('字体大小'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ..._fontOptions.keys.map((fontName) {
                return PopupMenuItem<String>(
                  value: fontName, // Value is important for PopUpMenuButton
                  onTap: () => Future.microtask(() => onChangeFontFamily(fontName)),
                  child: _buildFontMenuItem(context, fontName),
                );
              }),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
