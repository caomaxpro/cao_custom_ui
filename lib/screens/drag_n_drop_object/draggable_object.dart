import 'package:flutter/material.dart';

class DraggableObject extends StatelessWidget {
  final double x;
  final double y;
  final bool isDragging;
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  const DraggableObject({
    super.key,
    required this.x,
    required this.y,
    required this.isDragging,
    required this.size,
    required this.color,
    this.onTap,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: onTap,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: Opacity(
          opacity: isDragging ? 0.7 : 1.0,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.drag_indicator, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
