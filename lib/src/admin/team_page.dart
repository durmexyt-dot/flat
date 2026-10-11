import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../ui/app_dialog.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/site_scaffold.dart';
import '../ui/snack.dart';
import 'admin_page.dart';
import 'admin_repository.dart';

/// Admins and support accounts; admins add and remove support accounts.
class TeamPage extends ConsumerWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.adminTeamTitle,
      accountNav: true,
      body: AdminGate(
        builder: (context) {
          final team = ref.watch(teamProvider);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              SettingsSectionTitle(l10n.adminTeamMembers),
              AsyncView<List<StaffMember>>(
                value: team,
                loading: const AdminSkeleton(count: 2),
                onRetry: () => ref.invalidate(teamProvider),
                data: (members) => _TeamList(members: members),
              ),
              const SizedBox(height: 12),
              AdminNotice(text: l10n.adminAdminsInfo),
              SettingsSectionTitle(l10n.adminAddSupport),
              _AddSupport(team: team.value ?? const []),
            ],
          );
        },
      ),
    );
  }
}

String _roleName(AppLocalizations l10n, StaffRole role) => switch (role) {
  StaffRole.admin => l10n.adminRoleAdmin,
  StaffRole.support => l10n.adminRoleSupport,
};

String _initials(String name, String email) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isNotEmpty) {
    return parts.take(2).map((p) => p.characters.first.toUpperCase()).join();
  }
  return email.isEmpty ? '?' : email.characters.first.toUpperCase();
}

class _TeamList extends ConsumerWidget {
  const _TeamList({required this.members});

