import 'package:flutter_test/flutter_test.dart';
import 'package:houses/src/houses_app.dart';

void main() {
  testWidgets('lists the available addresses', (tester) async {
    await tester.pumpWidget(const HousesApp());
    expect(find.text('Houses'), findsOneWidget);
    expect(find.text('Abrahamsbergsvägen 18'), findsOneWidget);
    expect(find.text('Berganäsvägen 18B'), findsOneWidget);
    expect(find.text('Open the sun study'), findsNWidgets(2));
  });
}
