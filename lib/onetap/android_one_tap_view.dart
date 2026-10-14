part of '../library_vkid.dart';

class _AndroidOneTapHybridView extends StatelessWidget {
  final List<Object?> creationParams;
  final PlatformViewCreatedCallback onPlatformViewCreated;

  const _AndroidOneTapHybridView({
    required this.creationParams,
    required this.onPlatformViewCreated,
  });

  @override
  Widget build(BuildContext context) => PlatformViewLink(
    viewType: 'OneTap',
    surfaceFactory: (context, controller) => AndroidViewSurface(
      controller: controller as AndroidViewController,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      hitTestBehavior: PlatformViewHitTestBehavior.opaque,
    ),
    onCreatePlatformView: (params) =>
        PlatformViewsService.initExpensiveAndroidView(
            id: params.id,
            viewType: 'OneTap',
            layoutDirection: Directionality.of(context),
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
          ..create(),
  );
}
