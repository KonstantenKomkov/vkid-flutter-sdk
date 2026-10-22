import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vkid_flutter_sdk/src/one_tap_resume_frame.dart';

void main() {
  testWidgets(
    'snapshot lasts until texture readiness and ignores stale replies',
    (tester) async {
      final List<Completer<void>> frames = <Completer<void>>[];
      int taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 48,
            child: OneTapResumeFrame(
              awaitSurfaceFrame: (_) {
                final Completer<void> frame = Completer<void>();
                frames.add(frame);
                return frame.future;
              },
              child: GestureDetector(
                onTap: () => taps++,
                child: const ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byType(RawImage), findsOneWidget);
      final Object? image = tester
          .widget<RawImage>(find.byType(RawImage))
          .image;
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(frames, hasLength(1));
      await tester.tap(find.byType(ColoredBox).last);
      expect(taps, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      frames[0].complete();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(tester.widget<RawImage>(find.byType(RawImage)).image, same(image));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      frames[1].complete();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.byType(RawImage), findsNothing);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      frames[2].complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  for (final bool timeout in <bool>[false, true]) {
    testWidgets(
      'snapshot releases after ${timeout ? "timeout" : "native error"}',
      (tester) async {
        final Completer<void> frame = Completer<void>();
        await tester.pumpWidget(
          MaterialApp(
            home: OneTapResumeFrame(
              awaitSurfaceFrame: (_) async {
                if (timeout) return frame.future;
                throw StateError('frame unavailable');
              },
              child: const ColoredBox(color: Colors.blue),
            ),
          ),
        );
        await tester.pumpAndSettle();
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await tester.pump();
        expect(find.byType(RawImage), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));
        await tester.pump();
        expect(find.byType(RawImage), findsNothing);
        frame.complete();
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      },
    );
  }
}
