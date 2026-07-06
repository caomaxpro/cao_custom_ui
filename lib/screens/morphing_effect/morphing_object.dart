import 'package:flutter/material.dart';

class CubicControlPoint {
  final Offset anchor;
  final Offset control1;
  final Offset control2;

  CubicControlPoint({
    required this.anchor,
    required this.control1,
    required this.control2,
  });
}

class CubicShape {
  final List<CubicControlPoint> points;

  CubicShape({required this.points});
}

class MorphingObject extends StatefulWidget {
  final List<List<CubicControlPoint>> shapes; // Each shape is a list of points

  const MorphingObject({super.key, required this.shapes});

  @override
  State<MorphingObject> createState() => _MorphingObjectState();
}

class _MorphingObjectState extends State<MorphingObject>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int currentShape = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          currentShape = (currentShape + 1) % widget.shapes.length;
        });
        _controller.forward(from: 0);
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipPath(
          clipper: MorphClipper(
            shapeA: widget.shapes[currentShape],
            shapeB: widget.shapes[(currentShape + 1) % widget.shapes.length],
            t: _animation.value,
          ),
          child: Container(width: 200, height: 300, color: Colors.blue),
        );
      },
    );
  }
}

class MorphClipper extends CustomClipper<Path> {
  final List<CubicControlPoint> shapeA;
  final List<CubicControlPoint> shapeB;
  final double t;

  MorphClipper({required this.shapeA, required this.shapeB, required this.t});

  @override
  Path getClip(Size size) {
    Path path = Path();

    if (shapeA.isEmpty || shapeB.isEmpty) {
      return path;
    }

    // Đặt điểm bắt đầu (moveTo) từ điểm anchor đầu tiên
    final firstPointA = shapeA[0];
    final firstPointB = shapeB[0];
    final firstPoint = Offset.lerp(firstPointA.anchor, firstPointB.anchor, t)!;

    path.moveTo(firstPoint.dx, firstPoint.dy);

    // Vẽ các đường cong cubic cho các điểm tiếp theo
    for (int i = 1; i < shapeA.length && i < shapeB.length; i++) {
      final pointA = shapeA[i];
      final pointB = shapeB[i];

      // Nội suy anchor và control points
      final anchor = Offset.lerp(pointA.anchor, pointB.anchor, t)!;
      final control1 = Offset.lerp(pointA.control1, pointB.control1, t)!;
      final control2 = Offset.lerp(pointA.control2, pointB.control2, t)!;

      // Vẽ đường cong cubic
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        anchor.dx,
        anchor.dy,
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant MorphClipper oldClipper) =>
      oldClipper.t != t ||
      oldClipper.shapeA != shapeA ||
      oldClipper.shapeB != shapeB;
}
