import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_sharing_user_app/common_widgets/osm_route_map_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/ride_route_preview_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const captain = LatLng(30.0444, 31.2357);
  const pickup = LatLng(30.1, 31.3);
  const dest = LatLng(30.2, 31.4);

  Widget host({LatLng? destination}) => GetMaterialApp(
    home: Scaffold(body: Builder(builder: (ctx) => Center(child: ElevatedButton(
      key: const Key('open'),
      onPressed: () => RideRoutePreviewCard.show(ctx,
        captain: captain, pickup: pickup, destination: destination,
        pickupAddress: 'Pickup St', destinationAddress: 'Dest St'),
      child: const Text('open'),
    )))),
  );

  OsmRouteMap map(WidgetTester t) => t.widget<OsmRouteMap>(find.byType(OsmRouteMap));

  testWidgets('card opens with two tabs and switches route', (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(destination: dest));
    await tester.tap(find.byKey(const Key('open')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('route_preview_tab_0')), findsOneWidget);
    expect(find.byKey(const Key('route_preview_tab_1')), findsOneWidget);
    expect(map(tester).from, captain);
    expect(map(tester).to, pickup);
    expect(find.text('Pickup St'), findsOneWidget);

    await tester.tap(find.byKey(const Key('route_preview_tab_1')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(map(tester).from, pickup);
    expect(map(tester).to, dest);
    expect(find.text('Dest St'), findsOneWidget);

    await tester.tap(find.byKey(const Key('route_preview_close')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(RideRoutePreviewCard), findsNothing);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('without destination only the captain->pickup tab is shown', (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.tap(find.byKey(const Key('open')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('route_preview_tab_1')), findsNothing);
    expect(map(tester).to, pickup);
    await tester.tap(find.byKey(const Key('route_preview_close')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 10));
  });
}
