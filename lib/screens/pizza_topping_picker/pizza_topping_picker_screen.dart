import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_custom_ui/screens/circular_carousel/circular_carousel.dart';

// ================== Data Model ==================

class ToppingState {
  final double startX;
  final double startY;
  final double targetX;
  final double targetY;
  final double r;
  final String name;
  final Color color;

  // Pre-computed path data
  final Path path;
  final double pathLength;

  ToppingState({
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.r,
    required this.name,
    required this.color,
  }) : path = _buildPath(startX, startY, targetX, targetY),
       pathLength = _buildPath(
         startX,
         startY,
         targetX,
         targetY,
       ).computeMetrics().first.length;

  static Path _buildPath(double sx, double sy, double tx, double ty) {
    final path = Path()..moveTo(sx, sy);
    final dx = tx - sx;
    final dy = ty - sy;
    final len = sqrt(dx * dx + dy * dy);

    if (len < 0.001) {
      path.lineTo(tx, ty);
      return path;
    }

    final nx = -dy / len;
    final ny = dx / len;
    const curve = 0.25;

    path.quadraticBezierTo(
      (sx + tx) / 2 + nx * len * curve,
      (sy + ty) / 2 + ny * len * curve,
      tx,
      ty,
    );
    return path;
  }
}

/// Một batch topping cùng thời điểm thêm vào
class _ToppingBatch {
  final List<ToppingState> toppings;
  final double startTime; // thời điểm bắt đầu (seconds)

  const _ToppingBatch({required this.toppings, required this.startTime});
}

// ================== Main Screen ==================

class PizzaToppingPickerScreen extends StatefulWidget {
  const PizzaToppingPickerScreen({super.key});

  @override
  State<PizzaToppingPickerScreen> createState() =>
      _PizzaToppingPickerScreenState();
}

class _PizzaToppingPickerScreenState extends State<PizzaToppingPickerScreen>
    with SingleTickerProviderStateMixin {
  static const double _maxRadius = 0.95 * 230 / 2;
  static const double _minRadius = 10.0;
  static const double _gap = 12.0;
  static const double _toppingRadius = 15.0;
  static const int _toppingsPerClick = 12;
  static const Duration _animDuration = Duration(milliseconds: 1500);

  static const double _deltaMin = 40 * pi / 180;
  static const double _deltaMax = 45 * pi / 180;

  late final List<double> _radii;
  late final Offset _center;

  late final List<double> _largeRadii;
  late final List<double> _mediumRadii;
  late final List<double> _smallRadii;

  final List<ToppingState> _allToppings = [];
  final List<_ToppingBatch> _batches = [];
  final Random _random = Random();

  int _mixingMode = 0;

  // 1 AnimationController duy nhất cho tất cả
  late final AnimationController _controller;
  final Stopwatch _stopwatch = Stopwatch();

  static final List<ItemState> _toppingOptions = [
    ItemState(name: "Pepperoni", color: Colors.red),
    ItemState(name: "Mushroom", color: Colors.brown),
    ItemState(name: "Olive", color: Colors.black),
    ItemState(name: "Corn", color: Colors.yellow),
    ItemState(name: "Green Pepper", color: Colors.green),
    ItemState(name: "Onion", color: Colors.grey),
    ItemState(name: "Tomato", color: Colors.deepOrange),
    ItemState(name: "Bacon", color: Colors.pink),
    ItemState(name: "Pineapple", color: Colors.amber),
    ItemState(name: "Cheese", color: Colors.orangeAccent),
  ];

  static const _mixingOrders = [
    [0, 1, 2],
    [2, 1, 0],
    [1, 2, 0],
  ];

  ui.Image? _pizzaImage;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _loadPizzaImage();
  }

  Future<void> _loadPizzaImage() async {
    final data = await rootBundle.load('assets/images/base.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() => _pizzaImage = frame.image);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pizza Topping Picker')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _initRadii(constraints.maxWidth);
          final pizzaRadius = _radii.first;
          return Stack(
            children: [
              // Dùng AnimatedBuilder để repaint mỗi frame khi controller chạy
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: constraints.maxWidth, // vùng vuông chứa pizza
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _PizzaAndToppingsPainter(
                        radii: _radii,
                        center: _center,
                        batches: _batches,
                        currentTime: _stopwatch.elapsedMilliseconds / 1000.0,
                        animDurationSec: _animDuration.inMilliseconds / 1000.0,
                        pizzaImage: _pizzaImage,
                      ),
                    );
                  },
                ),
              ),

              // Carousel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CircularCarousel(
                  width: constraints.maxWidth,
                  height: 250,
                  radius: 350,
                  itemList: _toppingOptions,
                  center: Offset(constraints.maxWidth / 2, 250 / 2 - 330),
                  onPressed: _onToppingSelected,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- Init ----------

  bool _initialized = false;

  void _initRadii(double screenWidth) {
    if (_initialized) return;
    _initialized = true;

    final int numCircles = ((_maxRadius - _minRadius) ~/ _gap) + 1;
    _radii = List.generate(numCircles, (i) => _maxRadius - i * _gap);
    _center = Offset(screenWidth / 2, screenWidth / 2);

    final int oneThird = (numCircles / 3).round();
    _largeRadii = _radii.sublist(0, oneThird);
    _mediumRadii = _radii.sublist(oneThird, 2 * oneThird);
    _smallRadii = _radii.sublist(2 * oneThird);
  }

  // ---------- Logic ----------

  void _onToppingSelected(ItemState item) {
    final newToppings = _generateToppings(
      count: _toppingsPerClick,
      color: item.color,
    );

    _allToppings.addAll(newToppings);
    _batches.add(
      _ToppingBatch(
        toppings: newToppings,
        startTime: _stopwatch.elapsedMilliseconds / 1000.0,
      ),
    );

    // Resume controller nếu đang dừng
    if (!_controller.isAnimating) {
      _controller.repeat();
    }

    // Tự dừng sau khi animation batch này xong
    _scheduleStop();

    setState(() {
      _mixingMode = (_mixingMode + 1) % 3;
    });
  }

  void _scheduleStop() {
    Future.delayed(_animDuration + const Duration(milliseconds: 50), () {
      if (!mounted) return;

      final now = _stopwatch.elapsedMilliseconds / 1000.0;
      final animSec = _animDuration.inMilliseconds / 1000.0;
      final allDone = _batches.every((b) => (now - b.startTime) >= animSec);

      if (allDone && _controller.isAnimating) {
        // Vẽ 1 frame cuối ở vị trí đích rồi dừng
        _controller.stop();
        // Force 1 repaint cuối
        setState(() {});
      }
    });
  }

  List<ToppingState> _generateToppings({
    required int count,
    required Color color,
  }) {
    final List<ToppingState> result = [];

    // Random hóa góc bắt đầu mỗi lần nhấn
    double angle = _random.nextDouble() * 2 * pi;

    final order = _mixingOrders[_mixingMode];
    final groups = [_largeRadii, _mediumRadii, _smallRadii];

    // Chia đều góc cho các topping
    final double angleStep = 2 * pi / count;

    for (int i = 0; i < count; i++) {
      final groupIndex = order[i % 3];
      final group = groups[groupIndex];
      final r = group.isNotEmpty
          ? group[_random.nextInt(group.length)]
          : _radii[_random.nextInt(_radii.length)];

      result.add(
        ToppingState(
          startX: _center.dx,
          startY: _center.dy,
          targetX: _center.dx + r * cos(angle),
          targetY: _center.dy + r * sin(angle),
          r: _toppingRadius,
          name: 'Topping $i',
          color: color,
        ),
      );

      // Tỏa đều quanh pizza
      angle += angleStep;
    }

    return result;
  }
}

