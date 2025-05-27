import 'package:flutter/material.dart';

class GuitarPanImage extends StatefulWidget {
  final double screenWidth;
  final double imgWidth;
  final String assetPath;

  const GuitarPanImage({
    required this.screenWidth,
    required this.imgWidth,
    required this.assetPath,
    Key? key,
  }) : super(key: key);

  @override
  State<GuitarPanImage> createState() => _GuitarPanImageState();
}

class _GuitarPanImageState extends State<GuitarPanImage> {
  late final double minX;
  late final double maxX;
  double imgX = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    minX = 0;
    maxX = (widget.imgWidth - widget.screenWidth).clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          imgX = maxX;
          _initialized = true;
        });
      });
    }

    return GestureDetector(
      onPanUpdate: (d) => setState(() {
        final nextX = imgX - d.delta.dx;
        imgX = nextX.clamp(minX, maxX);
      }),
      child: Stack(children: [
        Positioned(
          left: -imgX,
          top: 0,
          child: Image.asset(
            widget.assetPath,
            width: widget.imgWidth,
            fit: BoxFit.none,
          ),
        ),
      ]),
    );
  }
}
