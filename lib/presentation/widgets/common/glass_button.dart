import 'package:flutter/material.dart';
import '../../../design_tokens/design_tokens.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final Widget? icon;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isSecondary
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: DesignTokens.tealGradient,
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.tealGlow.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.transparent : null,
          foregroundColor: isSecondary ? DesignTokens.teal300 : DesignTokens.navy900,
          disabledBackgroundColor: isSecondary
              ? Colors.white.withValues(alpha: 0.05)
              : DesignTokens.teal500.withValues(alpha: 0.5),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSecondary
                ? const BorderSide(color: DesignTokens.glassBorder)
                : BorderSide.none,
          ),
          textStyle: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 16,
            fontWeight: DesignTokens.weightSemiBold,
            letterSpacing: 0.3,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? DesignTokens.teal300 : DesignTokens.navy900,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}
