import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/image_preview_dialog.dart';
import 'snackbar_util.dart' as snackbar_util;

class ImageHandler {
  static Future<bool> _requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Storage permission primarily for Android/iOS
      var status = await Permission.storage.status;
      if (Platform.isAndroid && (await _getAndroidSdkInt()) >= 30) {
        // Android 11+ uses manageExternalStorage or scoped storage
        status = await Permission.manageExternalStorage.status; // Or use scoped storage if not writing to common dirs
      }

      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (Platform.isAndroid && (await _getAndroidSdkInt()) >= 30 && !status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }
      }
      if (!status.isGranted) {
        snackbar_util.showSnackbar(context, '需要存储权限才能保存图片');
        return false;
      }
    }
    return true;
  }

  static Future<int> _getAndroidSdkInt() async {
    // This is a placeholder. In a real app, you might use a plugin
    // like `device_info_plus` to get the Android SDK version.
    // For now, assume a recent SDK version if on Android.
    if (Platform.isAndroid) return 30; // Assume API 30 for testing purposes
    return 0;
  }

  static Future<void> saveImageWithPreview(
    BuildContext context, {
    required Uint8List imageBytes,
    String imageNamePrefix = 'shared_image',
  }) async {
    try {
      snackbar_util.showSnackbar(context, '正在准备图片...');
      await showImagePreviewDialog(
        context: context,
        imageBytes: imageBytes,
        onConfirm: () async {
          final bool permissionGranted = await _requestStoragePermission(context);
          if (!permissionGranted) return;

          try {
            snackbar_util.showSnackbar(context, '正在保存图片...');
            final result = await ImageGallerySaver.saveImage(
              imageBytes,
              quality: 100,
              name: '${imageNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.png',
            );

            if (result['isSuccess']) {
              snackbar_util.showSnackbar(context, '图片已保存到相册');
            } else {
              snackbar_util.showSnackbar(context, '保存图片失败: ${result["errorMessage"] ?? "未知错误"}');
            }
          } catch (e) {
            snackbar_util.showSnackbar(context, '保存图片时发生错误: $e');
          }
        },
      );
    } catch (e) {
      snackbar_util.showSnackbar(context, '处理图片时发生错误: $e');
    }
  }

  static Future<void> shareImageWithPreview(
    BuildContext context, {
    required Uint8List imageBytes,
    String shareText = 'Shared Image',
  }) async {
    try {
      snackbar_util.showSnackbar(context, '正在准备图片...');
      await showImagePreviewDialog(
        context: context,
        imageBytes: imageBytes,
        onConfirm: () async {
          try {
            snackbar_util.showSnackbar(context, '正在准备分享...');
            final tempDir = Directory.systemTemp;
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final file = File('${tempDir.path}/share_image_$timestamp.png');
            await file.writeAsBytes(imageBytes);

            await Share.shareXFiles(
              [XFile(file.path)],
              text: shareText,
            );
            // No need to show snackbar on success, share sheet handles it.
            // Attempt to clean up the temporary file, though not critical
            file.delete().catchError((_) {/* Ignore */});
          } catch (e) {
            snackbar_util.showSnackbar(context, '分享图片时发生错误: $e');
          }
        },
      );
    } catch (e) {
      snackbar_util.showSnackbar(context, '处理图片时发生错误: $e');
    }
  }
}
