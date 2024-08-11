import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';

import 'package:airhockey/app_state.dart';
import 'package:airhockey/app_reducer.dart';
import 'package:airhockey/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create the store with an initial state
    final store = Store<AppState>(
      appReducer,
      initialState: AppState.initial(),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(store: store));

    // Debugging: Immediately check for the "0" text without tapping any button.
    print('Testing initial state...');
    expect(find.text('0'),
        findsOneWidget); // This should pass if the initial state is correct

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
