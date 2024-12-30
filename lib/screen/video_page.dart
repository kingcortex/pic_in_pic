import 'package:flutter/material.dart';
import 'package:pic_in_pic/extentions/gap.dart';
import 'package:video_player/video_player.dart';

import '../widgets/hud.dart';
import '../widgets/video_action_button.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool _isMinimized = false;
  Offset _offset = const Offset(20, 20);
  late Offset _bottomRightOffset;
  bool _inMoove = false;

  final GlobalKey<MaximisedVideoHudState> _hudKey =
      GlobalKey<MaximisedVideoHudState>();

  late VideoPlayerController _videoController;

  // Constants
  static const double _minimizedHeightFactor = 0.7;
  static const double _appPadding = 20.0;

  @override
  void initState() {
    super.initState();
    _initializeVideoController();
  }

  void _initializeVideoController() {
    _videoController =
        VideoPlayerController.asset("assets/videos/uncharted.mp4")
          ..initialize().then((_) {
            _videoController.play();
            setState(() {});
          });
  }

  void _toggleVideoSize() {
    setState(() {
      _isMinimized = !_isMinimized;
      _offset = _bottomRightOffset;
    });
  }

  void _toggleInMove() {
    setState(() {
      _inMoove = !_inMoove;
    });
  }

  void _rewind10Seconds() async {
    final currentPosition = await _videoController.position;
    if (currentPosition != null) {
      final newPosition = currentPosition - const Duration(seconds: 10);
      _videoController
          .seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
    }
  }

  void _forward10Seconds() async {
    final currentPosition = await _videoController.position;
    if (currentPosition != null) {
      final maxDuration = _videoController.value.duration;
      final newPosition = currentPosition + const Duration(seconds: 10);
      _videoController
          .seekTo(newPosition < maxDuration ? newPosition : maxDuration);
    }
  }

  void _snapToClosestCorner(Size screenSize, Size containerSize) {
    double dx = _offset.dx;
    double dy = _offset.dy;

    final corners = [
      Offset(_appPadding, MediaQuery.of(context).viewPadding.top),
      Offset(screenSize.width - _appPadding - containerSize.width,
          MediaQuery.of(context).viewPadding.top),
      Offset(
          _appPadding,
          screenSize.height -
              containerSize.height -
              MediaQuery.of(context).viewPadding.bottom),
      Offset(
          screenSize.width - _appPadding - containerSize.width,
          screenSize.height -
              containerSize.height -
              MediaQuery.of(context).viewPadding.bottom),
    ];

    final closestCorner = corners.reduce((a, b) {
      final distanceA = (a.dx - dx).abs() + (a.dy - dy).abs();
      final distanceB = (b.dx - dx).abs() + (b.dy - dy).abs();
      return distanceA < distanceB ? a : b;
    });

    setState(() {
      _offset = closestCorner;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final minimizedSize = Size(screenSize.width - _appPadding * 7, 170);

    _bottomRightOffset = Offset(
        screenSize.width - _appPadding - minimizedSize.width,
        screenSize.height -
            minimizedSize.height -
            MediaQuery.of(context).viewPadding.bottom);

    return Stack(
      children: [
        const Scaffold(
          body: Center(
            child: Text(
              "Contenu principal de l'application",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        AnimatedPositioned(
          curve: Curves.easeOutBack,
          duration:
              !_inMoove ? const Duration(milliseconds: 400) : Duration.zero,
          top: _isMinimized
              ? _offset.dy
              : MediaQuery.of(context).viewPadding.top,
          left: _isMinimized ? _offset.dx : 0,
          width: _isMinimized ? minimizedSize.width : screenSize.width,
          height: _isMinimized ? minimizedSize.height : screenSize.height / 3,
          child: GestureDetector(
            onTap: () {
              if (!_isMinimized) _hudKey.currentState?.toggleShow();
            },
            onPanStart: (_) {
              if (_isMinimized) _toggleInMove();
            },
            onPanUpdate: (details) {
              if (_isMinimized) {
                setState(() {
                  _offset += details.delta;
                });
              }
            },
            onPanEnd: (_) {
              if (_isMinimized) {
                _snapToClosestCorner(screenSize, minimizedSize);
                _toggleInMove();
              }
            },
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(_isMinimized ? 12 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_isMinimized ? 12 : 0),
                child: Stack(
                  children: [
                    Container(
                      height: _isMinimized ? minimizedSize.height * 0.7 : null,
                      color: Colors.black,
                      child: Center(
                        child: _videoController.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _videoController.value.aspectRatio,
                                child: VideoPlayer(_videoController),
                              )
                            : Container(),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: VideoActionButton(
                        size: _isMinimized ? 15 : null,
                        color: Colors.white,
                        iconPath: _isMinimized
                            ? "assets/svg/type_close.svg"
                            : "assets/svg/reduit.svg",
                        onTap: _toggleVideoSize,
                      ),
                    ),
                    if (!_isMinimized)
                      Positioned.fill(
                        child: MaximisedVideoHud(
                          key: _hudKey,
                          videoController: _videoController,
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: VideoProgressIndicator(
                              _videoController,
                              allowScrubbing: true,
                            ),
                          ),
                          if (_isMinimized)
                            _buildMinimizedVideoHud(minimizedSize),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimizedVideoHud(Size minimizedSize) {
    return SizedBox(
      height: minimizedSize.height * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VideoActionButton(
            onTap: _rewind10Seconds,
            iconPath: "assets/svg/moin10sec.svg",
          ),
          20.horisontalSpace,
          VideoActionButton(
            onTap: () async {
              _videoController.value.isPlaying
                  ? await _videoController.pause()
                  : await _videoController.play();
              setState(() {});
            },
            iconPath: _videoController.value.isPlaying
                ? "assets/svg/pause.svg"
                : "assets/svg/play_.svg",
          ),
          20.horisontalSpace,
          VideoActionButton(
            onTap: _forward10Seconds,
            iconPath: "assets/svg/plus10sec.svg",
          ),
        ],
      ),
    );
  }
}
