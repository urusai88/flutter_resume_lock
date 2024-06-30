import 'package:flutter/widgets.dart';

import '../resume_lock.dart';
import 'action.dart';

abstract class ResumeLockDelegate {
  const ResumeLockDelegate();

  Future<ResumeLockAction?> onResumed(BuildContext context);

  void onPaused() {}

  void onLocked() {}

  void onUnlocked() {}

  @protected
  ResumeLockAction doLock() => const ResumeLockAction.lock();

  @mustCallSuper
  void didReplace(covariant ResumeLockDelegate oldDelegate) {
    assert(() {
      debugPrint('$runtimeType replaced');
      return true;
    }());
  }

  @mustCallSuper
  void dispose() {
    assert(() {
      debugPrint('$runtimeType disposed');
      return true;
    }());
  }
}
