import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'action.dart';
import 'delegate.dart';

export 'action.dart';
export 'delegate.dart';

@optionalTypeArgs
typedef ResumeLockRouteBuilder<T> = Route<T> Function(Widget child);
typedef ResumeLockLockerBuilder = Widget Function(BuildContext context);

@optionalTypeArgs
abstract class ResumeLock<T> extends StatefulWidget {
  const ResumeLock({
    super.key,
    required this.delegate,
    required this.navigatorKey,
    required this.child,
  });

  const factory ResumeLock.builder({
    Key? key,
    required ResumeLockDelegate delegate,
    required GlobalKey<NavigatorState> navigatorKey,
    required ResumeLockLockerBuilder lockerBuilder,
    required ResumeLockRouteBuilder<T> routeBuilder,
    required Widget child,
  }) = _ResumeLockBuilder;

  final ResumeLockDelegate delegate;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ResumeLockState createState() => ResumeLockState();

  Widget buildLocker(BuildContext context);

  Route<T> buildRoute(Widget child);

  static ResumeLockState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<ResumeLockState>();

  static ResumeLockState of(BuildContext context) => maybeOf(context)!;
}

class ResumeLockState extends State<ResumeLock> with WidgetsBindingObserver {
  var _locked = false;

  AppLifecycleState? _previousState;

  NavigatorState? get navigator => widget.navigatorKey.currentState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant ResumeLock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      if (widget.delegate.runtimeType == oldWidget.delegate.runtimeType) {
        widget.delegate.didReplace(oldWidget.delegate);
      }
      oldWidget.delegate.dispose();
    }
  }

  @override
  void dispose() {
    widget.delegate.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_previousState == state) {
      return;
    }
    _previousState = state;
    if (state == AppLifecycleState.paused && !_locked) {
      widget.delegate.onPaused();
    } else if (state == AppLifecycleState.resumed) {
      if (!context.mounted) {
        return;
      }
      if (await widget.delegate.onResumed(context) is ResumeLockActionLock) {
        await lock();
      }
    }
  }

  Widget buildChild(Widget child) => PopScope(canPop: false, child: child);

  Future<void>? lock() {
    assert(navigator != null);
    if (_locked || navigator == null) {
      return null;
    }
    _locked = true;
    widget.delegate.onLocked();
    return navigator!.push(
      widget.buildRoute(buildChild(widget.buildLocker(context))),
    );
  }

  void unlock() {
    assert(navigator != null);
    if (!_locked || navigator == null) {
      return;
    }
    _locked = false;
    navigator!.pop();
    widget.delegate.onUnlocked();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

@optionalTypeArgs
class _ResumeLockBuilder<T> extends ResumeLock<T> {
  const _ResumeLockBuilder({
    super.key,
    required super.delegate,
    required super.navigatorKey,
    required this.lockerBuilder,
    required this.routeBuilder,
    required super.child,
  });

  final ResumeLockLockerBuilder lockerBuilder;
  final ResumeLockRouteBuilder<T> routeBuilder;

  @override
  Widget buildLocker(BuildContext context) => lockerBuilder(context);

  @override
  Route<T> buildRoute(Widget child) => routeBuilder(child);
}
