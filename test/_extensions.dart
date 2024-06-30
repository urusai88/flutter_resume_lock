import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterX on WidgetTester {
  Future<void> pause() {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    return pumpAndSettle();
  }

  Future<void> resume() {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    return pumpAndSettle();
  }

  Future<void> wait([Duration duration = const Duration(milliseconds: 100)]) =>
      pause().then((_) => pumpAndSettle(duration)).then((_) => resume());
}
