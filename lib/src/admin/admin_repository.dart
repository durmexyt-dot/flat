import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/repositories.dart';
import '../data/live_snapshots.dart';

/// Roles, fees and finding users: the admin side.
///
/// Admins are made in the Firebase console (a roles/{uid} document with
/// role "admin"); the security rules don't let anybody write that. Admins
/// can make and remove support accounts.
abstract class AdminRepository {
  /// The user's team role, or null for normal users.
  Stream<StaffRole?> watchRole(String uid);

  /// The fees for new listings.
  Stream<FeeConfig> watchFees();
  Future<void> setFees(FeeConfig fees, {required String byUid});

  /// Admins and support accounts.
  Stream<List<StaffMember>> watchTeam();

  /// Finds one user by exact email address or username, so admins never
  /// load the whole user list.
  Future<UserLookup?> findUser(String emailOrUsername);
  Future<void> grantSupport(UserLookup user, {required String byUid});
  Future<void> revokeSupport(String uid);
}

class FirestoreAdminRepository implements AdminRepository {
  FirestoreAdminRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _roles =>
      _db.collection('roles');
  DocumentReference<Map<String, dynamic>> get _fees =>
      _db.collection('config').doc('fees');

  @override
  Stream<StaffRole?> watchRole(String uid) => _roles
      .doc(uid)
      .liveSnapshots()
      .map(
        (d) =>
            d.exists ? StaffMember.fromMap(uid, firestoreData(d)).role : null,
      )
      // Without access (e.g. rules not yet published) nobody is staff.
      .transform(
        StreamTransformer.fromHandlers(
          handleError: (_, _, sink) => sink.add(null),
        ),
      );

  @override
  Stream<FeeConfig> watchFees() => _fees.liveSnapshots().map(
    (d) => FeeConfig.fromMap(d.exists ? firestoreData(d) : null),
  );

  @override
  Future<void> setFees(FeeConfig fees, {required String byUid}) => _fees.set({
    ...fees.toMap(),
    'updatedBy': byUid,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  @override
  Stream<List<StaffMember>> watchTeam() =>
      _roles.liveSnapshots().asyncMap((q) async {
        final members = [
          for (final d in q.docs) StaffMember.fromMap(d.id, firestoreData(d)),
        ];
        // Name and email from the profiles, so they are current (and known for
        // admins added by hand in the console).
        final current = await Future.wait(members.map(_withProfile));
        return current..sort((a, b) {
          final byRole = a.role.index.compareTo(b.role.index);
          return byRole != 0 ? byRole : a.name.compareTo(b.name);
        });
      });

  Future<StaffMember> _withProfile(StaffMember m) async {
    try {
      final d = await _db.collection('users').doc(m.uid).get();
      if (!d.exists) return m;
      final p = UserProfile.fromMap(m.uid, firestoreData(d));
      return StaffMember(
        uid: m.uid,
        role: m.role,
        name: (p.displayName ?? '').isNotEmpty ? p.displayName! : m.name,
        email: (p.email ?? '').isNotEmpty ? p.email! : m.email,
        grantedAt: m.grantedAt,
      );
    } catch (_) {
      return m;
    }
  }

  @override
  Future<UserLookup?> findUser(String emailOrUsername) async {
    final q = emailOrUsername.trim();
    if (q.isEmpty) return null;
    DocumentSnapshot<Map<String, dynamic>>? user;
    if (q.contains('@')) {
      final found = await _db
          .collection('users')
          .where('email', isEqualTo: q)
          .limit(1)
          .get();
      // Emails are stored as typed at sign-up; try lower case too.
      final docs = found.docs.isNotEmpty
          ? found.docs
          : (await _db
                    .collection('users')
                    .where('email', isEqualTo: q.toLowerCase())
                    .limit(1)
                    .get())
                .docs;
      user = docs.firstOrNull;
    } else {
      final name = q.replaceFirst('@', '').toLowerCase();
      final reservation = await _db.collection('usernames').doc(name).get();
      final uid = reservation.data()?['uid'] as String?;
      if (uid != null) user = await _db.collection('users').doc(uid).get();
    }
    if (user == null || !user.exists) return null;
    final p = UserProfile.fromMap(user.id, firestoreData(user));
    return UserLookup(
      uid: p.uid,
      name: p.displayName ?? '',
      email: p.email ?? '',
      username: p.username ?? '',
    );
  }

  @override
  Future<void> grantSupport(UserLookup user, {required String byUid}) =>
      _roles.doc(user.uid).set({
        'role': StaffRole.support.name,
        'name': user.name,
        'email': user.email,
        'grantedBy': byUid,
        'grantedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> revokeSupport(String uid) => _roles.doc(uid).delete();
}

/// Roles and fees held in memory, for tests.
class InMemoryAdminRepository implements AdminRepository {
  InMemoryAdminRepository({
    Map<String, StaffRole> roles = const {},
    this.fees = const FeeConfig(),
    List<UserLookup> users = const [],
  }) : _team = {
         for (final e in roles.entries)
           e.key: StaffMember(uid: e.key, role: e.value),
       },
       _users = [...users];

  final Map<String, StaffMember> _team;
  final List<UserLookup> _users;
  FeeConfig fees;
  final _changes = StreamController<void>.broadcast();

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<StaffRole?> watchRole(String uid) => _watch(() => _team[uid]?.role);

  @override
  Stream<FeeConfig> watchFees() => _watch(() => fees);

  @override
  Future<void> setFees(FeeConfig fees, {required String byUid}) async {
    this.fees = fees;
    _changes.add(null);
  }

  @override
  Stream<List<StaffMember>> watchTeam() => _watch(() => [..._team.values]);

  @override
  Future<UserLookup?> findUser(String emailOrUsername) async {
    final q = emailOrUsername.trim().toLowerCase().replaceFirst(
      RegExp(r'^@'),
      '',
    );
    return _users
        .where((u) => u.email.toLowerCase() == q || u.username == q)
        .firstOrNull;
  }

  @override
  Future<void> grantSupport(UserLookup user, {required String byUid}) async {
    _team[user.uid] = StaffMember(
      uid: user.uid,
      role: StaffRole.support,
      name: user.name,
      email: user.email,
      grantedAt: DateTime.now(),
    );
    _changes.add(null);
  }

  @override
  Future<void> revokeSupport(String uid) async {
    if (_team[uid]?.role == StaffRole.support) _team.remove(uid);
    _changes.add(null);
  }
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => FirestoreAdminRepository(ref.watch(firestoreProvider)),
);

/// The signed-in user's team role, or null.
final staffRoleProvider = StreamProvider<StaffRole?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(adminRepositoryProvider).watchRole(uid);
});

final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(staffRoleProvider).value == StaffRole.admin,
);

/// Admins and support accounts answer support requests.
final isStaffProvider = Provider<bool>(
  (ref) => ref.watch(staffRoleProvider).value != null,
);

/// The fees new listings get.
final feeConfigProvider = StreamProvider<FeeConfig>(
  (ref) => ref.watch(adminRepositoryProvider).watchFees(),
);

/// Read anew each time the team page opens, so profile changes show.
final teamProvider = StreamProvider.autoDispose<List<StaffMember>>(
  (ref) => ref.watch(adminRepositoryProvider).watchTeam(),
);
