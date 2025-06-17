import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeInputSection extends StatelessWidget {
  final TextEditingController qrCodeController;
  final VoidCallback? onQrChanged; // To trigger updates in parent if needed

  const QrCodeInputSection({
    super.key,
    required this.qrCodeController,
    this.onQrChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Use a ListenableBuilder to rebuild only this section when qrCodeController changes
    return ListenableBuilder(
      listenable: qrCodeController,
      builder: (context, child) {
        return Card(
          // color: Colors.white, // From theme
          // elevation: 0, // From theme
          // shape: RoundedRectangleBorder( // From theme or customized
          //   borderRadius: BorderRadius.circular(16),
          //   side: BorderSide(color: Colors.grey.shade200, width: 1),
          // ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '二维码内容',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qrCodeController,
                  decoration: const InputDecoration(
                    hintText: '输入要转换为二维码的内容',
                    prefixIcon: Icon(Icons.qr_code_rounded),
                  ),
                  onChanged: (value) {
                    // setState is handled by ListenableBuilder listening to controller
                    onQrChanged?.call();
                  },
                ),
                if (qrCodeController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            color: Colors.white, // Ensure QR background is white for readability
                          ),
                          child: QrImageView(
                            data: qrCodeController.text,
                            version: QrVersions.auto,
                            size: 80,
                            backgroundColor: Colors.transparent, // Container handles background
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '二维码预览: "${qrCodeController.text}"',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
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
}
