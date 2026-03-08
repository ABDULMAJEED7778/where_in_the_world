import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:where_in_the_world/providers/game_provider.dart';

/// Wraps [child] in a MaterialApp + ChangeNotifierProvider<GameProvider>
/// so that `context.watch/read<GameProvider>()` works in widget tests.
///
/// Returns the provider instance so tests can manipulate state.
GameProvider pumpWithProvider(WidgetTester tester, {required Widget child}) {
  final provider = GameProvider();
  // We don't await here — the caller does `await tester.pumpWidget(...)`.
  return provider;
}

/// Builds a full widget tree with MaterialApp + Provider for the given child.
Widget buildTestableWidget(Widget child, GameProvider provider) {
  return ChangeNotifierProvider<GameProvider>.value(
    value: provider,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

/// Builds a testable dialog (shows it inside a MaterialApp + Provider).
Widget buildTestableDialog(Widget dialog, GameProvider provider) {
  return ChangeNotifierProvider<GameProvider>.value(
    value: provider,
    child: MaterialApp(
      home: Builder(
        builder: (context) {
          // Auto-show the dialog on first build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (_) => ChangeNotifierProvider<GameProvider>.value(
                value: provider,
                child: dialog,
              ),
            );
          });
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    ),
  );
}
