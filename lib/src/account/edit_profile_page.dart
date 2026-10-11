import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/repositories.dart';
import 'avatar.dart';
import 'photo_actions.dart';
import '../ui/snack.dart';
import '../ui/nav.dart';
import '../ui/site_scaffold.dart';

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
      showSnack(l10n.saved);
      if (mounted) popOrGo(context, '/settings');
    } on UsernameTakenException {
      if (mounted) {
        setState(() => _usernameTaken = true);
        _formKey.currentState!.validate();
      }
    } catch (_) {
      showSnack(l10n.saveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider).value;
    final user = ref.watch(authStateProvider).value;

    return SiteScaffold(
      title: l10n.editProfile,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Align(
          // Website layout: under the page title, not centered.
          alignment: isWideLayout(context)
              ? Alignment.topLeft
              : Alignment.topCenter,
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
                      icon: const Icon(FLucideIcons.camera),
                      label: Text(l10n.changePhoto),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: l10n.nameLabel,
                      prefixIcon: const Icon(FLucideIcons.user),
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
                      prefixIcon: const Icon(FLucideIcons.atSign),
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
                      prefixIcon: const Icon(FLucideIcons.mail),
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
