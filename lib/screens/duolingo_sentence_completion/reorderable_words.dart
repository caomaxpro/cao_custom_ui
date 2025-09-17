import 'package:flutter/material.dart';
import 'package:reorderable_staggered_scroll_view/reorderable_staggered_scroll_view.dart';

// Định nghĩa DragObjectState cho mỗi khối
class DragObjectState {
  final int id;
  final String text;
  final Color color;
  final double width;
  final double height;

  DragObjectState({
    required this.id,
    required this.text,
    required this.color,
    required this.width,
    required this.height,
  });
}

class ReorderableWordsScreen extends StatefulWidget {
  const ReorderableWordsScreen({super.key});

  @override
  State<ReorderableWordsScreen> createState() => _ReorderableWordsScreenState();
}

class _ReorderableWordsScreenState extends State<ReorderableWordsScreen> {
  List<DragObjectState> blocks = [
    DragObjectState(
      id: 0,
      text: "Flutter",
      color: Colors.blue,
      width: 120,
      height: 54,
    ),
    DragObjectState(
      id: 1,
      text: "drag",
      color: Colors.green,
      width: 80,
      height: 54,
    ),
    DragObjectState(
      id: 2,
      text: "drop",
      color: Colors.orange,
      width: 90,
      height: 54,
    ),
    DragObjectState(
      id: 3,
      text: "variable",
      color: Colors.purple,
      width: 130,
      height: 54,
    ),
    DragObjectState(
      id: 4,
      text: "size",
      color: Colors.red,
      width: 70,
      height: 54,
    ),
    DragObjectState(
      id: 5,
      text: "grid",
      color: Colors.teal,
      width: 80,
      height: 54,
    ),
    DragObjectState(
      id: 6,
      text: "custom",
      color: Colors.indigo,
      width: 110,
      height: 54,
    ),
    DragObjectState(
      id: 7,
      text: "reorder",
      color: Colors.cyan,
      width: 120,
      height: 54,
    ),
    DragObjectState(
      id: 8,
      text: "staggered",
      color: Colors.amber,
      width: 140,
      height: 54,
    ),
    DragObjectState(
      id: 9,
      text: "scroll",
      color: Colors.lime,
      width: 100,
      height: 54,
    ),
    DragObjectState(
      id: 10,
      text: "view",
      color: Colors.pink,
      width: 80,
      height: 54,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reorderable Words")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ReorderableStaggeredScrollView.grid(
          crossAxisCount: 6,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          isLongPressDraggable: false, // Kéo thả bằng tap thường
          // Các callbacks
          onAccept: (item1, item2, value) {
            debugPrint('onAccept: item1 $item1 item2 $item2 value $value');
            // item1: widget bị kéo, item2: widget đích, value: giá trị kéo thả

            // Lấy index từ item1 và item2
            final oldIndex = blocks.indexWhere(
              (block) => ValueKey(block.id).toString() == item1?.key.toString(),
            );
            final newIndex = blocks.indexWhere(
              (block) => ValueKey(block.id).toString() == item2.key.toString(),
            );

            if (oldIndex >= 0 && newIndex >= 0) {
              setState(() {
                final block = blocks.removeAt(oldIndex);
                blocks.insert(newIndex, block);
              });
            }
          },
          onDragEnd: (details, item) {
            debugPrint('onDragEnd: $details ${item.key}');
            // Có thể thêm hiệu ứng hoặc âm thanh khi kéo thả hoàn tất
          },
          onMove: (item, item2, value) {
            debugPrint('onMove: item $item item2 $item2 value $value');
            // Xử lý logic khi di chuyển (nếu cần)
          },
          onDragUpdate: (details, item) {
            debugPrint('onDragUpdate: details $details item $item');
            // Xử lý logic khi đang kéo (nếu cần)
          },

          // Có thể thêm danh sách các item không kéo được
          isNotDragList: [
            // Ví dụ: thêm khối cố định không kéo được
            // ReorderableStaggeredScrollViewGridCountItem(...)
          ],

          children: [
            for (final block in blocks)
              ReorderableStaggeredScrollViewGridCountItem(
                key: ValueKey(block.id),
                mainAxisCellCount: 1,
                crossAxisCellCount: _calculateCellCount(block.width),
                widget: Card(
                  color: block.color,
                  child: SizedBox(
                    height: block.height,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          block.text,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Hàm tính toán số cột cần thiết cho mỗi block dựa trên chiều rộng
  int _calculateCellCount(double width) {
    // Giả sử mỗi cột có chiều rộng 40
    final cellWidth = 40.0;
    // Làm tròn lên để đảm bảo đủ chỗ
    return (width / cellWidth).ceil();
  }
}
