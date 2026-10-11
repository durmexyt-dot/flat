import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A small muted heading above a group or a section.
class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle(this.title, {super.key, this.padding});

  final String title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(2, 24, 2, 8),
      child: Text(
        title,
        style: theme.typography.body.sm.copyWith(
          color: theme.colors.mutedForeground,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Tiles grouped in one bordered Forui tile group.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<FTileMixin> children;

  @override
  Widget build(BuildContext context) => FTileGroup(children: children);
}

/// A settings row that opens a sub page.
class SettingsLinkTile extends StatelessWidget with FTileMixin {
  const SettingsLinkTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FTile(
    prefix: Icon(icon),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    details: trailing,
    suffix: const Icon(FLucideIcons.chevronRight),
    onPress: onTap,
  );
}
