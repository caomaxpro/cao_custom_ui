import 'package:flutter/material.dart';
import 'draggable_object.dart';

class DragObjectState {
  double x;
  double y;
  bool isDragging;
  final double size;
  final Color color;

  DragObjectState({
    required this.x,
    required this.y,
    this.isDragging = false,
    required this.size,
    required this.color,
  });
}

class TestDragScreen extends StatefulWidget {
  const TestDragScreen({super.key});

  @override
  State<TestDragScreen> createState() => _TestDragScreenState();
}

class _TestDragScreenState extends State<TestDragScreen> {
  final List<DragObjectState> objects = [
    DragObjectState(x: 100, y: 200, size: 80, color: Colors.blue),
    DragObjectState(x: 220, y: 350, size: 80, color: Colors.red),
    DragObjectState(x: 140, y: 450, size: 80, color: Colors.cyanAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Drag Object')),
      body: Stack(
        children: [
          for (int i = 0; i < objects.length; i++)
            DraggableObject(
              x: objects[i].x,
              y: objects[i].y,
              isDragging: objects[i].isDragging,
              size: objects[i].size,
              color: objects[i].color,
              onPanStart: (details) {
                setState(() {
                  objects[i].isDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  objects[i].x += details.delta.dx;
                  objects[i].y += details.delta.dy;
                });
              },
              onPanEnd: (details) {
                setState(() {
                  objects[i].isDragging = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
