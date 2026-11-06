import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/theme_utils.dart';

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  /// Runs after [asyncValidatorDebounce] of no typing, e.g. an
  /// availability check against an API ("is this username taken?").
  /// Its result is merged with [validator] — [validator] wins if both
  /// return a non-null error.
  final Future<String?> Function(String?)? asyncValidator;
  final Duration asyncValidatorDebounce;

  /// External error to display regardless of [validator]/[asyncValidator]
  /// — e.g. a server-side error surfaced from a Bloc's `FAILURE` state
  /// after submit ("Email already registered"). Clears on next edit.
  final String? errorText;

  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final Color? fillColor;
  final Color? borderColor;
  final Color? labelColor;
  final bool isRequired;
  final int labelFontSize;
  final bool readOnly;
  final double borderRadius;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.label,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.isRequired = false,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 10,
    this.controller,
    this.focusNode,
    this.labelColor,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.sentences,
    this.validator,
    this.asyncValidator,
    this.asyncValidatorDebounce = const Duration(milliseconds: 500),
    this.errorText,
    this.labelFontSize = 16,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool isObscure;
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  Timer? _debounce;
  String? _asyncError;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    isObscure = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant CustomTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      _fieldKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    if (widget.asyncValidator == null) return;

    _debounce?.cancel();
    if (_asyncError != null || _isValidating) {
      setState(() {
        _asyncError = null;
        _isValidating = false;
      });
    }
    _debounce = Timer(widget.asyncValidatorDebounce, () => _runAsyncValidator(value));
  }

  Future<void> _runAsyncValidator(String value) async {
    setState(() => _isValidating = true);
    final error = await widget.asyncValidator!(value);
    if (!mounted) return;
    setState(() {
      _isValidating = false;
      _asyncError = error;
    });
    _fieldKey.currentState?.validate();
  }

  String? _validate(String? value) {
    if (widget.errorText != null) return widget.errorText;
    return widget.validator?.call(value) ?? _asyncError;
  }

  @override
  Widget build(BuildContext context) {
    final defaultBorderColor = widget.borderColor ?? context.border;
    final defaultLabelColor = widget.labelColor ?? context.textSecondary;
    final defaultFillColor = widget.fillColor ?? context.surfaceElevated;
    // [label] is a floating label, not a separate row above the field —
    // it sits inline like a hint when the field is empty and unfocused,
    // then floats above the value once focused or filled, so the field's
    // identity stays visible after typing instead of vanishing the way a
    // plain hint would. [hintText] is only a fallback for the rare field
    // with no label at all.
    final effectiveLabel = widget.label != null
        ? '${widget.label}${widget.isRequired ? ' *' : ''}'
        : null;

    // Priority: password toggle > validating spinner > custom suffixIcon.
    Widget? effectiveSuffix;
    if (widget.obscureText) {
      effectiveSuffix = IconButton(
        icon: Icon(isObscure ? Iconsax.eye_slash : Iconsax.eye, color: context.grey500, size: 20),
        onPressed: () => setState(() => isObscure = !isObscure),
      );
    } else if (_isValidating) {
      effectiveSuffix = const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    } else {
      effectiveSuffix = widget.suffixIcon;
    }

    return TextFormField(
      key: _fieldKey,
      autofocus: false,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
      readOnly: widget.readOnly,
      focusNode: widget.focusNode,
      style: context.bodySmall.copyWith(color: context.textPrimary),
      controller: widget.controller,
      obscureText: isObscure,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      decoration: InputDecoration(
        labelText: effectiveLabel,
        hintText: effectiveLabel == null ? widget.hintText : null,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: context.bodySmall.copyWith(
          color: defaultLabelColor,
          fontSize: widget.labelFontSize.toDouble(),
        ),
        hintStyle: context.bodySmall.copyWith(
          color: defaultLabelColor,
          fontSize: widget.labelFontSize.toDouble(),
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: context.grey500, size: 20)
            : null,
        suffixIcon: effectiveSuffix,
        // Filled with `context.surfaceElevated` (white in light mode) by
        // default — this used to default to `context.surface`, which was
        // the exact same grey as the screen background and read as an
        // unintentional smudge rather than a card. Pass [fillColor]
        // explicitly to override.
        filled: true,
        fillColor: defaultFillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: context.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: context.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: context.error, width: 2),
        ),
      ),
      validator: _validate,
      onChanged: _handleChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
    );
  }
}
