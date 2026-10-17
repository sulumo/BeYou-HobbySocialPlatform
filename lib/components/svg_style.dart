import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransparentSvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;

  const TransparentSvgIcon({
    super.key,
    required this.assetPath,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: const ColorFilter.mode(
        Colors.transparent,
        BlendMode.srcATop,
      ),
    );
  }
}
