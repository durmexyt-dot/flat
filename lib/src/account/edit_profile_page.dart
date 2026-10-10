import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/repositories.dart';
import 'avatar.dart';
import 'photo_actions.dart';
import '../ui/snack.dart';

final usernamePattern = RegExp(r'^[a-z0-9_.]{3,20}$');

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  bool _saving = false;
  bool _usernameTaken = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    final user = ref.read(authStateProvider).value;
    _name = TextEditingController(
      text: profile?.displayName ?? user?.displayName ?? '',
    );
    _username = TextEditingController(text: profile?.username ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _usernameTaken = false);
    if (_saving || !_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final profile = ref.read(profileProvider).value;
    final repo = ref.read(profileRepositoryProvider);
    setState(() => _saving = true);
    try {
      final name = _name.text.trim();
      if (name != profile?.displayName) {
        await repo.updateDisplayName(uid, name);
        await ref.read(authRepositoryProvider).updateDisplayName(name);
      }
      final username = _username.text.trim().toLowerCase();
      if (username.isNotEmpty && username != profile?.username) {
        await repo.setUsername(uid, username);
      }
      showSnack(messenger, l10n.saved);
      if (mounted) context.pop();
    } on UsernameTakenException {
      if (mounted) {
        setState(() => _usernameTaken = true);
        _formKey.currentState!.validate();
      }
    } catch (_) {
      showSnack(messenger, l10n.saveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider).value;
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: UserAvatar(
                      size: 120,
                      photoBase64: profile?.photoBase64,
                      name: _name.text,
                    ),
                  ),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => showPhotoActions(context, ref),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(l10n.changePhoto),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: l10n.nameLabel,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.nameRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _username,
                    decoration: InputDecoration(
                      labelText: l10n.usernameLabel,
                      prefixIcon: const Icon(Icons.alternate_email),
                      helperText: l10n.usernameHint,
                      helperMaxLines: 2,
                    ),
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    validator: (v) {
                      final value = (v ?? '').trim().toLowerCase();
                      if (_usernameTaken) return l10n.usernameTaken;
                      if (value.isNotEmpty &&
                          !usernamePattern.hasMatch(value)) {
                        return l10n.usernameInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: user?.email ?? '',
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SubmitButton(
                    label: l10n.save,
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