// ================== Combined Painter ==================

class _PizzaAndToppingsPainter extends CustomPainter {
  final List<double> radii;
  final Offset center;
  final List<_ToppingBatch> batches;
  final double currentTime;
  final double animDurationSec;
  final ui.Image? pizzaImage;

  const _PizzaAndToppingsPainter({
    required this.radii,
    required this.center,
    required this.batches,
    required this.currentTime,
    required this.animDurationSec,
    this.pizzaImage,
  });

  // Easing: easeOutCubic
  static double _easeOutCubic(double t) {
    final t1 = 1 - t;
    return 1 - t1 * t1 * t1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // --- draw pizza image ---
    if (pizzaImage != null) {
      // Tăng bán kính ảnh pizza lớn hơn vòng tròn lớn nhất 12px
      final pizzaRadius = radii.first + 30;
      final dstRect = Rect.fromCircle(center: center, radius: pizzaRadius);
      final srcRect = Rect.fromLTWH(
        0,
        0,
        pizzaImage!.width.toDouble(),
        pizzaImage!.height.toDouble(),
      );
      canvas.save();
      canvas.clipPath(Path()..addOval(dstRect));
      canvas.drawImageRect(pizzaImage!, srcRect, dstRect, Paint());
      canvas.restore();
    }

    // --- draw pizza ---
    final circlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final r in radii) {
      canvas.drawCircle(center, r, circlePaint);
    }

    // --- draw toppings ---
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final batch in batches) {
      final elapsed = currentTime - batch.startTime;
      final rawT = (elapsed / animDurationSec).clamp(0.0, 1.0);
      final t = _easeOutCubic(rawT);

      final fillPaint = Paint()..style = PaintingStyle.fill;

      for (final topping in batch.toppings) {
        // Lấy vị trí trên path theo t
        final metric = topping.path.computeMetrics().first;
        final pos = metric.getTangentForOffset(topping.pathLength * t);
        final offset = pos?.position ?? Offset(topping.startX, topping.startY);

        fillPaint.color = topping.color;
        canvas.drawCircle(offset, topping.r, fillPaint);
        canvas.drawCircle(offset, topping.r, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PizzaAndToppingsPainter old) => true;
}
