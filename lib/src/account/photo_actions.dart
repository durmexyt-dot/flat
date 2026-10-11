import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final action = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.changePhoto),
            onTap: () => Navigator.pop(context, 'change'),
          ),
          if (hasPhoto)
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(l10n.removePhoto),
              onTap: () => Navigator.pop(context, 'remove'),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
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
