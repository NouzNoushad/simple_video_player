import 'package:flutter/material.dart';
import 'package:phonepay_app/widgets/overlay_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:auto_orientation/auto_orientation.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController? controller;
  const VideoPlayerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) =>
      (controller != null && controller!.value.isInitialized)
          ? Container(
              alignment: Alignment.topCenter,
              child: buildVideo(),
            )
          : Container();

  Widget buildVideo() => OrientationBuilder(builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        return Stack(
          fit: isPortrait ? StackFit.loose : StackFit.expand,
          children: [
            buildVideoPlayer(),
            Positioned.fill(
                child: OverlayWidget(
              controller: controller!,
              onClickFullScreen: () {
                if (isPortrait) {
                  AutoOrientation.landscapeAutoMode();
                } else {
                  AutoOrientation.portraitAutoMode();
                }
              },
            ))
          ],
        );
      });

  Widget buildVideoPlayer() => buildFullScreen(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );

  Widget buildFullScreen({required Widget child}) {
    final Size size = controller!.value.size;
    final double width = size.width;
    final double height = size.height;
    return FittedBox(
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}
