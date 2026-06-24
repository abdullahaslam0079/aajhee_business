import 'package:flutter_test/flutter_test.dart';
import 'package:goluto_business/src/app.dart';
import 'package:goluto_business/src/shared/wrappers/localization_wrapper.dart';
import 'package:goluto_business/src/shared/wrappers/state_wrapper.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const LocalizationWrapper(
        child: StateWrapper(
          child: App(),
        ),
      ),
    );

    expect(find.text('Business Login'), findsOneWidget);
  });
}
