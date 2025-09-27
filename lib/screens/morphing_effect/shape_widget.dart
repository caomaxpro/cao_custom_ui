import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ShapeWidget extends StatelessWidget {
  const ShapeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(200, 146), painter: Shape1());
  }
}

class Shape1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(216.513, 134.5);
    path_0.cubicTo(150, 166.5, 180.561, 198.289, 163, 216);
    path_0.cubicTo(145.243, 233.909, 127.225, 212.5, 100.013, 212.5);
    path_0.cubicTo(57.4678, 212.5, 32.0599, 204.389, 18.5129, 166.5);
    path_0.cubicTo(15.5002, 141, -2.51277, 131.5, 0.500049, 94.4999);
    path_0.cubicTo(10.9873, 45.9999, 25.5144, 25.7566, 63.5, 9.49995);
    path_0.cubicTo(102.672, -7.26449, 135.521, 2.17369, 171.5, 25);
    path_0.cubicTo(195.914, 40.489, 202.743, 62.5913, 220.5, 80.4999);
    path_0.cubicTo(238.061, 98.2105, 240.5, 114.5, 216.513, 134.5);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = const Color(0xffF9AB19);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Shape2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(227.513, 117.5);
    path_0.cubicTo(227.513, 144.412, 198.165, 148.789, 180.604, 166.5);
    path_0.cubicTo(162.847, 184.409, 138.225, 195.5, 111.013, 195.5);
    path_0.cubicTo(68.4677, 195.5, 43.0598, 187.389, 29.5128, 149.5);
    path_0.cubicTo(26.5001, 124, -2.5, 134.5, 0.512818, 97.5);
    path_0.cubicTo(11.0001, 49, 33.987, 38.1294, 51.0129, 20.5);
    path_0.cubicTo(84.5129, -9.42819, 110.333, 3.50006, 138.013, 3.50006);
    path_0.cubicTo(180.604, 1.00006, 182.255, 22.5914, 200.013, 40.5001);
    path_0.cubicTo(217.574, 58.2107, 227.513, 90.5886, 227.513, 117.5);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xffD9D9D9).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
