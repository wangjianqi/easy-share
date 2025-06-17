import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CapturedContentWidget extends StatelessWidget {
  final String textContent;
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;
  final String fontFamily;
  final bool showFooterInImage;
  final String footerText;
  final String qrCodeData;
  final bool isMarkdownPreviewEnabled;
  final BuildContext parentContext; // To access Theme.of(parentContext)

  const CapturedContentWidget({
    super.key,
    required this.textContent,
    required this.textColor,
    required this.backgroundColor,
    required this.fontSize,
    required this.fontFamily,
    required this.showFooterInImage,
    required this.footerText,
    required this.qrCodeData,
    required this.isMarkdownPreviewEnabled,
    required this.parentContext,
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
    return GoogleFonts.nunito(textStyle: baseStyle); // Default to Nunito if family not found
  }

  MarkdownStyleSheet _getMarkdownStyleSheet(BuildContext context, TextStyle baseTextStyle) {
    final theme = Theme.of(context); // Use the passed build context
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
      a: baseTextStyle.copyWith(color: theme.colorScheme.secondary, decoration: TextDecoration.underline),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use parentContext for Theme access, as this widget might be built
    // by screenshot controller outside the main widget tree's context directly.
    final theme = Theme.of(parentContext);
    final baseTextStyle = _getCurrentFontStyle(TextStyle(
      color: textColor,
      fontSize: fontSize,
      height: 1.4, // Improved line height
    ));

    Widget mainContent;
    if (isMarkdownPreviewEnabled && textContent.isNotEmpty) {
      mainContent = MarkdownBody(
        data: textContent,
        styleSheet: _getMarkdownStyleSheet(parentContext, baseTextStyle), // Use parentContext here for theme
      );
    } else if (textContent.isNotEmpty) {
      mainContent = SelectableText(
        textContent,
        style: baseTextStyle,
      );
    } else {
      // If textContent is empty, mainContent can be an empty SizedBox or similar placeholder.
      // This is to avoid rendering MarkdownBody with empty data, which might cause issues.
      mainContent = const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent, // Ensure Material itself is transparent
      child: Container(
        padding: const EdgeInsets.all(20),
        // Width constraint will be applied by captureFromLongDynamicWidget via RenderConstrainedBox
        // width: MediaQuery.of(parentContext).size.width - 40, // Not needed here, handled by capturer
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08), // Softer shadow for image
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mainContent, // TextField or MarkdownBody
            if (textContent.isEmpty && qrCodeData.isNotEmpty && showFooterInImage) // Show footer if only QR code is there
              const SizedBox(height: 10), // Some space if only QR + footer

            if (showFooterInImage && (textContent.isNotEmpty || (isMarkdownPreviewEnabled && textContent.isNotEmpty) || qrCodeData.isNotEmpty)) _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: (textContent.isNotEmpty || (isMarkdownPreviewEnabled && textContent.isNotEmpty)) ? 40 : 20, thickness: 0.8, color: Colors.grey.shade300),
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
                      color: theme.colorScheme.primary, // Use theme color
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
                            color: theme.colorScheme.primary, // Use theme color
                          ),
                        ),
                        if (footerText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              footerText,
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
            if (qrCodeData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16), // Add some space if text is also present
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // QR codes need a white background
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: QrImageView(
                    data: qrCodeData,
                    version: QrVersions.auto,
                    size: 70,
                    // Slightly smaller for footer
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
    );
  }
}
