import 'package:flutter/material.dart';
import '../../../../core/theme/theme_exports.dart';
import '../../../../core/utils/utils_exports.dart';

/// Shared presentational pieces for rendering a measurement template's
/// fields — used by both `MeasurementFormView` (the full take-measurement
/// screen) and `AddCustomerWizardView`'s condensed measurement step, so a
/// visual tweak to one of these only has to be made once.

/// Full-width selectable "pill" row — a small tinted icon badge plus a
/// bold label on a lightly-tinted (selected) or plain (unselected)
/// background. Used both interactively (a category picker, [onTap]
/// switches the selection) and as a plain divider (always [selected] and
/// not tappable) — one consistent "pill header" visual language for every
/// kind of grouping.
class PillHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const PillHeader({
    super.key,
    required this.icon,
    required this.label,
    this.selected = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? context.primary.withValues(alpha: 0.1) : context.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: selected ? null : Border.all(color: context.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: selected
                  ? context.primary.withValues(alpha: 0.16)
                  : context.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: selected ? context.primary : context.textSecondary),
          ),
          widthBox(10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium.copyWith(
                color: selected ? context.primary : context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return onTap == null ? bar : bar.onTap(onTap!);
  }
}

/// +/- stepper button for `counter`-type fields (e.g. pocket count) and
/// quantity pickers.
class StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const StepperButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final button = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: enabled
            ? context.primary.withValues(alpha: 0.12)
            : context.border.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 15, color: enabled ? context.primary : context.textDisabled),
    );
    return onTap == null ? button : button.onTap(onTap!);
  }
}

/// Shared individually-bordered box for a number/counter/dropdown field.
/// [label] is optional: number and dropdown fields pass null and instead
/// put their label in the [child] control's own hint text (one line, no
/// redundant label-above-input) — only `counter` (a stepper has no
/// hint-capable control to carry a label) passes [label] to render it
/// above [child]. Sized to [width] by the caller, height grows to fit its
/// own content instead of being forced into a uniform grid-cell height.
class FieldBox extends StatelessWidget {
  final double width;
  final String? label;
  final Widget child;

  const FieldBox({super.key, required this.width, this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.divider),
        ),
        child: label == null
            ? child
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label!, style: context.labelSmall.copyWith(color: context.textSecondary)),
                  heightBox(4),
                  child,
                ],
              ),
      ),
    );
  }
}

/// A `checkbox`-type field's own box — label (left, can wrap to two lines
/// for a long option name) plus a trailing [Checkbox], instead of
/// [FieldBox]'s label-above-value layout, since this field has no separate
/// "value line" to show.
class CheckboxFieldBox extends StatelessWidget {
  final double width;
  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const CheckboxFieldBox({
    super.key,
    required this.width,
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: context.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Checkbox(
              value: checked,
              activeColor: context.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onChanged: (value) => onChanged(value ?? false),
            ),
          ],
        ),
      ),
    );
  }
}
