import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/circular_carousel/circular_carousel.dart';

class ToppingState {
  double x;
  double y;
  double targetX;
  double targetY;
  double r;
  String name;
  Color color;

  ToppingState({
    required this.x,
    required this.y,
    required this.r,
    required this.targetX,
    required this.targetY,
    required this.name,
    required this.color,
  });
}

class PizzaToppingPickerScreen extends StatefulWidget {
  const PizzaToppingPickerScreen({super.key});

  @override
  State<PizzaToppingPickerScreen> createState() =>
      _PizzaToppingPickerScreenState();
}

class _PizzaToppingPickerScreenState extends State<PizzaToppingPickerScreen> {
  double size = 0;
  final double maxRadius = 0.95 * 230 / 2;
  final double minRadius = 10.0;
  final double gap = 12.0;
  late final List<double> radii;
  late final List<Offset> centers;

  List<ToppingState> toppings = [];

  final List<ItemState> toppingOptions = [
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

  bool reversed = true;
  int mixingMode = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use screenWidth here for initialization
  }

  List<ToppingState> generateRandomToppings({
    required int count,
    required List<double> radii,
    required List<Offset> centers,
    Color color = Colors.red,
    double toppingRadius = 15,
  }) {
    final random = Random();
    List<ToppingState> result = [];

    // Chia radii thành 2 nửa
    int total = radii.length;
    int oneThird = (total / 3).round();

    List<double> largeRadii = radii.sublist(0, oneThird);
    List<double> mediumRadii = radii.sublist(oneThird, 2 * oneThird);
    List<double> smallRadii = radii.sublist(2 * oneThird);

    final Offset center = centers[0];
    double angle = 0;

    if (toppings.isEmpty) {
      angle = (random.nextDouble() * 2 * pi);
    } else {
      final fCoor = toppings[toppings.length - 2];
      final sCoor = toppings.last;

      double fAngle = atan2(
        fCoor.targetY - center.dy,
        fCoor.targetX - center.dx,
      );
      double sAngle = atan2(
        sCoor.targetY - center.dy,
        sCoor.targetX - center.dx,
      );

      angle = (fAngle + sAngle) / 2;
    }

    double deltaMin = 40 * pi / 180;
    double deltaMax = 45 * pi / 180;

    for (int i = 0; i < count; i++) {
      // Xen kẽ bán kính lớn và nhỏ
      double r;
      if (mixingMode == 1) {
        // large, medium, small
        if (i % 3 == 0 && largeRadii.isNotEmpty) {
          r = largeRadii[random.nextInt(largeRadii.length)];
        } else if (i % 3 == 1 && mediumRadii.isNotEmpty) {
          r = mediumRadii[random.nextInt(mediumRadii.length)];
        } else if (i % 3 == 2 && smallRadii.isNotEmpty) {
          r = smallRadii[random.nextInt(smallRadii.length)];
        } else {
          r = radii[random.nextInt(radii.length)];
        }
      } else if (mixingMode == 2) {
        // small, medium, large
        if (i % 3 == 0 && smallRadii.isNotEmpty) {
          r = smallRadii[random.nextInt(smallRadii.length)];
        } else if (i % 3 == 1 && mediumRadii.isNotEmpty) {
          r = mediumRadii[random.nextInt(mediumRadii.length)];
        } else if (i % 3 == 2 && largeRadii.isNotEmpty) {
          r = largeRadii[random.nextInt(largeRadii.length)];
        } else {
          r = radii[random.nextInt(radii.length)];
        }
      } else {
        // mediu, small, large
        if (i % 3 == 0 && smallRadii.isNotEmpty) {
          r = mediumRadii[random.nextInt(smallRadii.length)];
        } else if (i % 3 == 1 && mediumRadii.isNotEmpty) {
          r = smallRadii[random.nextInt(mediumRadii.length)];
        } else if (i % 3 == 2 && largeRadii.isNotEmpty) {
          r = largeRadii[random.nextInt(largeRadii.length)];
        } else {
          r = radii[random.nextInt(radii.length)];
        }
      }

      double targetX = center.dx + r * cos(angle);
      double targetY = center.dy + r * sin(angle);

      result.add(
        ToppingState(
          x: center.dx,
          y: center.dy,
          targetX: targetX,
          targetY: targetY,
          r: toppingRadius,
          name: 'Topping $i',
          color: color,
        ),
      );

      double delta = deltaMin + random.nextDouble() * (deltaMax - deltaMin);
      angle += delta;
      if (angle > 2 * pi) angle -= 2 * pi;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (size == 0) {
      size = MediaQuery.of(context).size.width;
      // You may want to use setState to trigger a rebuild
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() {
          int numCircles = ((maxRadius - minRadius) ~/ gap) + 1;
          radii = List.generate(numCircles, (i) => maxRadius - i * gap);
          centers = List.filled(numCircles, Offset(size / 2, size / 2));
        }),
      );
      return const SizedBox(); // Or a loading indicator
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pizza Topping Picker')),
      body: Align(
        // alignment: Alignment.topCenter,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              CustomPaint(
                painter: _RandomCirclesPainter(radii: radii, centers: centers),
                child: Container(),
              ),
              // Render các điểm test
              ...toppings.asMap().entries.map(
                (entry) => Topping(
                  key: ValueKey(
                    entry.key,
                  ), // Đảm bảo mỗi topping có key duy nhất
                  x: entry.value.x,
                  y: entry.value.y,
                  r: entry.value.r,
                  color: entry.value.color,
                  targetX: entry.value.targetX,
                  targetY: entry.value.targetY,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CircularCarousel(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  radius: 350,
                  itemList: toppingOptions,
                  center: Offset(
                    MediaQuery.of(context).size.width / 2,
                    250 / 2 - 330,
                  ),
                  onPressed: (item) {
                    final newToppings = generateRandomToppings(
                      count: 12,
                      radii: radii,
                      centers: centers,
                      color: item.color,
                    );
                    setState(() {
                      toppings.addAll(newToppings);
                      mixingMode += 1;

                      if (mixingMode > 3) {
                        reversed = !reversed;
                        mixingMode = 1;
                      }
                    });

                    // Sau một frame, cập nhật vị trí về target để trigger animation
                    Future.delayed(Duration(milliseconds: 100), () {
                      setState(() {
                        for (
                          int i = toppings.length - newToppings.length;
                          i < toppings.length;
                          i++
                        ) {
                          toppings[i].x = toppings[i].targetX;
                          toppings[i].y = toppings[i].targetY;
                        }
                      });
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RandomCirclesPainter extends CustomPainter {
  final List<double> radii;
  final List<Offset> centers;
  _RandomCirclesPainter({required this.radii, required this.centers});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < radii.length; i++) {
      canvas.drawCircle(centers[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Topping extends StatefulWidget {
  final double x;
  final double y;
  final double r;
  final Color color;
  final double targetX;
  final double targetY;

  const Topping({
    super.key,
    required this.x,
    required this.y,
    required this.r,
    required this.color,
    required this.targetX,
    required this.targetY,
  });

  @override
  State<Topping> createState() => _ToppingState();
}

class _ToppingState extends State<Topping> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Path _path;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // Tạo đường cong từ điểm xuất phát đến điểm đích
    _path = _createPath();

    // Bắt đầu animation ngay khi widget được tạo
    _controller.forward();
  }

  Path _createPath() {
    Path path = Path();

    // Điểm xuất phát
    path.moveTo(widget.x, widget.y);

    // Trung điểm AB
    final double mx = (widget.x + widget.targetX) / 2;
    final double my = (widget.y + widget.targetY) / 2;

    // Vector AB
    final dx = widget.targetX - widget.x;
    final dy = widget.targetY - widget.y;

    // Vector pháp tuyến (vuông góc AB)
    final length = sqrt(dx * dx + dy * dy);
    final nx = -dy / length;
    final ny = dx / length;

    // Đẩy control point ra ngoài theo pháp tuyến (độ cong = 0.25 * chiều dài AB, bạn có thể chỉnh)
    const double curve = 0.25;
    final double controlX = mx + nx * length * curve;
    final double controlY = my + ny * length * curve;

    // Tạo đường cong bezier đến điểm đích
    path.quadraticBezierTo(controlX, controlY, widget.targetX, widget.targetY);

    return path;
  }

  Offset _calculatePosition(double value) {
    PathMetrics pathMetrics = _path.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt(0);
    value = pathMetric.length * value;
    Tangent? pos = pathMetric.getTangentForOffset(value);
    return pos?.position ?? Offset(widget.x, widget.y);
  }

  @override
  Widget build(BuildContext context) {
    // Tính vị trí hiện tại dựa trên đường cong
    Offset position = _calculatePosition(_animation.value);

    return Stack(
      children: [
        // Vẽ đường cong để debug
        // CustomPaint(
        //   painter: PathPainter(_path),
        //   size: Size(
        //     MediaQuery.of(context).size.width,
        //     MediaQuery.of(context).size.height,
        //   ),
        // ),

        // Topping di chuyển theo đường cong
        Positioned(
          left: position.dx - widget.r,
          top: position.dy - widget.r,
          width: widget.r * 2,
          height: widget.r * 2,
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// Thêm lớp này vào cuối file
class PathPainter extends CustomPainter {
  final Path path;

  PathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
