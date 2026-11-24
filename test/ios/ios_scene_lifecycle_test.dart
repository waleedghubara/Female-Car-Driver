// Guards the UIScene launch setup. A mismatch between Info.plist and
// AppDelegate.swift makes the app open on a permanent black screen, even though
// Dart code runs fine (this happened on iOS).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final info = File('ios/Runner/Info.plist').readAsStringSync();
  final delegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
  final hasScene = info.contains('<key>UIApplicationSceneManifest</key>');

  test('UIScene manifest (if present) points scenes at the Main storyboard', () {
    if (!hasScene) return;
    expect(info.contains('<key>UISceneStoryboardFile</key>'), isTrue,
        reason: 'scene manifest without UISceneStoryboardFile => the scene has no FlutterViewController (black screen)');
    final m = RegExp(r'<key>UISceneStoryboardFile</key>\s*<string>([^<]+)</string>').firstMatch(info)!;
    expect(File('ios/Runner/Base.lproj/${m.group(1)}.storyboard').existsSync(), isTrue);
    final scene = RegExp(r'<key>UISceneDelegateClassName</key>\s*<string>([^<]+)</string>').firstMatch(info);
    expect(scene, isNotNull);
    expect(scene!.group(1), anyOf('FlutterSceneDelegate', contains('SceneDelegate')));
  });

  test('AppDelegate matches the lifecycle declared in Info.plist', () {
    final registersInEngineCallback = delegate.contains('didInitializeImplicitFlutterEngine') &&
        delegate.contains('GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)');
    final registersInLaunch = delegate.contains('GeneratedPluginRegistrant.register(with: self)');
    if (hasScene) {
      expect(delegate.contains('FlutterImplicitEngineDelegate'), isTrue,
          reason: 'scene lifecycle requires AppDelegate: FlutterImplicitEngineDelegate');
      expect(registersInEngineCallback, isTrue);
      expect(registersInLaunch, isFalse,
          reason: 'registering plugins in didFinishLaunching is the old lifecycle');
    } else {
      expect(registersInLaunch, isTrue);
      expect(delegate.contains('FlutterImplicitEngineDelegate'), isFalse);
    }
  });

  test('AppDelegate still calls super.application(didFinishLaunching...)', () {
    expect(delegate.contains('super.application(application, didFinishLaunchingWithOptions: launchOptions)'), isTrue);
  });
}
