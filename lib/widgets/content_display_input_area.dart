import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ContentDisplayInputArea extends StatelessWidget {
  final TextEditingController textController;
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;
  final String fontFamily;
  final bool showFooterInImage;
  final String footerText;
  final String qrCodeData;
  final ScrollController scrollController;
  final GlobalKey? contentKey;
  final VoidCallback? onTextChanged;
  final bool isMarkdownPreviewEnabled;

  const ContentDisplayInputArea({
    super.key,
    required this.textController,
    required this.textColor,
    required this.backgroundColor,
    required this.fontSize,
    required this.fontFamily,
    required this.showFooterInImage,
    required this.footerText,
    required this.qrCodeData,
    required this.scrollController,
    this.contentKey,
    this.onTextChanged,
    required this.isMarkdownPreviewEnabled,
  });

  static final Map<String, TextStyle Function(TextStyle)> _fontOptions = {
    'Nunito': (baseStyle) => GoogleFonts.nunito(textStyle: baseStyle),
    'Roboto': (baseStyle) => GoogleFonts.roboto(textStyle: baseStyle),
    'Open Sans': (baseStyle) => GoogleFonts.openSans(textStyle: baseStyle),
    'Montserrat': (baseStyle) => GoogleFonts.montserrat(textStyle: baseStyle),
    'Source Code Pro': (baseStyle) => GoogleFonts.sourceCodePro(textStyle: baseStyle),
  };

  TextStyle _getCurrentFontStyle(TextStyle baseStyle) {
    final fontStyler = _fontOptions[fontFamily];
    if (fontStyler != null) {
      return fontStyler(baseStyle);
    }
    return GoogleFonts.nunito(textStyle: baseStyle); // Default
  }

  MarkdownStyleSheet _getMarkdownStyleSheet(BuildContext context, TextStyle baseTextStyle) {
    final theme = Theme.of(context);
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: baseTextStyle,
      h1: baseTextStyle.copyWith(fontSize: fontSize * 1.8, fontWeight: FontWeight.bold),
      h2: baseTextStyle.copyWith(fontSize: fontSize * 1.6, fontWeight: FontWeight.bold),
      h3: baseTextStyle.copyWith(fontSize: fontSize * 1.4, fontWeight: FontWeight.bold),
      h4: baseTextStyle.copyWith(fontSize: fontSize * 1.2, fontWeight: FontWeight.bold),
      h5: baseTextStyle.copyWith(fontSize: fontSize * 1.1, fontWeight: FontWeight.bold),
      h6: baseTextStyle.copyWith(fontSize: fontSize, fontWeight: FontWeight.bold),
      em: baseTextStyle.copyWith(fontStyle: FontStyle.italic),
      strong: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
      del: baseTextStyle.copyWith(decoration: TextDecoration.lineThrough),
      blockquote: baseTextStyle.copyWith(color: Colors.grey.shade700),
      img: baseTextStyle,
      listBullet: baseTextStyle.copyWith(color: textColor.withOpacity(0.8)),
      codeblockDecoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300)),
      code: baseTextStyle.copyWith(backgroundColor: Colors.grey.shade200, fontFamily: 'Source Code Pro'),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1.0, color: Colors.grey.shade400)),
      ),
      tableHead: baseTextStyle.copyWith(fontWeight: FontWeight.w600),
      tableBorder: TableBorder.all(color: Colors.grey.shade400, width: 1),
      tableCellsDecoration: const BoxDecoration(color: Colors.transparent),
      a: baseTextStyle.copyWith(color: Theme.of(context).colorScheme.secondary, decoration: TextDecoration.underline),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextStyle = _getCurrentFontStyle(TextStyle(
      color: textColor,
      fontSize: fontSize,
      height: 1.4,
    ));

    Widget mainContent;
    if (isMarkdownPreviewEnabled) {
      mainContent = MarkdownBody(
        data: textController.text,
        selectable: true,
        styleSheet: _getMarkdownStyleSheet(context, baseTextStyle),
      );
    } else {
      mainContent = TextField(
        controller: textController,
        style: baseTextStyle,
        decoration: const InputDecoration(
          hintText: '粘贴或输入内容...',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        onChanged: (_) => onTextChanged?.call(),
      );
    }

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          key: contentKey,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                mainContent,
                if (showFooterInImage && (textController.text.isNotEmpty || qrCodeData.isNotEmpty)) _buildFooter(theme, textController.text, footerText, qrCodeData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, String mainText, String customFooterText, String currentQrCodeData) {
    return Padding(
      padding: EdgeInsets.only(top: mainText.isNotEmpty ? 20 : 0), // Add top padding only if main text exists
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: mainText.isNotEmpty ? 40 : 20, thickness: 0.8, color: Colors.grey.shade300),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'E',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'EasyShare',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (customFooterText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                customFooterText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (currentQrCodeData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: QrImageView(
                      data: currentQrCodeData,
                      version: QrVersions.auto,
                      size: 70,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(6),
                      eyeStyle: QrEyeStyle(color: theme.colorScheme.primary, eyeShape: QrEyeShape.square),
                      dataModuleStyle: QrDataModuleStyle(color: theme.colorScheme.primary, dataModuleShape: QrDataModuleShape.square),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
