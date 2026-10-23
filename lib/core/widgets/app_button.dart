import 'package:flutter/material.dart';

/// Reusable primary button supporting loading indicator and disabled states.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? Colors.white;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: effectiveTextColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: effectiveTextColor,
            ),
          ),
        ],
      );
    } else {
      childContent = Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: effectiveTextColor,
        ),
      );
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(isFullWidth ? double.infinity : 0, height),
        disabledBackgroundColor: Theme.of(context).primaryColor
            .withValues(alpha: 0.6),
      ),
      child: childContent,
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, height: height, child: button)
        : button;
  }
}
