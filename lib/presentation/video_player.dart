import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phonepay_app/utils/colors.dart';
import 'package:video_player/video_player.dart';

import '../utils/constant.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _disposed = false;
  int _isPlayingIndex = -1;
  int _onUpdateControllerTime = -1;
  Duration? _duration = const Duration();
  Duration? _position = const Duration();
  double _progress = 0.0;

  _initPlayer(String video, int index) {
    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      Uri.parse(video),
    );
    final oldController = _controller;
    _controller = controller;
    if (oldController != null) {
      oldController.removeListener(_onControllerUpdate);
      oldController.pause();
    }
    setState(() {});
    controller.initialize().then((value) {
      oldController?.dispose();
      _isPlayingIndex = index;
      controller.addListener(_onControllerUpdate);
      controller.play();
      setState(() {});
    });
  }

  _onControllerUpdate() async {
    if (_disposed) {
      return;
    }
    _onUpdateControllerTime = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_onUpdateControllerTime > now) {
      return;
    }
    _onUpdateControllerTime = now + 500;

    final controller = _controller;
    if (controller == null) {
      debugPrint('Null controller');
      return;
    }
    if (!controller.value.isInitialized) {
      debugPrint('Not initialized');
      return;
    }
    _duration ??= _controller?.value.duration;
    var duration = _duration;
    if (duration == null) return;
    var position = await controller.position;
    _position = position;

    final playing = controller.value.isPlaying;
    if (playing) {
      if (_disposed) return;
      setState(() {
        _progress = position!.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }
    _isPlaying = playing;
  }

  @override
  void dispose() {
    _disposed = true;
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  Widget _playView(BuildContext context) {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: VideoPlayer(controller),
      );
    } else {
      return const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }
  }

  String convertTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Widget _controllerView(BuildContext context) {
    bool noMute = (_controller?.value.volume ?? 0) > 0;
    final duration = _duration?.inSeconds;
    final position = _position?.inSeconds;
    final remainder = max(0, duration! - position!);
    final mins = convertTwo(remainder ~/ 60);
    final secs = convertTwo(remainder % 60);
    return Column(
      children: [
        Slider(
          value: max(0, min(_progress * 100, 100)),
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            setState(() {
              _progress = value * 0.01;
            });
          },
          onChangeStart: (value) {
            _controller?.pause();
          },
          onChangeEnd: (value) {
            final duration = _controller?.value.duration;
            if (duration != null) {
              var newValue = max(0, min(value, 99)) * 0.01;
              var millis = (duration.inMilliseconds * newValue).toInt();
              _controller?.seekTo(Duration(milliseconds: millis));
              _controller?.play();
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  if (noMute) {
                    _controller?.setVolume(0);
                  } else {
                    _controller?.setVolume(1);
                  }
                  setState(() {});
                },
                icon: noMute
                    ? const Icon(Icons.volume_up)
                    : const Icon(Icons.volume_off)),
            IconButton(
                onPressed: () {
                  final index = _isPlayingIndex - 1;
                  if (index >= 0) {
                    _initPlayer(videos[index], index);
                  } else {
                    debugPrint('No more videos');
                  }
                },
                icon: const Icon(Icons.fast_rewind)),
            IconButton(
                onPressed: () {
                  if (_isPlaying) {
                    _controller?.pause();
                  } else {
                    _controller?.play();
                  }
                  setState(() {});
                },
                icon: _isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow)),
            IconButton(
                onPressed: () {
                  final index = _isPlayingIndex + 1;
                  if (index <= videos.length - 1) {
                    _initPlayer(videos[index], index);
                  } else {
                    debugPrint('No more videos');
                  }
                },
                icon: const Icon(Icons.fast_forward)),
            Text(
              '$mins:$secs',
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPicker.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorPicker.primaryColor,
        title: const Text('Video Player'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _playView(context),
                _controllerView(context),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              separatorBuilder: (context, index) => const SizedBox(
                height: 8,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                String video = videos[index];
                return GestureDetector(
                  onTap: () {
                    _initPlayer(video, index);
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${index + 1}',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
