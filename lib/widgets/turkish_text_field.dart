import 'package:flutter/material.dart';

/// Türkçe karakter girişine uygun metin alanı.
class TurkishTextField extends StatelessWidget {
  const TurkishTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.style,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      style: style,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: true,
      enableSuggestions: true,
      smartDashesType: SmartDashesType.enabled,
      smartQuotesType: SmartQuotesType.enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
    );
  }
}
