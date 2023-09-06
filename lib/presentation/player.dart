import 'package:flutter/material.dart';
import 'package:phonepay_app/utils/colors.dart';
import 'package:video_player/video_player.dart';

import '../widgets/video_player_widget.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController controller;
  @override
  void initState() {
    controller = VideoPlayerController.networkUrl(Uri.parse(
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"))
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((_) => controller.play());

    // setLandscape();
    super.initState();
  }

  // setLandscape() async {
  //   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  //   await SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.landscapeLeft,
  //     DeviceOrientation.landscapeRight,
  //   ]);
  // }

  // setAllOrientations() async {
  //   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual);
  //   await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  // }

  @override
  void dispose() {
    controller.dispose();
    // setAllOrientations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorPicker.backgroundColor,
        // appBar: AppBar(
        //   backgroundColor: ColorPicker.secondaryColor,
        //   title: const Text('Video Player'),
        //   centerTitle: true,
        // ),
        body: SafeArea(
          child: VideoPlayerWidget(
            controller: controller,
          ),
        ));
  }
}
