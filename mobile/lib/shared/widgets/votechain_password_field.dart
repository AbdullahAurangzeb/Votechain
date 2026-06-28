import 'package:flutter/material.dart';

import '../../theme/app_icons.dart';
import 'votechain_text_field.dart';

/// Password field with visibility toggle — Stitch auth pattern.
class VoteChainPasswordField extends StatefulWidget {
  const VoteChainPasswordField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.focusNode,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  State<VoteChainPasswordField> createState() => _VoteChainPasswordFieldState();
}

class _VoteChainPasswordFieldState extends State<VoteChainPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return VoteChainTextField(
      label: widget.label,
      hint: widget.hint,
      icon: AppIcons.lock,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscure,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      suffix: IconButton(
        icon: Icon(
          _obscure ? AppIcons.visibility : AppIcons.visibilityOff,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
