import 'package:flutter/material.dart';
import 'package:resume_lock/resume_lock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState _of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  var _duration = const Duration(seconds: 1);

  Duration get duration => _duration;

  set duration(Duration value) {
    if (_duration != value) {
      setState(() => _duration = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      builder: (context, child) => MyResumeLock(
        delegate: TimeoutResumeLockDelegate(lockTimeout: _duration),
        navigatorKey: _navigatorKey,
        child: child!,
      ),
      home: const Scaffold(
        body: Center(child: Text('HOME')),
      ),
    );
  }
}

class MyResumeLock extends ResumeLock {
  const MyResumeLock({
    super.key,
    required super.delegate,
    required super.navigatorKey,
    required super.child,
  });

  @override
  Widget buildLocker(BuildContext context) => const MyLockerView();

  @override
  Route<dynamic> buildRoute(Widget child) =>
      MaterialPageRoute(builder: (context) => child);
}

class MyLockerView extends StatelessWidget {
  const MyLockerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Text('App is locked!')),
          ElevatedButton(
            onPressed: () => ResumeLock.of(context).unlock(),
            child: const Text('Unlock'),
          ),
          ElevatedButton(
            onPressed: () =>
                MyApp._of(context).duration = const Duration(seconds: 1),
            child: const Text('SET DURATION 1'),
          ),
          ElevatedButton(
            onPressed: () =>
                MyApp._of(context).duration = const Duration(seconds: 5),
            child: const Text('SET DURATION 5'),
          ),
          ElevatedButton(
            onPressed: () =>
                MyApp._of(context).duration = const Duration(seconds: 10),
            child: const Text('SET DURATION 10'),
          ),
        ],
      ),
    );
  }
}
