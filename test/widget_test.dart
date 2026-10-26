import 'package:flutter_test/flutter_test.dart';
import 'package:test_1/core/constants/app_strings.dart';
import 'package:test_1/main.dart';

void main() {
  testWidgets('Smoke test: PoseDetectionApp carga SplashScreen correctamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PoseDetectionApp());

    expect(find.text(AppStrings.splashTitle), findsOneWidget);
    expect(find.text(AppStrings.startNow), findsOneWidget);
  });
}
