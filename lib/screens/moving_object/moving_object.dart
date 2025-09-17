import 'package:flutter/material.dart';
import 'dart:math' as math;

class MovingObjectScreen extends StatefulWidget {
  const MovingObjectScreen({super.key});

  @override
  State<MovingObjectScreen> createState() => _MovingObjectScreenState();
}

class _MovingObjectScreenState extends State<MovingObjectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final double objectSize = 50;
  final int objectCount = 15; // Số lượng vật thể
  final List<FallingObject> fallingObjects = [];

  // Thêm biến để theo dõi object đang được kéo
  int? draggingIndex;
  Offset? dragOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60), // Thời gian dài để chạy animation
    );

    // Khởi tạo animation sau khi build đầu tiên để có kích thước màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final random = math.Random();

      // Tạo nhiều đối tượng rơi với vị trí và tốc độ khác nhau
      for (int i = 0; i < objectCount; i++) {
        // Tạo màu ngẫu nhiên từ danh sách các màu
        final colors = [
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.teal,
        ];
        final color = colors[random.nextInt(colors.length)];

        // Tạo kích thước ngẫu nhiên
        final size = objectSize * (0.7 + random.nextDouble() * 0.6);

        // Vị trí bắt đầu ngẫu nhiên
        final x = random.nextDouble() * screenWidth;
        final startY = -size - random.nextDouble() * screenHeight * 0.5;

        // Tốc độ rơi ngẫu nhiên (thời gian để rơi qua màn hình)
        final duration = Duration(
          seconds: 5 + random.nextInt(10),
          milliseconds: random.nextInt(1000),
        );

        // Animation từ vị trí bắt đầu đến dưới màn hình
        final animation = Tween<double>(
          begin: startY,
          end: screenHeight + size,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

        // Thêm vào danh sách các đối tượng rơi
        fallingObjects.add(
          FallingObject(
            x: x,
            animation: animation,
            size: size,
            color: color,
            rotationSpeed:
                (random.nextDouble() - 0.5) * 0.2, // Tốc độ quay ngẫu nhiên
          ),
        );
      }

      // Bắt đầu animation và lặp lại vô hạn
      _controller.forward();
      _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Falling Objects')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Nếu chưa khởi tạo các đối tượng
          if (fallingObjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              for (int i = 0; i < fallingObjects.length; i++)
                // Wrap object trong GestureDetector
                Positioned(
                  left: draggingIndex == i && dragOffset != null
                      ? dragOffset!.dx - fallingObjects[i].size / 2
                      : fallingObjects[i].x - fallingObjects[i].size / 2,
                  top: draggingIndex == i && dragOffset != null
                      ? dragOffset!.dy - fallingObjects[i].size / 2
                      : fallingObjects[i].animation.value -
                            fallingObjects[i].size / 2,
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        // Khi bắt đầu kéo, lưu index của object và vị trí hiện tại
                        draggingIndex = i;
                        dragOffset = details.globalPosition;
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        // Cập nhật vị trí khi kéo
                        if (draggingIndex == i) {
                          dragOffset = details.globalPosition;
                        }
                      });
                    },
                    onPanEnd: (details) {
                      if (draggingIndex == i) {
                        // Lấy vị trí hiện tại của vật thể khi thả
                        final screenHeight = MediaQuery.of(context).size.height;

                        // Vị trí hiện tại từ dragOffset - chính xác hơn
                        final currentY =
                            dragOffset!.dy - fallingObjects[i].size / 2;

                        // Tạo animation mới từ vị trí thả đến dưới màn hình
                        final newAnimation =
                            Tween<double>(
                              begin: currentY,
                              end: screenHeight + fallingObjects[i].size,
                            ).animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Curves.linear,
                              ),
                            );

                        // Cập nhật vật thể với vị trí mới và animation mới
                        setState(() {
                          fallingObjects[i] = FallingObject(
                            x: dragOffset!.dx, // Lưu vị trí X chính xác
                            animation:
                                newAnimation, // Dùng animation mới từ vị trí thả
                            size: fallingObjects[i].size,
                            color: fallingObjects[i].color,
                            rotationSpeed: fallingObjects[i].rotationSpeed,
                          );

                          // Reset trạng thái khi kết thúc kéo
                          draggingIndex = null;
                          dragOffset = null;
                        });
                      }
                    },
                    child: Transform.rotate(
                      angle:
                          _controller.value *
                          math.pi *
                          2 *
                          fallingObjects[i].rotationSpeed,
                      child: _buildObject(
                        fallingObjects[i].size,
                        fallingObjects[i].color,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildObject(double size, Color color) {
    return Container(
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color, color.withOpacity(0.6)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.arrow_downward,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

// Lớp để lưu thông tin của một đối tượng rơi
class FallingObject {
  final double x;
  final Animation<double> animation;
  final double size;
  final Color color;
  final double rotationSpeed;

  FallingObject({
    required this.x,
    required this.animation,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });
}
