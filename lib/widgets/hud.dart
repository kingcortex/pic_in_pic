import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pic_in_pic/extentions/gap.dart';
import 'package:video_player/video_player.dart';

import 'video_action_button.dart';

class MaximisedVideoHud extends StatefulWidget {
  final VideoPlayerController videoController;
  const MaximisedVideoHud({super.key, required this.videoController});

  @override
  State<MaximisedVideoHud> createState() => MaximisedVideoHudState();
}

class MaximisedVideoHudState extends State<MaximisedVideoHud> {
  bool _show = true;
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _cancelHideTimer(); // Annule le Timer lors de la destruction du widget
    super.dispose();
  }

  void _startHideTimer() {
    _cancelHideTimer(); // Annule tout Timer actif
    _delay = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _show = false;
        });
      }
    });
  }

  void _cancelHideTimer() {
    _delay?.cancel();
    _delay = null;
  }

  void toggleShow() {
    setState(() {
      _show = !_show;
    });

    if (_show) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  void _rewind10Seconds() async {
    _startHideTimer();
    final currentPosition = await widget.videoController.position;
    if (currentPosition != null) {
      final newPosition = currentPosition - const Duration(seconds: 10);
      widget.videoController
          .seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
    }
  }

  void _forward10Seconds() async {
    _startHideTimer();
    final currentPosition = await widget.videoController.position;
    if (currentPosition != null) {
      final maxDuration = widget.videoController.value.duration;
      final newPosition = currentPosition + const Duration(seconds: 10);
      widget.videoController
          .seekTo(newPosition < maxDuration ? newPosition : maxDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _show ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: _show,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VideoActionButton(
                  size: 30,
                  color: Colors.white,
                  onTap: () => _rewind10Seconds(),
                  iconPath: "assets/svg/moin10sec.svg",
                ),
                50.horisontalSpace,
                VideoActionButton(
                  size: 35,
                  color: Colors.white,
                  onTap: () async {
                    _startHideTimer(); // Redémarre le Timer à chaque interaction
                    widget.videoController.value.isPlaying
                        ? await widget.videoController.pause()
                        : await widget.videoController.play();
                    setState(() {});
                  },
                  iconPath: widget.videoController.value.isPlaying
                      ? "assets/svg/pause.svg"
                      : "assets/svg/play_.svg",
                ),
                50.horisontalSpace,
                VideoActionButton(
                  size: 30,
                  color: Colors.white,
                  onTap: () => _forward10Seconds(),
                  iconPath: "assets/svg/plus10sec.svg",
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
