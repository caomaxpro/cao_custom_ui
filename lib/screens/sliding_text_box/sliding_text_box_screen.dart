import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile_custom_ui/screens/sliding_text_box/sliding_text.box.dart';

class SlidingTextBoxStateData {
  double x;
  double y;
  double width;
  double height;
  double xEnd;
  String text;
  int id;
  GlobalKey? containerKey;

  SlidingTextBoxStateData({
    this.containerKey,
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.xEnd,
    required this.text,
  });
}

class SlidingTextBoxScreen extends StatefulWidget {
  const SlidingTextBoxScreen({super.key});

  @override
  State<SlidingTextBoxScreen> createState() => _SlidingTextBoxScreenState();
}

class _SlidingTextBoxScreenState extends State<SlidingTextBoxScreen>
    with SingleTickerProviderStateMixin {
  List<SlidingTextBoxStateData> boxStates = [
    SlidingTextBoxStateData(
      containerKey: GlobalKey(),
      id: 0,
      x: 0,
      xEnd: 0,
      y: 0,
      width: 0,
      height: 60,
      text:
          "Lỗi này xảy ra vì bạn bọc một Positioned hoặc AnimatedPositioned bên trong một Positioned",
    ),
    SlidingTextBoxStateData(
      containerKey: GlobalKey(),
      id: 1,
      x: 0,
      xEnd: 0,
      y: 0,
      width: 0,
      height: 60,
      text:
          "Lỗi này xảy ra vì bạn bọc một Positioned hoặc AnimatedPositioned bên trong một Positioned",
    ),
  ];

  late Ticker _ticker;
  double speed = 0.5; // tốc độ di chuyển mỗi frame

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTextWidthAndAnimate();

      _ticker = Ticker((_) {
        setState(() {
          for (var i = 0; i < boxStates.length; i++) {
            var box = boxStates[i];
            box.x -= speed;

            // Infinite slider logic: nếu box ra khỏi main container bên trái
            if (box.x + box.width <= 0) {
              // Tìm box còn lại
              int other = (i == 0) ? 1 : 0;
              // Đặt box này ra sau box kia
              box.x = boxStates[other].x + boxStates[other].width;
            }
          }
        });
      });
      _ticker.start();
    });
  }

  void _getTextWidthAndAnimate() {
    for (var i = 0; i < boxStates.length; i++) {
      final box = boxStates[i];
      final RenderBox? renderBox =
          box.containerKey?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          boxStates[i].x = i * renderBox.size.width;
          boxStates[i].xEnd = i * renderBox.size.width - renderBox.size.width;
          boxStates[i].y = box.y + (60 - renderBox.size.height) / 2;
          boxStates[i].width = renderBox.size.width;
          boxStates[i].height = renderBox.size.height;
        });
      }
    }
  }

  @override
  void dispose() {
    _ticker.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sliding Text Box')),
      body: Align(
        alignment: Alignment.topLeft,
        child: SlidingTextBox(
          containerWidth: MediaQuery.of(context).size.width - 100,
          containerHeight: 60,
          text:
              "Tạo 2 box mặc định với text là widget.text và width đã tính toán.",
          textStyle: TextStyle(fontSize: 24),
          backgroundColor: Colors.blue,
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
    );
  }
}