  final List<StaffMember> members;

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    StaffMember member,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = member.name.isNotEmpty
        ? member.name
        : member.email.isNotEmpty
        ? member.email
        : l10n.adminNoName;
    final ok = await showAppDialog<bool>(
      context: context,
      title: l10n.adminRemoveSupportTitle,
      body: Text(l10n.adminRemoveSupportBody(name)),
      actions: (ctx) => [
        FButton(
          variant: .outline,
          onPress: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FButton(
          variant: .destructive,
          onPress: () => Navigator.pop(ctx, true),
          child: Text(l10n.adminRemove),
        ),
      ],
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).revokeSupport(member.uid);
      showSnack(l10n.adminSupportRemoved);
    } catch (_) {
      showSnack(l10n.saveError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(currentUidProvider);
    return SettingsGroup(
      children: [
        for (final m in members)
          FTile(
            key: ValueKey('member-${m.uid}'),
            prefix: FAvatar.raw(
              size: 40,
              child: Text(_initials(m.name, m.email)),
            ),
            title: Text(
              [
                if (m.name.isNotEmpty) m.name else l10n.adminNoName,
                if (m.uid == me) '(${l10n.adminYou})',
              ].join(' '),
            ),
            subtitle: Text(
              [
                if (m.email.isNotEmpty) m.email,
                if (m.grantedAt != null)
                  l10n.adminGrantedAt(formatDate(context, m.grantedAt!)),
              ].join(' · '),
            ),
            details: _RoleBadge(role: m.role),
            suffix: m.role == StaffRole.support && m.uid != me
                ? FButton.icon(
                    variant: .ghost,
                    semanticsLabel: l10n.adminRemoveSupport,
                    onPress: () => _remove(context, ref, m),
                    child: const Icon(FLucideIcons.userX),
                  )
                : null,
          ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final StaffRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FBadge(
      variant: role == StaffRole.admin ? .primary : .secondary,
      child: Text(_roleName(l10n, role)),
    );
  }
}

/// Finds a user by exact email or username and makes them support.
class _AddSupport extends ConsumerStatefulWidget {
  const _AddSupport({required this.team});

  final List<StaffMember> team;

  @override
  ConsumerState<_AddSupport> createState() => _AddSupportState();
}

class _AddSupportState extends ConsumerState<_AddSupport> {
  final _query = TextEditingController();
  bool _searching = false;
  bool _granting = false;

  /// Null before the first search.
  ({UserLookup? user})? _result;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _query.text.trim();
    if (q.isEmpty || _searching) return;
    FocusScope.of(context).unfocus();
    setState(() => _searching = true);
    try {
      final user = await ref.read(adminRepositoryProvider).findUser(q);
      if (mounted) setState(() => _result = (user: user));
    } catch (_) {
      if (mounted) showSnack(AppLocalizations.of(context).loadError);
    }
    if (mounted) setState(() => _searching = false);
  }

  Future<void> _grant(UserLookup user) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null || _granting) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _granting = true);
    try {
      await ref.read(adminRepositoryProvider).grantSupport(user, byUid: uid);
      showSnack(l10n.adminSupportAdded);
      if (mounted) {
        setState(() => _result = null);
        _query.clear();
      }
    } catch (_) {
      showSnack(l10n.saveError);
    }
    if (mounted) setState(() => _granting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final result = _result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.adminAddSupportInfo,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        FTextFormField(
          key: const ValueKey('find-user'),
          control: FTextFieldControl.managed(
            controller: _query,
            onChange: (_) {
              if (_result != null) setState(() => _result = null);
            },
          ),
          label: Text(l10n.adminFindUserLabel),
          prefixBuilder: (context, style, variants) =>
              fieldIcon(FLucideIcons.search),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.search,
          autocorrect: false,
          enableSuggestions: false,
          onSubmit: (_) => _search(),
        ),
        const SizedBox(height: 12),
        FButton(
          variant: .outline,
          onPress: _searching ? null : _search,
          prefix: _searching
              ? FCircularProgress.loader()
              : const Icon(FLucideIcons.search),
          child: Text(l10n.adminFindUser),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: result == null
                ? const SizedBox(key: ValueKey('none'), width: double.infinity)
                : Padding(
                    key: ValueKey(result.user?.uid ?? 'not-found'),
                    padding: const EdgeInsets.only(top: 16),
                    child: result.user == null
                        ? _NotFound()
                        : _UserCard(
                            user: result.user!,
                            team: widget.team,
                            granting: _granting,
                            onGrant: () => _grant(result.user!),
                          ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(FLucideIcons.userX, color: theme.colors.mutedForeground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adminUserNotFound,
                    style: theme.typography.body.md.copyWith(
                      color: theme.colors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.adminUserNotFoundInfo,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  const _UserCard({
    required this.user,
    required this.team,
    required this.granting,
    required this.onGrant,
  });

  final UserLookup user;
  final List<StaffMember> team;
  final bool granting;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final me = ref.watch(currentUidProvider);
    final member = team.where((m) => m.uid == user.uid).firstOrNull;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );

    final Widget action;
    if (user.uid == me) {
      action = Text(l10n.adminThatsYou, style: muted);
    } else if (member != null) {
      action = Row(
        children: [
          Icon(
            FLucideIcons.shieldCheck,
            size: 18,
            color: theme.colors.foreground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.adminAlreadyInTeam(_roleName(l10n, member.role)),
              style: muted.copyWith(color: theme.colors.foreground),
            ),
          ),
        ],
      );
    } else {
      action = FButton(
        onPress: granting ? null : onGrant,
        prefix: granting
            ? FCircularProgress.loader()
            : const Icon(FLucideIcons.userPlus),
        child: Text(l10n.adminMakeSupport),
      );
    }

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FAvatar.raw(
                  size: 48,
                  child: Text(_initials(user.name, user.email)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isNotEmpty ? user.name : l10n.adminNoName,
                        style: theme.typography.body.md.copyWith(
                          color: theme.colors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (user.email.isNotEmpty)
                        Text(
                          user.email,
                          style: muted,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (user.username.isNotEmpty)
                        Text('@${user.username}', style: muted),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            action,
          ],
        ),
      ),
    );
  }
}
