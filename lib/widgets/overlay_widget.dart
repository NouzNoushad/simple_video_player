import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OverlayWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final void Function()? onClickFullScreen;
  const OverlayWidget(
      {super.key, required this.controller, required this.onClickFullScreen});
  static const allSpeeds = [0.25, 0.5, 1, 1.5, 2, 3, 5, 10];
  getPosition() {
    final duration = Duration(
        milliseconds: controller.value.position.inMilliseconds.round());
    return [
      duration.inMinutes,
      duration.inSeconds,
    ].map((e) => e.remainder(60).toString().padLeft(2, '0')).join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildPlay(),
        buildSpeed(),
        Positioned(
          left: 8,
          bottom: 28,
          child: Text(
            getPosition(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(children: [
            Expanded(child: buildIndicator()),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: onClickFullScreen,
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ]),
        )
      ],
    );
  }

  Widget buildSpeed() => Align(
        alignment: Alignment.topRight,
        child: PopupMenuButton<double>(
          initialValue: controller.value.playbackSpeed,
          tooltip: 'Playback speed',
          onSelected: controller.setPlaybackSpeed,
          itemBuilder: (context) => allSpeeds
              .map<PopupMenuEntry<double>>(
                  (e) => PopupMenuItem(value: e + 0.0, child: Text('${e}X')))
              .toList(),
          child: Container(
            color: Colors.white38,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text('${controller.value.playbackSpeed}x'),
          ),
        ),
      );

  Widget buildIndicator() => Container(
        margin: const EdgeInsets.all(8).copyWith(right: 0),
        height: 16,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
        ),
      );

  Widget buildPlay() => controller.value.isPlaying
      ? Container()
      : Container(
          color: Colors.black26,
          child: const Center(
              child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 70,
          )),
        );
}
