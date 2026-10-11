import 'package:firebase_core/firebase_core.dart';
import 'package:flat/src/data/live_snapshots.dart';
import 'package:flutter_test/flutter_test.dart';

FirebaseException _error(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  test('a refused listener right after signing in is started again', () async {
    {
      var opened = 0;
      final values = <int>[];
      final errors = <Object>[];
      retryTransient<int>(() {
        opened++;
        return opened == 1
            ? Stream.error(_error('permission-denied'))
            : Stream.value(42);
      }).listen(values.add, onError: errors.add);
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(opened, 2);
      expect(values, [42]);
      expect(errors, isEmpty);
    }
  });

  test('a lasting error is passed on after a few tries', () async {
    {
      var opened = 0;
      final errors = <Object>[];
      retryTransient<int>(() {
        opened++;
        return Stream.error(_error('permission-denied'));
      }).listen((_) {}, onError: errors.add);
      await Future<void>.delayed(const Duration(milliseconds: 3800));
      expect(opened, 4);
      expect(errors, hasLength(1));
    }
  });

  test('other errors are passed on at once', () async {
    {
      var opened = 0;
      final errors = <Object>[];
      retryTransient<int>(() {
        opened++;
        return Stream.error(_error('invalid-argument'));
      }).listen((_) {}, onError: errors.add);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(opened, 1);
      expect(errors, hasLength(1));
    }
  });
}
