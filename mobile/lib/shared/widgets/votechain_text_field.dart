import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Stitch-matched text field with leading icon and focus glow.
class VoteChainTextField extends StatelessWidget {
  const VoteChainTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
    this.inputFormatters,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Focus(
          child: Builder(
            builder: (context) {
              final focused = Focus.of(context).hasFocus;
              final hasError = errorText != null && errorText!.isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.inputBorder,
                  border: Border.all(
                    color: hasError
                        ? AppColors.error
                        : focused
                            ? AppColors.brandSecondary
                            : AppColors.outlineVariant,
                    width: 1,
                  ),
                  boxShadow: focused && !hasError
                      ? [
                          BoxShadow(
                            color: AppColors.primaryDisplay.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 15,
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  obscureText: obscureText,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  inputFormatters: inputFormatters,
                  autofillHints: autofillHints,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: hint,
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    prefixIcon: Icon(
                      icon,
                      color: focused
                          ? AppColors.primaryDisplay
                          : AppColors.onSurfaceVariant,
                    ),
                    suffixIcon: suffix,
                  ),
                ),
              );
            },
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              errorText!,
              style: textTheme.labelMedium?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }

  bool get hasError => errorText != null && errorText!.isNotEmpty;
}
