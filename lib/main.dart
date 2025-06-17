import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

import 'theme.dart';
import 'utils/snackbar_util.dart' as snackbar_util;
import 'utils/dialog_helper.dart' as dialog_helper;
import 'utils/image_handler.dart';
import 'utils/markdown_detector.dart' as markdown_detector;

import 'widgets/home_app_bar.dart';
import 'widgets/qr_code_input_section.dart';
import 'widgets/footer_input_section.dart';
import 'widgets/content_display_input_area.dart';
import 'widgets/home_action_buttons.dart';
import 'widgets/captured_content_widget.dart';
import 'widgets/color_picker_dialog.dart' as color_picker_dialog;
import 'widgets/font_size_dialog.dart' as font_size_dialog;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyShare',
      theme: AppTheme.getTheme(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _qrCodeController = TextEditingController();
  final TextEditingController _footerTextController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contentKey = GlobalKey();

  Color _textColor = Colors.black;
  Color _backgroundColor = Colors.white;
  double _fontSize = 18.0;
  String _fontFamily = 'Nunito';
  bool _showQrCodeInput = false;
  bool _showFooterTextInput = false;
  bool _showFooterInImage = true;
  bool _isMarkdownPreviewEnabled = false;
  bool _isSavingImage = false;
  bool _isSharingImage = false;

  String? _lastCheckedClipboardContent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLastCheckedClipboardContent();
    });
    _textController.addListener(_onTextChanged);
    _qrCodeController.addListener(_onTextChanged);
    _footerTextController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _qrCodeController.removeListener(_onTextChanged);
    _qrCodeController.dispose();
    _footerTextController.removeListener(_onTextChanged);
    _footerTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkClipboardOnResume();
    }
  }

  Future<void> _updateLastCheckedClipboardContent() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    _lastCheckedClipboardContent = data?.text;
  }

  Future<void> _checkClipboardOnResume() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final newClipboardText = data?.text;

    if (newClipboardText != null && newClipboardText.isNotEmpty && newClipboardText != _lastCheckedClipboardContent) {
      await _handlePastedText(newClipboardText);
    } else if (newClipboardText != null && newClipboardText.isNotEmpty && _lastCheckedClipboardContent == null) {
      await _handlePastedText(newClipboardText);
    }
  }

  Future<void> _handlePastedText(String pastedText) async {
    _lastCheckedClipboardContent = pastedText;

    if (pastedText == _textController.text) {
      snackbar_util.showSnackbar(context, '剪贴板内容与当前内容相同');
      return;
    }

    _textController.text = pastedText;
    bool shouldResetPreview = _isMarkdownPreviewEnabled;
    _isMarkdownPreviewEnabled = false;

    if (markdown_detector.isLikelyMarkdown(pastedText)) {
      final bool? applyStyling = await dialog_helper.showMarkdownPromptDialog(context);
      if (applyStyling == true && mounted) {
        setState(() {
          _isMarkdownPreviewEnabled = true;
        });
        snackbar_util.showSnackbar(context, 'Markdown 样式已应用');
      } else {
        setState(() {});
        snackbar_util.showSnackbar(context, '内容已粘贴 (纯文本)');
      }
    } else {
      setState(() {});
      if (!shouldResetPreview) {
        snackbar_util.showSnackbar(context, '内容已粘贴');
      }
    }
  }

  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      await _handlePastedText(data.text!);
    } else {
      snackbar_util.showSnackbar(context, '剪贴板中没有文本');
    }
  }

  void toggleMarkdownPreview() {
    if (_textController.text.isEmpty && _isMarkdownPreviewEnabled) {
      setState(() {
        _isMarkdownPreviewEnabled = false;
      });
      return;
    }
    if (!_isMarkdownPreviewEnabled && _textController.text.isNotEmpty && !markdown_detector.isLikelyMarkdown(_textController.text)) {
      snackbar_util.showSnackbar(context, '当前内容看起来不是 Markdown，无法切换到预览模式。');
      return;
    }
    if (_textController.text.isEmpty && !_isMarkdownPreviewEnabled) {
      snackbar_util.showSnackbar(context, '没有内容可预览为 Markdown。');
      return;
    }
    setState(() {
      _isMarkdownPreviewEnabled = !_isMarkdownPreviewEnabled;
      if (_isMarkdownPreviewEnabled) {
        snackbar_util.showSnackbar(context, 'Markdown 预览已开启');
      } else {
        snackbar_util.showSnackbar(context, 'Markdown 预览已关闭，显示纯文本');
      }
    });
  }

  Future<Uint8List?> _captureImageForExport() async {
    if (_textController.text.isEmpty && _qrCodeController.text.isEmpty) {
      snackbar_util.showSnackbar(context, '没有内容可截图');
      return null;
    }
    try {
      final contentToCapture = CapturedContentWidget(
        textContent: _textController.text,
        textColor: _textColor,
        backgroundColor: _backgroundColor,
        fontSize: _fontSize,
        fontFamily: _fontFamily,
        showFooterInImage: _showFooterInImage,
        footerText: _footerTextController.text,
        qrCodeData: _qrCodeController.text,
        isMarkdownPreviewEnabled: _isMarkdownPreviewEnabled,
        parentContext: context,
      );

      double targetWidth = MediaQuery.of(context).size.width - 40;
      if (targetWidth <= 0) targetWidth = 300;

      return await _screenshotController.captureFromWidget(
        contentToCapture,
        context: context,
        delay: const Duration(milliseconds: 100),
        targetSize: ui.Size(targetWidth, 200000),
        pixelRatio: MediaQuery.of(context).devicePixelRatio * 1.5,
      );
    } catch (e) {
      debugPrint('截图错误: $e');
      snackbar_util.showSnackbar(context, '截图失败: $e');
      return null;
    }
  }

  void _handleSaveToGallery() async {
    if (_isSavingImage || _isSharingImage) return;

    setState(() {
      _isSavingImage = true;
    });

    try {
      final imageBytes = await _captureImageForExport();
      if (imageBytes != null && mounted) {
        await ImageHandler.saveImageWithPreview(
          context,
          imageBytes: imageBytes,
          imageNamePrefix: 'EasyShare',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingImage = false;
        });
      }
    }
  }

  void _handleShareImage() async {
    if (_isSavingImage || _isSharingImage) return;

    setState(() {
      _isSharingImage = true;
    });

    try {
      final imageBytes = await _captureImageForExport();
      if (imageBytes != null && mounted) {
        await ImageHandler.shareImageWithPreview(
          context,
          imageBytes: imageBytes,
          shareText: '来自EasyShare的分享',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharingImage = false;
        });
      }
    }
  }

  void _handleClearContent() {
    dialog_helper.showClearContentDialog(
      context,
      onClearText: () {
        setState(() {
          _textController.clear();
          _isMarkdownPreviewEnabled = false;
        });
        snackbar_util.showSnackbar(context, '文本内容已清除');
      },
      onClearAll: () {
        setState(() {
          _textController.clear();
          _qrCodeController.clear();
          _footerTextController.clear();
          _isMarkdownPreviewEnabled = false;
        });
        snackbar_util.showSnackbar(context, '所有内容已清除');
      },
    );
  }

  void _toggleQrCodeInput() {
    setState(() {
      _showQrCodeInput = !_showQrCodeInput;
    });
  }

  void _toggleFooterTextInput() {
    setState(() {
      _showFooterTextInput = !_showFooterTextInput;
    });
  }

  void _toggleFooterVisibility() {
    setState(() {
      _showFooterInImage = !_showFooterInImage;
    });
  }

  void _handlePickTextColor() {
    color_picker_dialog.showColorPickerDialog(
      context: context,
      initialColor: _textColor,
      title: '选择文字颜色',
      onColorChanged: (color) {
        setState(() => _textColor = color);
      },
    );
  }

  void _handlePickBackgroundColor() {
    color_picker_dialog.showColorPickerDialog(
      context: context,
      initialColor: _backgroundColor,
      title: '选择背景颜色',
      onColorChanged: (color) {
        setState(() => _backgroundColor = color);
      },
    );
  }

  void _handleChangeFontFamily(String fontFamily) {
    setState(() {
      _fontFamily = fontFamily;
    });
  }

  void _handleShowFontSizeDialog() {
    font_size_dialog.showFontSizeDialog(
      context: context,
      initialSize: _fontSize,
      onSizeChanged: (value) {
        setState(() => _fontSize = value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: HomeAppBar(
        showQrCodeInput: _showQrCodeInput,
        showFooterTextInput: _showFooterTextInput,
        showFooterInImage: _showFooterInImage,
        currentFontFamily: _fontFamily,
        onPaste: _pasteFromClipboard,
        onToggleQrInput: _toggleQrCodeInput,
        onToggleFooterTextInput: _toggleFooterTextInput,
        onToggleFooterVisibility: _toggleFooterVisibility,
        onClearContent: _handleClearContent,
        onPickTextColor: _handlePickTextColor,
        onPickBackgroundColor: _handlePickBackgroundColor,
        onShowFontSizeDialog: _handleShowFontSizeDialog,
        onChangeFontFamily: _handleChangeFontFamily,
        isMarkdownPreviewEnabled: _isMarkdownPreviewEnabled,
        onToggleMarkdownPreview: toggleMarkdownPreview,
      ),
      body: SafeArea(
        child: Container(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(builder: (context, constraints) {
                return Column(
                  children: [
                    Wrap(
                      runSpacing: 16,
                      spacing: 16,
                      children: [
                        if (_showQrCodeInput)
                          QrCodeInputSection(
                            qrCodeController: _qrCodeController,
                            onQrChanged: _onTextChanged,
                          ),
                        if (_showFooterTextInput)
                          FooterInputSection(
                            footerTextController: _footerTextController,
                            showFooterInImage: _showFooterInImage,
                            onFooterTextChanged: (value) => _onTextChanged(),
                            onShowFooterInImageChanged: (value) {
                              setState(() {
                                _showFooterInImage = value;
                              });
                            },
                          ),
                      ],
                    ),
                    if (_showQrCodeInput || _showFooterTextInput) const SizedBox(height: 16),
                    Expanded(
                      child: ContentDisplayInputArea(
                        textController: _textController,
                        textColor: _textColor,
                        backgroundColor: _backgroundColor,
                        fontSize: _fontSize,
                        fontFamily: _fontFamily,
                        showFooterInImage: _showFooterInImage,
                        footerText: _footerTextController.text,
                        qrCodeData: _qrCodeController.text,
                        scrollController: _scrollController,
                        contentKey: _contentKey,
                        onTextChanged: _onTextChanged,
                        isMarkdownPreviewEnabled: _isMarkdownPreviewEnabled,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HomeActionButtons(
                      onSavePressed: _handleSaveToGallery,
                      onSharePressed: _handleShareImage,
                      isSaving: _isSavingImage,
                      isSharing: _isSharingImage,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
