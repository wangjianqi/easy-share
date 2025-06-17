import 'package:flutter/material.dart';

class HomeActionButtons extends StatelessWidget {
  final VoidCallback? onSavePressed;
  final VoidCallback? onSharePressed;
  final bool isSaving;
  final bool isSharing;

  const HomeActionButtons({
    super.key,
    required this.onSavePressed,
    required this.onSharePressed,
    required this.isSaving,
    required this.isSharing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isSaveDisabled = isSaving || onSavePressed == null;
    final bool isShareDisabled = isSharing || onSharePressed == null;

    Widget buildButtonChild(String label, IconData icon, bool isLoading) {
      if (isLoading) {
        return const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
        );
      }
    }

    Widget buildOutlinedButtonChild(String label, IconData icon, bool isLoading, Color indicatorColor) {
      if (isLoading) {
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: indicatorColor,
          ),
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
        );
      }
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSaveDisabled || isSharing ? null : onSavePressed,
            label: Text(isSaving ? '保存中...' : '保存到相册'),
            icon: buildButtonChild('', Icons.save_alt_rounded, isSaving),
            style: theme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.disabled)) return Colors.grey.shade400;
                return theme.colorScheme.primary;
              }),
              foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.disabled)) return Colors.grey.shade700;
                return theme.colorScheme.onPrimary;
              }),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isShareDisabled || isSaving ? null : onSharePressed,
            label: Text(isSharing ? '分享中...' : '分享图片'),
            icon: buildOutlinedButtonChild('', Icons.share_rounded, isSharing, theme.colorScheme.primary),
            style: theme.outlinedButtonTheme.style?.copyWith(
              side: MaterialStateProperty.resolveWith<BorderSide?>((states) {
                if (states.contains(MaterialState.disabled)) return BorderSide(color: Colors.grey.shade400);
                return BorderSide(color: theme.colorScheme.primary, width: 1.5);
              }),
              foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.disabled)) return Colors.grey.shade600;
                return theme.colorScheme.primary;
              }),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
            ),
          ),
        ),
      ],
    );
  }
}
