import 'package:flutter/material.dart';

class OverlayWithRectangleClipping extends StatelessWidget {
  const OverlayWithRectangleClipping({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: _getCustomPaintOverlay(context));
  }

  //CustomPainter that helps us in doing this
  CustomPaint _getCustomPaintOverlay(BuildContext context) {
    return CustomPaint(
        size: MediaQuery.of(context).size, painter: RectanglePainter());
  }
}

class RectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87;

    canvas.drawPath(
        Path.combine(
          PathOperation.difference, //simple difference of following operations
          //bellow draws a rectangle of full screen (parent) size
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          //bellow clips out the circular rectangle with center as offset and dimensions you need to set
          Path()
            ..addRRect(RRect.fromRectAndRadius(
                Rect.fromCircle(
                    center: Offset(size.width * 0.5, size.height * 0.5),
                    radius: 175),
                const Radius.circular(300)))
            ..close(),
        ),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}