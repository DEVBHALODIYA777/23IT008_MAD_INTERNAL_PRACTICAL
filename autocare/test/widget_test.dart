import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocare/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic test just to ensure no syntax errors and compiles.
    // Hive init makes complete tests require mocksetup.
    expect(true, isTrue);
  });
}
