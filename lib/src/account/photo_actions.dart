import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/repositories.dart';
import 'photo_picker.dart';
import '../ui/snack.dart';

/// Bottom sheet to change or remove the profile photo.
Future<void> showPhotoActions(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final uid = ref.read(currentUidProvider);
  if (uid == null) return;
  final hasPhoto = ref.read(profileProvider).value?.photoBase64 != null;

  final action = await showFSheet<String>(
    context: context,
    side: FLayout.btt,
    mainAxisMaxRatio: null,
    builder: (context) {
      final theme = context.theme;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background,
          border: Border(top: BorderSide(color: theme.colors.border)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FTileGroup(
              children: [
                FTile(
                  prefix: const Icon(FLucideIcons.images),
                  title: Text(l10n.changePhoto),
                  onPress: () => Navigator.pop(context, 'change'),
                ),
                if (hasPhoto)
                  FTile(
                    variant: FItemVariant.destructive,
                    prefix: const Icon(FLucideIcons.trash2),
                    title: Text(l10n.removePhoto),
                    onPress: () => Navigator.pop(context, 'remove'),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
  if (action == null || !context.mounted) return;

  final repo = ref.read(profileRepositoryProvider);
  try {
    if (action == 'remove') {
      await repo.setPhoto(uid, null);
    } else {
      final photo = await pickProfilePhoto();
      if (photo != null) await repo.setPhoto(uid, photo);
    }
  } catch (_) {
    showSnack(l10n.photoError);
  }
}
