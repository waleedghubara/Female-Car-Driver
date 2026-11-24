import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/map/widgets/customer_ride_request_card_widget.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(TripDetail t) => GetMaterialApp(
    home: Scaffold(body: Center(child: RideRequestInfoStrip(rideRequest: t))),
  );

  testWidgets('normal request shows minutes away, distance and the eye', (tester) async {
    final trip = TripDetail()..type = 'ride_request'..estimatedTime = '5'..estimatedDistance = 6.48;
    await tester.pumpWidget(wrap(trip));
    await tester.pump();
    expect(find.textContaining('min_away'), findsOneWidget);
    expect(find.textContaining('6.48 Km'), findsOneWidget);
    expect(find.byKey(const Key('captain_pickup_eye_button')), findsOneWidget);
    expect(find.text('pickup_date_time'), findsNothing);
  });

  testWidgets('scheduled request shows pickup date/time, distance and the eye', (tester) async {
    final trip = TripDetail()
      ..type = 'scheduled_request'
      ..scheduledAt = '2026-11-20 15:30:00'
      ..estimatedDistance = 12.5;
    await tester.pumpWidget(wrap(trip));
    await tester.pump();
    expect(find.text('pickup_date_time'), findsOneWidget);
    expect(find.textContaining('12.50 Km'), findsOneWidget);
    expect(find.byKey(const Key('captain_pickup_eye_button')), findsOneWidget);
    expect(find.textContaining('min_away'), findsNothing);
  });

  testWidgets('scheduled eye without location shows no crash and no dialog', (tester) async {
    final trip = TripDetail()..type = 'scheduled_request'..scheduledAt = '2026-11-20 15:30:00'..estimatedDistance = 3;
    await tester.pumpWidget(wrap(trip));
    await tester.pump();
    await tester.tap(find.byKey(const Key('captain_pickup_eye_button')));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.byType(Dialog), findsNothing);
    await tester.pump(const Duration(seconds: 5));
  });
}
