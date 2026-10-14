import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<MethodCall> platformCalls;

  setUp(() {
    platformCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, (call) async {
          platformCalls.add(call);
          final Map<Object?, Object?> args = call.arguments is Map
              ? call.arguments as Map<Object?, Object?>
              : <Object?, Object?>{};
          if (call.method == 'create') {
            return args['hybrid'] == true ? null : 42;
          }
          if (call.method == 'resize') {
            return <String, Object?>{
              'width': args['width'],
              'height': args['height'],
            };
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, null);
  });

  for (final OneTapAndroidCompositionMode mode
      in OneTapAndroidCompositionMode.values) {
    testWidgets(
      '$mode selects native composition and retains auth parameters',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: OneTap(
              key: ValueKey<OneTapAndroidCompositionMode>(mode),
              androidCompositionMode: mode,
              style: const OneTapStyle(size: OneTapSize.large48),
              signInToAnotherAccountButtonEnabled: false,
              authParams: UIAuthParamsBuilder()
                  .withAuthFlow(
                    const ConfidentialFlowData('state', 'challenge'),
                  )
                  .build(),
              onAuth: (_, data) {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final MethodCall creation = platformCalls.singleWhere(
          (call) => call.method == 'create',
        );
        final Map<Object?, Object?> args =
            creation.arguments as Map<Object?, Object?>;
        expect(
          args['viewType'],
          mode == OneTapAndroidCompositionMode.virtualDisplay
              ? 'OneTapVirtualDisplay'
              : 'OneTap',
        );
        expect(
          args['hybrid'] == true,
          mode == OneTapAndroidCompositionMode.hybrid,
        );
        expect(args['hybridFallback'], isNot(true));
        final List<Object?> params =
            const StandardMessageCodec().decodeMessage(
                  ByteData.sublistView(args['params'] as Uint8List),
                )
                as List<Object?>;
        expect(params[5], isTrue);
        expect(params[7], 'state');
        expect(params[8], 'challenge');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(
          platformCalls.where((call) => call.method == 'dispose'),
          hasLength(1),
        );
      },
    );
  }

  testWidgets('the default remains texture-layer composition', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OneTap(
          key: const ValueKey<String>('default'),
          onAuth: (_, data) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<OneTap>(find.byType(OneTap)).androidCompositionMode,
      OneTapAndroidCompositionMode.textureLayer,
    );
    expect(
      tester.widget<AndroidView>(find.byType(AndroidView)).viewType,
      'OneTap',
    );
  });

  testWidgets(
    'withOAuths accepts virtual display and keeps the OAuth payload',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OneTap.withOAuths(
            key: const ValueKey<String>('oauths'),
            androidCompositionMode: OneTapAndroidCompositionMode.virtualDisplay,
            alternativeOAuths: const <OneTapOAuth>{OneTapOAuth.ok},
            onAuth: (_, data) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final AndroidView view = tester.widget<AndroidView>(
        find.byType(AndroidView),
      );
      expect(view.viewType, 'OneTapVirtualDisplay');
      expect((view.creationParams as List<Object?>).first, <String>['ok']);
    },
  );

  testWidgets('Android composition is ignored on iOS', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OneTap(
          key: const ValueKey<String>('ios'),
          androidCompositionMode: OneTapAndroidCompositionMode.virtualDisplay,
          onAuth: (_, data) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<UiKitView>(find.byType(UiKitView)).viewType, 'OneTap');
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets(
    'virtual display forwards auth codes and removes the channel on dispose',
    (tester) async {
      AuthCodeData? received;
      bool? completed;
      await tester.pumpWidget(
        MaterialApp(
          home: OneTap(
            key: const ValueKey<String>('callback'),
            androidCompositionMode: OneTapAndroidCompositionMode.virtualDisplay,
            onAuth: (_, data) {},
            onAuthCode: (data, isCompletion) {
              received = data;
              completed = isCompletion;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final MethodCall creation = platformCalls.singleWhere(
        (call) => call.method == 'create',
      );
      final int id = (creation.arguments as Map<Object?, Object?>)['id'] as int;
      Future<void> send(MethodCall call) =>
          tester.binding.defaultBinaryMessenger.handlePlatformMessage(
            'com.vk.id/onetap-$id',
            const StandardMethodCodec().encodeMethodCall(call),
            (_) {},
          );
      await send(
        const MethodCall('onAuthCode', <Object?>[
          null,
          'code',
          'device',
          'redirect',
        ]),
      );
      expect(received?.code, 'code');
      expect(received?.deviceID, 'device');
      expect(completed, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      received = null;
      await send(
        const MethodCall('onAuthCode', <Object?>[
          null,
          'late',
          'device',
          'redirect',
        ]),
      );
      await send(const MethodCall('onHeight', 144));
      expect(received, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
