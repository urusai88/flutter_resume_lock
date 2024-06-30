import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';

import '../action.dart';
import '../delegate.dart';

class TimeoutResumeLockDelegate extends ResumeLockDelegate {
  TimeoutResumeLockDelegate({required this.lockTimeout});

  final Duration lockTimeout;

  DateTime? _pauseTime;

  @protected
  bool shouldLock() {
    if (_pauseTime == null) {
      return false;
    }
    final shouldLockAt = _pauseTime!.add(lockTimeout);
    final should = clock.now().isAfter(shouldLockAt);

    if (should) {
      return true;
    }
    _pauseTime = null;
    return false;
  }

  @override
  Future<ResumeLockAction?> onResumed(BuildContext context) =>
      Future.value(shouldLock() ? doLock() : null);

  @override
  @mustCallSuper
  void onPaused() => _pauseTime = clock.now();

  @override
  @mustCallSuper
  void onUnlocked() => _pauseTime = null;

  @override
  void didReplace(covariant TimeoutResumeLockDelegate oldDelegate) {
    super.didReplace(oldDelegate);
    _pauseTime = oldDelegate._pauseTime;
  }

  @override
  void dispose() {
    super.dispose();
    _pauseTime = null;
  }
}
