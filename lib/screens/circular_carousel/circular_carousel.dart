import 'dart:math';

import 'package:flutter/material.dart';

// this is the item's model
class ItemState {
  String name;
  double x;
  double y;
  Color color;
  double radius;
  Image? itemImage;

  ItemState({
    this.name = "",
    this.x = 0,
    this.y = 0,
    this.color = Colors.white,
    this.radius = 0,
    this.itemImage,
  });
}

class CircularCarousel extends StatefulWidget {
  // height and width of the container
  // main circle
  final double height;
  final double width;

  // size of the circle
  final double radius;

  // the circle's position
  final Offset center;

  // list of items should be rendered in the container
  final List<ItemState> itemList;

  // items
  final void Function(ItemState item)? onPressed;

  double minItemRadius;
  double maxItemRadius;

  CircularCarousel({
    super.key,
    this.height = 0,
    this.width = 0,
    this.itemList = const [],
    this.radius = 60,
    this.center = const Offset(0, 0),

    this.onPressed,
    this.minItemRadius = 60,
    this.maxItemRadius = 80,
  });

  @override
  State<CircularCarousel> createState() => _CircularCarouselState();
}

class _CircularCarouselState extends State<CircularCarousel> {
  Offset center = Offset.zero;
  double startAngle = 0;
  List<ItemState> items = [];
  bool isLocked = false;
  double lockedAngle = 0;

  void _renderItems() {
    // calculate
  }

  void _drawCircle() {}

  @override
  void initState() {
    super.initState();

    center = widget.center;

    // testing item
    items = widget.itemList;

    final double angleStep = 2 * pi / items.length;

    for (int i = 0; i < items.length; i++) {
      // Bắt đầu từ 90 độ (π/2 radian), tức là điểm dưới cùng
      double angle = pi / 2 + i * angleStep;
      double x = center.dx + widget.radius * cos(angle);
      double y = center.dy + widget.radius * sin(angle);

      items[i].x = x;
      items[i].y = y;
      items[i].color = Colors.primaries[i % Colors.primaries.length];
      items[i].radius = i == 0 ? widget.maxItemRadius : widget.minItemRadius;

      // items.add(
      //   ItemState(
      //     x: x,
      //     y: y,
      //     color: Colors.primaries[i % Colors.primaries.length],
      //     radius: i == 0 ? 80 : 60,
      //   ),
      // );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    debugPrint("[On Drag]: True");
    setState(() {
      // Điều chỉnh hệ số 0.01 cho phù hợp độ nhạy
      startAngle += details.delta.dx * 0.01;

      debugPrint("[Start Angle]: $startAngle");
    });
  }

  // minimize item.radius
  void _updateItem() {}

  void _snapToNearest90() {
    final int itemCount = items.length;
    double minDiff = double.infinity;
    int nearestIndex = 0;
    double nearestAngle = 0;

    // Tìm item có góc gần nhất với 90 độ (pi/2)
    for (int i = 0; i < itemCount; i++) {
      double angle = (startAngle + pi / 2 + 2 * pi * i / itemCount) % (2 * pi);
      double diff = (angle - pi / 2).abs();
      if (diff > pi) diff = 2 * pi - diff;
      if (diff < minDiff) {
        minDiff = diff;
        nearestIndex = i;
        nearestAngle = angle;
      }
    }

    setState(() {
      debugPrint("update processing...");
      // Tính delta để item này về đúng 90 độ
      double delta = (pi / 2 - nearestAngle);

      // reset item back to its minItemRadius
      for (int i = 0; i < itemCount; i++) {
        items[i].radius = widget.minItemRadius;
      }

      items[nearestIndex].radius = widget.maxItemRadius;

      // for (int i = 0; i < itemCount; i++) {
      //   debugPrint(
      //     "Item $i: x=${items[i].x}, y=${items[i].y}, radius=${items[i].radius}",
      //   );
      // }

      startAngle += delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        debugPrint("On Tap");
        // stop startAngle from updating
        setState(() {
          isLocked = true;
          lockedAngle = startAngle; // Khóa lại
        });
      },
      onHorizontalDragUpdate: (details) {
        if (!isLocked) {
          setState(() {
            startAngle -= details.delta.dx * 0.009;

            for (int i = 0; i < items.length; i++) {
              items[i].radius = 60; // reset về mặc định
            }
          });
        }
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          _snapToNearest90();
        });
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          isLocked = false;
          startAngle += 0; // Mở khóa khi nhả tay
        });
      },
      onTapCancel: () {
        setState(() {
          isLocked = false;
          startAngle += 0;
        });
      },
      child: Container(
        height: widget.height,
        width: widget.width,
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: isLocked ? lockedAngle : startAngle,
          ),
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeOut,
          builder: (context, animatedAngle, child) {
            final int itemCount = items.length;
            final double radius = widget.radius > 0 ? widget.radius : 100;

            // Chỉ cập nhật lại vị trí cho từng item, KHÔNG cập nhật lại radius
            for (int i = 0; i < itemCount; i++) {
              double angle = animatedAngle + pi / 2 + 2 * pi * i / itemCount;
              double x = center.dx + radius * cos(angle);
              double y = center.dy + radius * sin(angle);
              items[i].x = x;
              items[i].y = y;
              // KHÔNG cập nhật lại radius ở đây!
            }

            return Stack(
              children: [
                // CustomPaint(
                //   painter: CirclePainter(center: center, radius: radius),
                // ),
                // CustomPaint(
                //   painter: LinePainter(
                //     center: center,
                //     radius: radius,
                //     degAngle: animatedAngle * 180 / pi,
                //   ),
                // ),
                ...items.map(
                  (item) => Positioned(
                    left: item.x - item.radius,
                    top: item.y - item.radius,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.onPressed != null &&
                            item.radius == widget.maxItemRadius) {
                          widget.onPressed!(item);
                        }
                      },
                      child: Container(
                        width: item.radius * 2,
                        height: item.radius * 2,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Offset center;
  final double radius;

  CirclePainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LinePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double degAngle; // radian, mặc định là 0 (hướng sang phải)

  LinePainter({required this.center, required this.radius, this.degAngle = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    final double angle = degAngle * pi / 180;

    // Tính điểm mép đường tròn theo góc
    final Offset edge = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    canvas.drawLine(center, edge, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.degAngle != degAngle;
  }
}
