import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// ================== Data Model (Immutable) ==================

class ItemState {
  final String name;
  final Color color;

  const ItemState({this.name = "", this.color = Colors.white});
}

// ================== Widget ==================

class CircularCarousel extends StatefulWidget {
  final double height;
  final double width;
  final double radius;
  final Offset center;
  final List<ItemState> itemList;
  final void Function(ItemState item)? onPressed;
  final double minItemRadius;
  final double maxItemRadius;

  const CircularCarousel({
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

class _CircularCarouselState extends State<CircularCarousel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late double _currentAngle; // góc hiện tại (radian)
  double _targetAngle = 0; // góc đích sau snap
  int _selectedIndex = 0;

  int get _itemCount => widget.itemList.length;
  double get _angleStep => 2 * pi / _itemCount;
  double get _radius => widget.radius > 0 ? widget.radius : 100;

  @override
  void initState() {
    super.initState();
    _currentAngle = 0;
    _targetAngle = 0;

    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        )..addListener(() {
          setState(() {
            // Lerp từ current → target
            _currentAngle = lerpDouble(
              _currentAngle,
              _targetAngle,
              _animController.value,
            )!;
          });
        });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ---------- Gesture ----------

  double _dragStartAngle = 0;

  void _onDragStart(DragStartDetails details) {
    _animController.stop();
    _dragStartAngle = _currentAngle;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _currentAngle -= details.delta.dx * 0.009;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _snapToNearest();
  }

  void _snapToNearest() {
    // Tìm item gần 90° (pi/2) nhất
    double minDiff = double.infinity;
    int nearestIndex = 0;

    for (int i = 0; i < _itemCount; i++) {
      final angle = (_currentAngle + pi / 2 + _angleStep * i) % (2 * pi);
      var diff = (angle - pi / 2).abs();
      if (diff > pi) diff = 2 * pi - diff;
      if (diff < minDiff) {
        minDiff = diff;
        nearestIndex = i;
      }
    }

    // Tính delta cần xoay
    final nearestAngle =
        (_currentAngle + pi / 2 + _angleStep * nearestIndex) % (2 * pi);
    final delta = pi / 2 - nearestAngle;

    _targetAngle = _currentAngle + delta;
    _selectedIndex = nearestIndex;

    // Animate tới target
    _dragStartAngle = _currentAngle;
    _animController.forward(from: 0);
  }

  // ---------- Position helpers ----------

  Offset _itemPosition(int index) {
    final angle = _currentAngle + pi / 2 + _angleStep * index;
    return Offset(
      widget.center.dx + _radius * cos(angle),
      widget.center.dy + _radius * sin(angle),
    );
  }

  double _itemRadius(int index) {
    // Item được chọn lớn hơn
    return index == _selectedIndex
        ? widget.maxItemRadius
        : widget.minItemRadius;
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Container(
        height: widget.height,
        width: widget.width,
        color: Colors.transparent,
        child: Stack(
          children: List.generate(_itemCount, (i) {
            final pos = _itemPosition(i);
            final r = _itemRadius(i);
            final item = widget.itemList[i];

            return Positioned(
              left: pos.dx - r,
              top: pos.dy - r,
              width: r * 2,
              height: r * 2,
              child: GestureDetector(
                onTap: () {
                  if (i == _selectedIndex) {
                    widget.onPressed?.call(item);
                  } else {
                    // Snap tới item này
                    _selectedIndex = i;
                    final angle =
                        (_currentAngle + pi / 2 + _angleStep * i) % (2 * pi);
                    final delta = pi / 2 - angle;
                    _targetAngle = _currentAngle + delta;
                    _dragStartAngle = _currentAngle;
                    _animController.forward(from: 0);
                  }
                },
                child: _ItemCircle(
                  color: item.color,
                  name: item.name,
                  isSelected: i == _selectedIndex,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ================== Item Widget (const-friendly) ==================

class _ItemCircle extends StatelessWidget {
  final Color color;
  final String name;
  final bool isSelected;

  const _ItemCircle({
    required this.color,
    required this.name,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: isSelected
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12)]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSelected ? 12 : 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
