import 'package:flutter/material.dart';
import 'package:flutter_resume_lock/flutter_resume_lock.dart';
import 'package:flutter_test/flutter_test.dart';

import '_extensions.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  var _duration = const Duration(seconds: 1);

  void setDuration(Duration value) {
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
      home: const MyHome(),
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
  Widget buildLocker(BuildContext context) => const MyLocker();

  @override
  Route<dynamic> buildRoute(Widget child) =>
      MaterialPageRoute(builder: (context) => child);
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('HOME')),
    );
  }
}

class MyLocker extends StatelessWidget {
  const MyLocker({super.key});

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
        ],
      ),
    );
  }
}

void main() {
  Future<int> updateState(WidgetTester tester, AppLifecycleState state) async {
    tester.binding.handleAppLifecycleStateChanged(state);
    return tester.pumpAndSettle();
  }

  testWidgets('app just runs', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyHome), findsOneWidget);
    expect(find.byType(MyLocker), findsNothing);
  });

  testWidgets('app runs not enough time', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyHome), findsOneWidget);
    expect(find.byType(MyLocker), findsNothing);
    await tester.wait();
    expect(find.byType(MyHome), findsOneWidget);
    expect(find.byType(MyLocker), findsNothing);
  });

  testWidgets('app locked', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.wait(const Duration(seconds: 2));
    expect(find.byType(MyHome), findsNothing);
    expect(find.byType(MyLocker), findsOneWidget);
  });

  testWidgets('app locked and unlocked', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.wait(const Duration(seconds: 2));
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHome), findsOneWidget);
    expect(find.byType(MyLocker), findsNothing);
  });

  testWidgets('app change duration', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.wait(const Duration(seconds: 2));
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHome), findsOneWidget);
    expect(find.byType(MyLocker), findsNothing);
    tester
        .state<_MyAppState>(find.byType(MyApp))
        .setDuration(const Duration(seconds: 10));
    await tester.wait(const Duration(seconds: 2));
    expect(find.byType(MyHome), findsOneWidget);
    expect(find.byType(MyLocker), findsNothing);
    await tester.wait(const Duration(seconds: 20));
    expect(find.byType(MyHome), findsNothing);
    expect(find.byType(MyLocker), findsOneWidget);
  });
}
