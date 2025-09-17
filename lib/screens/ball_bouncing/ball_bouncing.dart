import 'package:flutter/material.dart';
import 'dart:math';

class BouncingBallsDemo extends StatefulWidget {
  const BouncingBallsDemo({super.key});

  @override
  State<BouncingBallsDemo> createState() => _BouncingBallsDemoState();
}

class _BouncingBallsDemoState extends State<BouncingBallsDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late _Ball ball;
  final double ballRadius = 24;
  final double gravity = 10; // px/s^2
  final double bounceLoss = 0.7;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(days: 365))
          ..addListener(_tick)
          ..forward();

    ball = _Ball(x: 0.5, y: ballRadius, vy: 0, color: Colors.red);
  }

  void _tick() {
    if (isDragging) return; // Không cập nhật vật lý khi đang drag
    final dt = _controller.lastElapsedDuration != null
        ? _controller.lastElapsedDuration!.inMilliseconds / 1000
        : 0.016;

    final maxY = MediaQuery.of(context).size.height - ballRadius;

    // Nếu bóng đã dừng hẳn thì không update nữa
    if (ball.vy <= 0 && ball.y == maxY) {
      setState(() {
        ball.vy = 0;
      });
      return;
    }

    setState(() {
      ball.vy += gravity * dt;
      ball.y += ball.vy * dt;

      debugPrint(
        'y: ${ball.y.toStringAsFixed(2)}, vy: ${ball.vy.toStringAsFixed(2)}',
      );

      debugPrint('maxY: ${maxY.toStringAsFixed(2)}');

      if (ball.y > maxY) {
        ball.y = maxY;
        // Chỉ lấy vận tốc rơi ngay trước khi chạm đất
        if (ball.vy > 0) {
          ball.vy = -bounceLoss * ball.vy;
        }
        if (ball.vy.abs() < 1) {
          ball.vy = 0; // Dừng bóng hoàn toàn nếu vận tốc quá nhỏ
        }
        debugPrint(
          'Bounce up! y: ${ball.y.toStringAsFixed(2)}, vy: ${ball.vy.toStringAsFixed(2)}',
        );
      }
    });
  }

  void _startDrag(DragStartDetails details, BuildContext context) {
    setState(() {
      isDragging = true;
      ball.vy = 0;
    });
  }

  void _updateDrag(DragUpdateDetails details, BuildContext context) {
    setState(() {
      ball.x = details.localPosition.dx / MediaQuery.of(context).size.width;
      ball.y = details.localPosition.dy;
    });
  }

  void _endDrag(DragEndDetails details) {
    setState(() {
      isDragging = false;
      ball.vy = 0; // vận tốc hướng lên nhẹ, bóng sẽ rơi rồi nảy lên
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _startDrag(details, context),
      onPanUpdate: (details) => _updateDrag(details, context),
      onPanEnd: _endDrag,
      child: CustomPaint(
        painter: _BallsPainter(balls: [ball], ballRadius: ballRadius),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _Ball {
  double x;
  double y;
  double vy;
  Color color;

  _Ball({
    required this.x,
    required this.y,
    required this.vy,
    required this.color,
  });
}

class _BallsPainter extends CustomPainter {
  final List<_Ball> balls;
  final double ballRadius;

  _BallsPainter({required this.balls, required this.ballRadius});

  @override
  void paint(Canvas canvas, Size size) {
    for (var ball in balls) {
      final dx = size.width * ball.x;
      final dy = ball.y;
      final paint = Paint()..color = ball.color;
      canvas.drawCircle(Offset(dx, dy), ballRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BallsPainter oldDelegate) => true;
}
