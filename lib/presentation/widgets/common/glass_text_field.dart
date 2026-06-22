import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../design_tokens/design_tokens.dart';

class GlassTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final TextAlign textAlign;
  final TextStyle? style;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  const GlassTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      maxLength: maxLength,
      textAlign: textAlign,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: enabled,
      style: style ??
          const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            color: Colors.white,
            fontSize: 15,
            fontWeight: DesignTokens.weightMedium,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? IconTheme(
                data: const IconThemeData(color: DesignTokens.teal300, size: 22),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: prefixIcon!,
                ),
              )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: DesignTokens.navy700.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DesignTokens.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DesignTokens.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DesignTokens.teal300, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DesignTokens.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DesignTokens.error, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          color: AppTheme.darkTextSecondary,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 15,
        ),
        errorStyle: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          color: DesignTokens.error,
          fontSize: 12,
        ),
      ),
    );
  }
}
