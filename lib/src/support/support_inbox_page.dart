import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../data/models.dart';
import '../ui/async_view.dart';
import '../ui/segmented.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import 'support_repository.dart';
import 'support_widgets.dart';
import '../ui/tokens.dart';

enum _Filter { open, answered, closed, all }

/// For the team: all support requests, newest activity first.
class SupportInboxPage extends ConsumerStatefulWidget {
  const SupportInboxPage({super.key});

  @override
  ConsumerState<SupportInboxPage> createState() => _SupportInboxPageState();
}

class _SupportInboxPageState extends ConsumerState<SupportInboxPage> {
  _Filter _filter = _Filter.open;

  bool _matches(SupportTicket t, _Filter f) => switch (f) {
    _Filter.open => t.status == SupportStatus.open,
    _Filter.answered => t.status == SupportStatus.answered,
    _Filter.closed => t.status == SupportStatus.closed,
    _Filter.all => true,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final role = ref.watch(staffRoleProvider);
    final isStaff = ref.watch(isStaffProvider);
    final tickets = ref.watch(staffTicketsProvider);

    final Widget body;
    if (role.isLoading && !role.hasValue) {
      body = const SkeletonTicketList(key: ValueKey('loading'));
    } else if (!isStaff) {
      body = Center(
        key: const ValueKey('denied'),
        child: EmptyState(
          icon: FLucideIcons.shieldOff,
          title: l10n.supportNoAccess,
          message: l10n.supportNoAccessInfo,
        ),
      );
    } else {
      final all = [...?tickets.value]
        ..sort(
          (a, b) => (b.lastMessageAt ?? b.createdAt ?? DateTime(0)).compareTo(
            a.lastMessageAt ?? a.createdAt ?? DateTime(0),
          ),
        );
      final labels = {
        _Filter.open: l10n.supportFilterOpen,
        _Filter.answered: l10n.supportFilterAnswered,
        _Filter.closed: l10n.supportFilterClosed,
        _Filter.all: l10n.supportFilterAll,
      };
      int count(_Filter f) => all.where((t) => _matches(t, f)).length;
      final shown = all.where((t) => _matches(t, _filter)).toList();

      body = Column(
        key: const ValueKey('inbox'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.xl,
              Space.md,
              Space.xl,
              Space.md,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Segmented<_Filter>(
                  values: _Filter.values,
                  selected: _filter,
                  label: (f) => tickets.hasValue
                      ? '${labels[f]!} (${count(f)})'
                      : labels[f]!,
                  scrollable: !isWideLayout(context),
                  onChanged: (f) => setState(() => _filter = f),
                ),
              ),
            ),
          ),
          Expanded(
            child: AsyncView<List<SupportTicket>>(
              value: tickets,
              onRetry: () => ref.invalidate(staffTicketsProvider),
              loading: const SkeletonTicketList(),
              data: (_) => AnimatedSwitcher(
                duration: Motion.normal,
                child: shown.isEmpty
                    ? Align(
                        key: ValueKey('empty-$_filter'),
                        alignment: Alignment.topCenter,
                        child: EmptyState(
                          icon: FLucideIcons.inbox,
                          title: l10n.supportInboxEmpty,
                        ),
                      )
                    : ListView.separated(
                        key: ValueKey('list-$_filter'),
                        padding: Insets.pageList,
                        itemCount: shown.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: Space.md),
                        itemBuilder: (context, i) {
                          final t = shown[i];
                          return SupportTicketTile(
                            key: ValueKey(t.id),
                            ticket: t,
                            unread: t.unreadForStaff,
                            staffView: true,
                            onTap: () =>
                                context.push('/support/ticket/${t.id}'),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      );
    }

    return SiteScaffold(
      title: l10n.supportInbox,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: AnimatedSwitcher(duration: Motion.normal, child: body),
    );
  }
}
