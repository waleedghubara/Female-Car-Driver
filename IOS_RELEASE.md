# iOS release checklist — Female Captain (driver app)

| | |
|---|---|
| Bundle ID | `com.femalecarriderapp.eon` |
| Firebase iOS App ID | `1:993077501425:ios:ce42617344503e14a2b850` |
| Firebase project | `female-car-1e241` |

## Before building (on the Mac)
1. Apple Developer → Identifiers: create the App ID `com.femalecarriderapp.eon` with **Push Notifications** enabled.
2. App Store Connect → New App using the same bundle id.
3. Firebase → Project settings → Cloud Messaging → upload the **APNs Auth Key (.p8)** for this app (add the Team ID).
4. Maps: the app uses OpenStreetMap — no API key is needed.
5. OTP login uses Firebase phone auth: in Firebase → Authentication enable **Phone**. APNs key (step 3) lets iOS verify silently; the app also registers the reCAPTCHA URL scheme (`app-1-993077501425-ios-ce42617344503e14a2b850` in Info.plist) as fallback.

## Build
```bash
flutter clean
flutter pub get
cd ios && pod install --repo-update && cd ..
flutter test test/ios          # config sanity checks, must pass
flutter build ipa --release --obfuscate --split-debug-info=build/ios/symbols
```
First time on a machine that ran an older version: delete the app from the simulator/device (different bundle id before).
Version comes from `pubspec.yaml` (`version: x.y.z+build`); raise the build number for every upload to App Store Connect.
Open `ios/Runner.xcworkspace` in Xcode, pick the Team (Automatic signing) and upload with Organizer/Transporter.

## Must stay consistent (otherwise the app shows a black screen at launch)
`ios/Runner/GoogleService-Info.plist` ⇄ `lib/firebase_options.dart` (iOS block) ⇄ `PRODUCT_BUNDLE_IDENTIFIER` in Xcode.
`flutter test test/ios` checks all of this; run it before every iOS build.

## Verify in Xcode
Runner → Build Phases → *Copy Bundle Resources* contains `GoogleService-Info.plist`.
