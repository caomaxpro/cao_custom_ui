import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// filepath: /home/cao-le/Flutter Projects/mobile_custom_ui/mobile_custom_ui/lib/screens/sliding_text_box/sliding_text.box.dart

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

class SlidingTextBox extends StatefulWidget {
  double containerWidth = 0;
  double containerHeight = 0;
  String text = "";

  final Color backgroundColor;
  TextStyle? textStyle;
  final double opacity;
  final BorderRadiusGeometry borderRadius; // Thêm thuộc tính bo góc
  final Color borderColor; // Thêm thuộc tính màu viền
  final double borderWidth;

  SlidingTextBox({
    super.key,
    required this.containerWidth,
    required this.containerHeight,
    required this.text,
    this.backgroundColor = Colors.transparent,
    this.textStyle = const TextStyle(fontSize: 10),
    this.opacity = 1,
    this.borderColor = Colors.transparent,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
    this.borderWidth = 0,
  });

  @override
  State<SlidingTextBox> createState() => _SlidingTextBoxScreenState();
}

class _SlidingTextBoxScreenState extends State<SlidingTextBox>
    with SingleTickerProviderStateMixin {
  List<SlidingTextBoxStateData> boxStates = [];

  late Ticker _ticker;
  double speed = 0.5; // tốc độ di chuyển mỗi frame

  @override
  void initState() {
    super.initState();

    boxStates = [
      SlidingTextBoxStateData(
        containerKey: GlobalKey(),
        id: 0,
        x: 0,
        xEnd: 0,
        y: 0,
        width: 0,
        height: 0,
        text: widget.text,
      ),
      SlidingTextBoxStateData(
        containerKey: GlobalKey(),
        id: 1,
        x: 0,
        xEnd: 0,
        y: 0,
        width: 0,
        height: 0,
        text: widget.text,
      ),
    ];

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

            // Nếu box cuối cùng chạm ngưỡng phải (containerWidth)
            if (box.x >= widget.containerWidth) {
              // Tìm box còn lại
              int other = (i == 0) ? 1 : 0;
              // Đặt box này lên đầu (trước box kia)
              box.x = boxStates[other].x - box.width;
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
    return GestureDetector(
      onHorizontalDragStart: (_) {
        _ticker.stop(); // Dừng animation khi bắt đầu swipe
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          for (var box in boxStates) {
            box.x += details.primaryDelta ?? 0; // Cập nhật vị trí theo swipe
          }
        });
      },
      onHorizontalDragEnd: (_) {
        _ticker.start(); // Bắt đầu lại animation sau khi swipe xong
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: widget.borderWidth == 0
              ? null
              : Border.all(
                  width: widget.borderWidth,
                  color: widget.borderColor,
                ),
          borderRadius: widget.borderRadius,
        ),
        width: widget.containerWidth,
        height: widget.containerHeight,
        child: Stack(
          children: boxStates.map((box) {
            return InnerBox(
              containerKey: box.containerKey,
              id: box.id,
              x: box.x,
              y: box.y,
              text: box.text,
              textStyle: widget.textStyle!,
              opacity: widget.opacity,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class InnerBox extends StatelessWidget {
  final int id;
  final double x;
  final double y;
  final double width;
  final double height;
  final Color backgroundColor;
  final String text;
  final TextStyle textStyle;
  final GlobalKey? containerKey;
  final double opacity; // Thêm thuộc tính opacity

  const InnerBox({
    super.key,
    this.containerKey,
    this.id = 0,
    this.x = 0,
    this.y = 0,
    this.width = 0,
    this.height = 0,
    this.backgroundColor = Colors.transparent,
    this.text = '',
    this.textStyle = const TextStyle(fontSize: 18),
    this.opacity = 1.0, // Giá trị mặc định là 1 (hiển thị hoàn toàn)
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: x,
      top: y,
      duration: Duration(milliseconds: 100),
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: containerKey,
          width: width > 0 ? width : null,
          height: height > 0 ? height : null,
          color: backgroundColor,
          padding: const EdgeInsets.only(left: 20, right: 50),
          child: Text(
            text,
            style: textStyle,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}
