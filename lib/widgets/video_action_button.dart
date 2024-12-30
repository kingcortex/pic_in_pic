import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class VideoActionButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;
  final Color? color;
  final double? size;
  const VideoActionButton({
    super.key,
    required this.iconPath,
    required this.onTap,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: onTap,
      child: SizedBox(
        height: size ?? 25,
        width: size ?? 25,
        child: SvgPicture.asset(
          iconPath,
          color: color ?? Colors.black,
        ),
      ),
    );
  }
}
