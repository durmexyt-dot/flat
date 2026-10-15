import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'tokens.dart';

/// A segmented control built on Forui tabs: one tab per value, without tab
/// content; the page shows the content for [selected] itself.
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.icon,
    this.scrollable = false,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final IconData Function(T value)? icon;
  final ValueChanged<T> onChanged;

  /// For many or long labels, e.g. filters on phones.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return FTabs(
      scrollable: scrollable,
      control: FTabControl.lifted(
        index: values.indexOf(selected),
        onChange: (i) => onChanged(values[i]),
      ),
      style: const .delta(spacing: 0),
      children: [
        for (final v in values)
          FTabEntry(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Space.sm,
              children: [
                if (icon != null) Icon(icon!(v), size: IconSizes.sm),
                Flexible(
                  child: Text(
                    label(v),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            child: const SizedBox.shrink(),
          ),
      ],
    );
  }
}
