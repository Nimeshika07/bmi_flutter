import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bmi/main.dart';

void main() {
  testWidgets('BMI calculator input, result, and clear on Calculate Again test', (WidgetTester tester) async {
    // Build the BMI App and trigger a frame.
    await tester.pumpWidget(const BmiApp());

    // Verify header and fields exist
    expect(find.text('BMI Calculator'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('Height'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('Calculate BMI'), findsOneWidget);

    // Select Male gender
    await tester.tap(find.text('Male'));
    await tester.pumpAndSettle();

    // Enter age, height, and weight
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(3));

    await tester.enterText(textFields.at(0), '25');
    await tester.enterText(textFields.at(1), '175');
    await tester.enterText(textFields.at(2), '70');
    await tester.pumpAndSettle();

    // Scroll calculate button into view and tap it
    final calculateButton = find.text('Calculate BMI');
    await tester.ensureVisible(calculateButton);
    await tester.pumpAndSettle();

    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    // Verify result screen is displayed with BMI (70 / 1.75^2 = 22.86 -> 22.9)
    expect(find.text('BMI Result'), findsOneWidget);
    expect(find.text('22.9'), findsOneWidget);
    expect(find.text('Normal Weight'), findsWidgets);
    expect(find.text('Calculate Again'), findsOneWidget);

    // Scroll Calculate Again button into view and tap it to return to input screen
    final calculateAgainButton = find.text('Calculate Again');
    await tester.ensureVisible(calculateAgainButton);
    await tester.pumpAndSettle();

    await tester.tap(calculateAgainButton);
    await tester.pumpAndSettle();

    // Verify returning to input screen and fields are cleared
    expect(find.text('Calculate BMI'), findsOneWidget);
    expect(find.text('25'), findsNothing);
    expect(find.text('175'), findsNothing);
    expect(find.text('70'), findsNothing);
  });

  testWidgets('BMI calculator input validation constraints test', (WidgetTester tester) async {
    await tester.pumpWidget(const BmiApp());

    final textFields = find.byType(TextField);
    final calculateButton = find.text('Calculate BMI');

    // Test empty validation
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter all details.'), findsOneWidget);

    // Test invalid age (> 120)
    await tester.tap(find.text('Female'));
    await tester.enterText(textFields.at(0), '150');
    await tester.enterText(textFields.at(1), '160');
    await tester.enterText(textFields.at(2), '55');
    await tester.pumpAndSettle();

    await tester.tap(calculateButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid age between 1 and 120 years.'), findsOneWidget);

    // Test invalid height (< 50 cm)
    await tester.enterText(textFields.at(0), '30');
    await tester.enterText(textFields.at(1), '40');
    await tester.pumpAndSettle();

    await tester.tap(calculateButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid height between 50 and 300 cm.'), findsOneWidget);

    // Test invalid weight (< 10 kg)
    await tester.enterText(textFields.at(1), '160');
    await tester.enterText(textFields.at(2), '5');
    await tester.pumpAndSettle();

    await tester.tap(calculateButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid weight between 10 and 500 kg.'), findsOneWidget);
  });
}
