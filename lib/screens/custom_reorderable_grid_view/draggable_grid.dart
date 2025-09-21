import 'dart:math' as math;
import 'package:flutter/material.dart';

class DraggableObject extends StatelessWidget {
  final double x;
  final double y;
  final int row;
  final bool isDragging;
  final double width;
  final double height;
  final Color color;
  final String label;
  final bool display;

  const DraggableObject({
    super.key,
    required this.x,
    required this.y,
    required this.isDragging,
    required this.width,
    required this.height,
    required this.color,
    required this.label,
    required this.display,
    this.row = -1,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 8000),
      curve: Curves.easeInOut,
      left: x,
      top: y,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: display ? (isDragging ? 0.85 : 1.0) : 0.0,
        child: Transform.scale(
          scale: isDragging ? 1.03 : 1.0,
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActiveDraggableObject extends StatelessWidget {
  final double x;
  final double y;
  final int row;
  final bool isDragging;
  final double width;
  final double height;
  final Color color;
  final String label;
  final bool display;

  const ActiveDraggableObject({
    super.key,
    required this.x,
    required this.y,
    required this.isDragging,
    required this.width,
    required this.height,
    required this.color,
    required this.label,
    required this.display,
    this.row = -1,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      left: x,
      top: y,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: display ? (isDragging ? 0.85 : 1.0) : 0.0,
        child: Transform.scale(
          scale: isDragging ? 1.03 : 1.0,
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
