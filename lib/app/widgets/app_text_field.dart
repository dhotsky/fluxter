import 'package:flutter/material.dart';
import 'package:fluxter/app/theme/app_color.dart';
import 'package:fluxter/app/utils/extensions/extensions.dart';
import 'package:fluxter/app/widgets/app_button.dart';

enum AppTextFieldVariant { outlined, underline, basic, floating }

/// A reusable TextField component that supports multiple visual variants,
/// password visibility toggling, leading/trailing icons, and error handling.
class AppTextField extends StatefulWidget {
  final AppTextFieldVariant variant;
  final TextEditingController? controller;
  final String? title;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.variant = AppTextFieldVariant.outlined,
    this.controller,
    this.title,
    this.hintText,
    this.labelText,
    this.errorText,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.isDense = true,
    this.contentPadding,
    this.onTap,
  });

  const AppTextField.outlined({
    super.key,
    this.controller,
    this.title,
    this.hintText,
    this.labelText,
    this.errorText,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.isDense = true,
    this.contentPadding,
    this.onTap,
  }) : variant = AppTextFieldVariant.outlined;

  const AppTextField.underline({
    super.key,
    this.controller,
    this.title,
    this.hintText,
    this.labelText,
    this.errorText,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.isDense = true,
    this.contentPadding,
    this.onTap,
  }) : variant = AppTextFieldVariant.underline;

  const AppTextField.basic({
    super.key,
    this.controller,
    this.title,
    this.hintText,
    this.labelText,
    this.errorText,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.isDense = true,
    this.contentPadding,
    this.onTap,
  }) : variant = AppTextFieldVariant.basic;

  const AppTextField.floating({
    super.key,
    this.controller,
    this.title,
    this.hintText,
    this.labelText,
    this.errorText,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.isDense = true,
    this.contentPadding,
    this.onTap,
  }) : variant = AppTextFieldVariant.floating;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    Widget? buildSuffixIcon() {
      if (widget.isPassword) {
        return AppButton.custom(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: context.textTertiary,
          ),
        );
      }
      return widget.suffixIcon;
    }

    final inputDecoration = _getDecoration(context).copyWith(
      hintText: widget.hintText,
      labelText: widget.labelText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: buildSuffixIcon(),
    );

    Widget buildTextField() {
      return TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        validator: widget.validator,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        onTap: widget.onTap,
        decoration: inputDecoration,
        style: TextStyle(fontSize: 15, color: context.textPrimary),
      );
    }

    Widget textFieldWidget = buildTextField();

    if (widget.variant == AppTextFieldVariant.floating) {
      textFieldWidget = Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: textFieldWidget,
      );
    }

    if (widget.title != null) {
      final isCompact =
          widget.variant == AppTextFieldVariant.underline ||
          widget.variant == AppTextFieldVariant.basic;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title!,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          isCompact ? 2.height : 8.height,
          textFieldWidget,
        ],
      );
    }

    return textFieldWidget;
  }

  InputDecoration _getDecoration(BuildContext context) {
    switch (widget.variant) {
      case AppTextFieldVariant.outlined:
        return InputDecoration(
          filled: true,
          isDense: widget.isDense,
          fillColor: context.surface,
          contentPadding:
              widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.divider),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.error),
          ),
        );
      case AppTextFieldVariant.underline:
        return InputDecoration(
          filled: false,
          isDense: widget.isDense,
          contentPadding:
              widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: context.divider),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.divider),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColor.primary, width: 1.5),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColor.error),
          ),
        );
      case AppTextFieldVariant.basic:
        return InputDecoration(
          filled: false,
          isDense: widget.isDense,
          contentPadding:
              widget.contentPadding ?? EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
        );
      case AppTextFieldVariant.floating:
        return InputDecoration(
          filled: false,
          isDense: widget.isDense,
          contentPadding:
              widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.error),
          ),
        );
    }
  }
}
