import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/draggable_word.dart';
import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/helper.dart';
import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/sentence_completion_game_3.dart';

enum DragDirection {
  none,
  left,
  right,
  up,
  down,
  upLeft,
  upRight,
  downLeft,
  downRight,
}

class DragObjectState {
  int id; // Thêm id
  int index;
  int row;
  int col;
  double x;
  double y;
  DragDirection dragDirection;
  bool isDragging;
  double width;
  bool display;
  double height;
  Color color;
  String text;

  DragObjectState({
    required this.id, // Thêm vào constructor
    required this.index,
    required this.x,
    required this.y,
    this.dragDirection = DragDirection.none,
    this.row = -1,
    this.col = -1,
    this.isDragging = false,
    this.width = 0,
    required this.display,
    required this.height,
    required this.color,
    required this.text,
  });
}

class DuolingoSentenceSortScreen extends StatefulWidget {
  const DuolingoSentenceSortScreen({super.key});

  @override
  State<DuolingoSentenceSortScreen> createState() =>
      _DuolingoSentenceSortScreenState();
}

class _DuolingoSentenceSortScreenState
    extends State<DuolingoSentenceSortScreen> {
  final GlobalKey _containerKey = GlobalKey();
  final double blockHeight = 54;
  final double blockSpacing = 12;
  final double listTop = 100;
  final double listLeft = 16;
  final double dragOutThreshold = 200; // y > threshold => ra khỏi list
  DragDirection dragDirection = DragDirection.none;
  Offset? startPosition;

  bool _isPositionBlock = false;

  static final List<String> words = [
    'Flutter',
    'makes',
    'building',
    'beautiful',
    'apps',
    'really',
    'fast',
    'and',
    'fun',
    '.',
  ];

  static final List<Color> colors = [
    Colors.blue,
    Colors.indigo,
    Colors.teal,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.red,
    Colors.cyan,
    Colors.brown,
    Colors.grey,
  ];

  late List<DragObjectState> blocks;
  List<DragObjectState> hiddenBlocks = [];

  DragObjectState touchedObjectState = DragObjectState(
    id: -1,
    index: -1,
    row: -1,
    col: -1,
    x: 0,
    y: 0,
    dragDirection: DragDirection.none,
    isDragging: true,
    width: 100,
    display: false,
    height: 54,
    color: const Color.fromARGB(0, 9, 0, 0),
    text: 'Dragged',
  );

  // ignore: avoid_init_to_null
  DragObjectState draggedObjectState = DragObjectState(
    id: -1,
    index: -1,
    row: -1,
    col: -1,
    x: 0,
    y: 0,
    dragDirection: DragDirection.none,
    isDragging: true,
    width: 100,
    display: false,
    height: 54,
    color: const Color.fromARGB(0, 9, 0, 0),
    text: 'Dragged',
  );
  // ignore: avoid_init_to_null
  DragObjectState overlappedObject = DragObjectState(
    id: -1,
    index: -1,
    row: -1,
    col: -1,
    x: 0,
    y: 0,
    dragDirection: DragDirection.none,
    isDragging: false,
    width: 0,
    display: false,
    height: 54,
    color: Colors.transparent,
    text: '',
  );

  List<DragObjectState> beforeObjects = [];
  List<DragObjectState> afterObjects = [];

  Offset lastFingerPosition = Offset(-1, -1);

  /* 
    process steps:
    1, get overlapped object
    2, collect objects
    3, update position
   */

  Map<String, bool> steps = {"get": true, "collect": true, "update": true};

  int loops = 5;

  // Thêm vào các biến instance của class
  int lastOverlappedObjectId = -1;
  Stopwatch debounceTimer = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    blocks = [];
  }

  void _setDefaultDraggedObject() {
    draggedObjectState = DragObjectState(
      id: -1,
      index: -1,
      row: -1,
      col: -1,
      x: 0,
      y: 0,
      dragDirection: DragDirection.none,
      isDragging: false,
      width: 0,
      display: false,
      height: 54,
      color: Colors.transparent,
      text: '',
    );
  }

  void _printContainerOffset() {
    final RenderBox? box =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final Offset topLeft = box.localToGlobal(Offset.zero);
    }
  }

  void _postionBlocks() {
    blocks = [];
    double total = 0;
    double height = 0;
    int curRow = 0;
    int curCol = 0;
    final screenWidth = MediaQuery.of(context).size.width;

    for (int i = 0; i < words.length; i++) {
      final obj = DragObjectState(
        id: i,
        index: i,
        col: curCol,
        x: total,
        y: height,
        dragDirection: DragDirection.none,
        display: true,
        height: 54,
        color: colors[i % colors.length],
        text: words[i],
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: obj.text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      obj.width = textPainter.width + 32;

      if (total + obj.width > screenWidth) {
        debugPrint("[remaining space] ${screenWidth - total}");

        final hiddenBlock = DragObjectState(
          id: -999,
          index: -999,
          col: curCol,
          x: total,
          y: height,
          dragDirection: DragDirection.none,
          display: true, // Đảm bảo là true
          width: screenWidth - total,
          height: 54,
          color: Colors.red.withOpacity(0.3), // Đổi màu cho dễ nhìn
          text: "hidden",
        );

        hiddenBlocks.add(hiddenBlock);

        total = 0;
        height += 54;
        curRow += 1;
        curCol = 0;
        obj.x = total;
        obj.y = height;
        obj.row = curRow;
        obj.col = curCol;
      }

      blocks.add(obj);

      total += obj.width;
      curCol += 1;
    }

    final hiddenBlock = DragObjectState(
      id: -999,
      index: -999,
      col: curCol,
      row: curRow,
      x: total,
      y: height,
      dragDirection: DragDirection.none,
      display: true, // Đảm bảo là true
      width: screenWidth - total,
      height: 54,
      color: Colors.red.withOpacity(0.3), // Đổi màu cho dễ nhìn
      text: "hidden",
    );

    hiddenBlocks.add(hiddenBlock);

    blocks.add(
      DragObjectState(
        id: blocks.length,
        index: blocks.length,
        row: curRow + 1,
        col: 0,
        x: 0,
        y: height + 54,
        dragDirection: DragDirection.none,
        display: true,
        width: screenWidth,
        height: 54,
        color: Colors.black,
        text: "last",
      ),
    );
  }

  DragDirection _getDragDirection({
    required Offset prevPosition,
    required Offset curPosition,
  }) {
    double deltaX = curPosition.dx - prevPosition.dx;
    double deltaY = curPosition.dy - prevPosition.dy;

    const double threshold = 0;

    if (deltaX > threshold && deltaY > threshold) {
      return DragDirection.downRight;
    } else if (deltaX < -threshold && deltaY > threshold) {
      return DragDirection.downLeft;
    } else if (deltaX > threshold && deltaY < -threshold) {
      return DragDirection.upRight;
    } else if (deltaX < -threshold && deltaY < -threshold) {
      return DragDirection.upLeft;
    } else if (deltaX > threshold) {
      return DragDirection.right;
    } else if (deltaX < -threshold) {
      return DragDirection.left;
    } else if (deltaY > threshold) {
      return DragDirection.down;
    } else if (deltaY < -threshold) {
      return DragDirection.up;
    }
    return DragDirection.none;
  }

  List<DragObjectState> _reorderBlocks({
    required List<DragObjectState> result,
    required DragObjectState draggedObject,
  }) {
    debugPrint(
      "[Before Current Blocks State]: ${blocks.map((block) => [block.index, block.id]).toList()}",
    );
    debugPrint(
      "[Before Reorder Blocks State]: ${result.map((block) => [block.index, block.id]).toList()}",
    );

    // before return update indexes
    for (int i = 0; i < result.length; i++) {
      result[i].index = i;

      if (result[i].id == draggedObject.id) {
        draggedObject.index = i;
      }

      blocks[i] = result[i];
    }

    debugPrint(
      "[dragged object]: [${draggedObject.index}, ${draggedObject.id}]",
    );

    debugPrint(
      "[After Reorder Blocks State]: ${result.map((block) => [block.index, block.id]).toList()}",
    );

    return result;
  }

  bool _isSpecialItem(DragObjectState block) {
    return block.text == "last";
  }

  List<DragObjectState> _collectBlocks({
    required DragObjectState overlappedObject,
    required DragObjectState draggedObject,
    required DragDirection dragDirection,
  }) {
    if (draggedObject.index == overlappedObject.index) {
      return [...blocks];
    }

    debugPrint(
      "Dragged object index: ${draggedObject.index}, text: '${draggedObject.text}'",
    );
    debugPrint(
      "Overlapped object index: ${overlappedObject.index}, text: '${overlappedObject.text}'",
    );
    debugPrint(
      "[Current State]: ${blocks.map((block) => [block.index, block.id]).toList()}",
    );

    DragObjectState? specialItem;
    List<DragObjectState> normalBlocks = [];

    for (final block in blocks) {
      if (block.text == "last") {
        specialItem = block;
      } else {
        normalBlocks.add(block);
      }
    }

    beforeObjects.clear();
    afterObjects.clear();

    List<DragObjectState> p1 = [];
    List<DragObjectState> p2 = [];
    List<DragObjectState> p3 = [];
    List<DragObjectState> p4 = [];
    List<DragObjectState> p5 = [];

    // Tách block ẩn cuối ra khỏi blocks (nếu có)

    if (overlappedObject.text == "last") {
      // only have 3 parts
      p1 = normalBlocks.sublist(0, draggedObject.index);
      p2 = normalBlocks.sublist(draggedObject.index, draggedObject.index + 1);
      p3 = normalBlocks.sublist(draggedObject.index + 1);

      beforeObjects.addAll([...p1, ...p3]);
      afterObjects.addAll([...p2]);

      if (specialItem != null) {
        afterObjects.add(specialItem);
      }
    } else if (overlappedObject.text != "last") {
      double screenWidth = MediaQuery.of(context).size.width;
      double empty = screenWidth;

      // if not including special item (the last one)
      if (draggedObject.index < overlappedObject.index) {
        p1 = normalBlocks.sublist(0, draggedObject.index);
        debugPrint("[p1]: ${p1.map((block) => block.text)}");
        p2 = normalBlocks.sublist(draggedObject.index, draggedObject.index + 1);
        debugPrint("[p2]: ${p2.map((block) => block.text)}");
        p3 = normalBlocks.sublist(
          draggedObject.index + 1,
          overlappedObject.index,
        );
        debugPrint("[p3]: ${p3.map((block) => block.text)}");
        p4 = normalBlocks.sublist(
          overlappedObject.index,
          overlappedObject.index + 1,
        );
        debugPrint("[p4]: ${p4.map((block) => block.text)}");
        p5 = normalBlocks.sublist(overlappedObject.index + 1);
        debugPrint("[p5]: ${p5.map((block) => block.text)}");

        // Kéo từ trái sang phải
        // Tính toán không gian còn lại trên dòng hiện tại
        double curX = 0;
        for (int i = 0; i < overlappedObject.index; i++) {
          if (i == draggedObject.index) continue; // Bỏ qua khối được kéo

          if (screenWidth - curX < blocks[i].width) {
            curX = 0; // Xuống dòng mới
          }
          curX += blocks[i].width;
        }
        empty = screenWidth - curX;

        if (empty >= p4.first.width) {
          // Nếu đủ không gian để đặt overlappedObject vào dòng hiện tại
          beforeObjects.addAll([...p1, ...p3, ...p4]);
          afterObjects.addAll([...p2, ...p5]);
        } else {
          // Nếu không đủ không gian, đặt overlappedObject vào dòng mới
          beforeObjects.addAll([...p1, ...p3]);
          afterObjects.addAll([...p4, ...p2, ...p5]);
        }
      } else if (draggedObject.index > overlappedObject.index) {
        p1 = blocks.sublist(0, overlappedObject.index);
        debugPrint("[p1]: ${p1.map((block) => block.text)}");

        p2 = blocks.sublist(overlappedObject.index, overlappedObject.index + 1);
        debugPrint("[p2]: ${p2.map((block) => block.text)}");

        p3 = blocks.sublist(overlappedObject.index + 1, draggedObject.index);
        debugPrint("[p3]: ${p3.map((block) => block.text)}");

        p4 = blocks.sublist(draggedObject.index, draggedObject.index + 1);
        debugPrint("[p4]: ${p4.map((block) => block.text)}");

        p5 = blocks.sublist(draggedObject.index + 1);
        debugPrint("[p5]: ${p5.map((block) => block.text)}");

        double curX = 0;
        for (int i = 0; i < p1.length; i++) {
          if (screenWidth - curX < p1[i].width) {
            curX = 0; // Xuống dòng mới
          }
          curX += p1[i].width;
        }
        empty = screenWidth - curX;

        if (empty >= p2.first.width) {
          // Nếu đủ không gian để đặt draggedObject trước overlappedObject
          beforeObjects.addAll([...p1, ...p4, ...p2, ...p3]);
          afterObjects.addAll([...p5]);
        } else {
          // Nếu không đủ không gian, đặt p4 vào vị trí đầu của hàng tiếp theo
          beforeObjects.addAll([...p1]);
          afterObjects.addAll([...p4, ...p2, ...p3, ...p5]);
        }
      }
    }

    debugPrint(
      "[objects]: ${[...beforeObjects, ...afterObjects].map((block) => block.text)}",
    );

    List<DragObjectState> result = [...beforeObjects, ...afterObjects];

    return result;
  }

  List<DragObjectState> _updateBlocksPosition({
    required DragObjectState draggedObj,
    required List<DragObjectState> reorderBlocks,
  }) {
    // Tách item đặc biệt nếu có
    DragObjectState? specialItem;
    List<DragObjectState> normalBlocks = [];

    for (final block in reorderBlocks) {
      if (block.text == "last") {
        specialItem = block;
      } else {
        normalBlocks.add(block);
      }
    }

    List<DragObjectState> newBlocksState = [];
    double screenWidth = MediaQuery.of(context).size.width;
    double curX = 0;
    double curY = 0;
    int curRow = 0;
    int curCol = 0;

    // Xử lý các block thông thường
    for (int i = 0; i < normalBlocks.length; i++) {
      final block = normalBlocks[i];
      block.index = i;

      // Nếu không đủ không gian, xuống dòng mới
      if (screenWidth - curX < block.width) {
        curX = 0;
        curY += block.height;
        curRow += 1;
        curCol = 0;
      }

      block.x = curX;
      block.y = curY;
      block.row = curRow;
      block.col = curCol;

      curX += block.width;
      curCol += 1;

      newBlocksState.add(block);
    }

    // Xử lý item đặc biệt cuối cùng
    if (specialItem != null) {
      // Cập nhật vị trí cho item đặc biệt
      specialItem.index = newBlocksState.length;
      specialItem.row = curRow + 1;
      specialItem.col = 0;
      specialItem.x = 0;
      specialItem.y = curY + blockHeight; // Đảm bảo item cuối nằm ở dòng mới
      newBlocksState.add(specialItem);
    }

    // Cập nhật thông tin cho draggedObj
    // (giữ nguyên code hiện tại)...

    return newBlocksState;
  }

  void _updateHiddenBlocksWidths(List<DragObjectState> blocksList) {
    debugPrint("===== UPDATING HIDDEN BLOCKS WIDTHS =====");
    double screenWidth = MediaQuery.of(context).size.width;

    // Tạo map chứa thông tin của các block theo row
    Map<int, List<DragObjectState>> blocksByRow = {};
    for (final block in blocksList) {
      if (block.id == -999) continue; // Bỏ qua hidden blocks

      if (!blocksByRow.containsKey(block.row)) {
        blocksByRow[block.row] = [];
      }
      blocksByRow[block.row]!.add(block);
    }

    // Tính khoảng trống cuối mỗi dòng và cập nhật hidden blocks
    hiddenBlocks.clear(); // Reset hidden blocks

    blocksByRow.forEach((row, rowBlocks) {
      // Sắp xếp blocks theo col để tìm block cuối cùng của dòng
      rowBlocks.sort((a, b) => a.col.compareTo(b.col));

      // Tính tổng width của các blocks trong dòng
      double rowWidth = 0;
      for (final block in rowBlocks) {
        rowWidth += block.width;
      }

      // Tính khoảng trống còn lại
      double remainingSpace = screenWidth - rowWidth;

      if (remainingSpace > 0) {
        // Tạo hidden block mới cho khoảng trống này
        final lastBlock = rowBlocks.last;
        final hiddenBlock = DragObjectState(
          id: -999,
          index: -999,
          row: row,
          col: lastBlock.col + 1,
          x: lastBlock.x + lastBlock.width,
          y: lastBlock.y,
          dragDirection: DragDirection.none,
          display: true, // Để debug, sau này có thể đổi thành false
          width: remainingSpace,
          height: 54,
          color: Colors.red.withOpacity(0.3),
          text: "hidden",
        );

        hiddenBlocks.add(hiddenBlock);
        debugPrint("Added hidden block at row $row with width $remainingSpace");
      }
    });

    debugPrint("===== HIDDEN BLOCKS UPDATED =====");
  }

  void _handleVisibleBlocks() {
    if (steps.values.every((v) => v)) {
      // ...get overlapped object...
      DragObjectState? localOverlappedObject = getOverlappedObjectByDirection(
        dragged: draggedObjectState,
        blocks: blocks,
        dragDirection: dragDirection,
      );

      if (localOverlappedObject == null) {
        lastOverlappedObjectId = -1; // Reset ID khi không còn va chạm
        return;
      }

      // Kiểm tra nếu đây là cùng một object như lần trước và thời gian chưa đủ, bỏ qua
      if (localOverlappedObject.id == lastOverlappedObjectId &&
          debounceTimer.elapsedMilliseconds < 200) {
        return;
      }

      // Ghi nhớ object bị va chạm hiện tại và reset timer
      lastOverlappedObjectId = localOverlappedObject.id;
      debounceTimer.reset();

      // Đánh dấu đang xử lý
      steps["get"] = false;
      steps["collect"] = false;
      steps["update"] = false;

      // Xử lý va chạm như trước
      try {
        // ...collect blocks...
        List<DragObjectState> localBlocks = _collectBlocks(
          overlappedObject: localOverlappedObject,
          draggedObject: draggedObjectState,
          dragDirection: dragDirection,
        );
        steps["collect"] = true;

        // ...reorder blocks...
        List<DragObjectState> reorderedBlocks = _reorderBlocks(
          result: localBlocks,
          draggedObject: draggedObjectState,
        );

        // ...update positions...
        List<DragObjectState> newBlocksState = _updateBlocksPosition(
          draggedObj: draggedObjectState,
          reorderBlocks: reorderedBlocks,
        );

        _updateHiddenBlocksWidths(blocks);
      } catch (e) {
        debugPrint("Error handling hidden blocks: $e");
      }

      // Đánh dấu hoàn thành để lần sau xử lý lại
      steps["get"] = true;
      steps["collect"] = true;
      steps["update"] = true;
    }
  }

  void _handleHiddenBlocks() {
    if (steps.values.every((v) => v)) {
      // Tìm object bị va chạm
      DragObjectState? hiddenOverlappedObject = getOverlappedObjectByPercentage(
        draggedObjectState,
        hiddenBlocks,
      );

      // Nếu không có va chạm hoặc đang kéo quá nhanh, bỏ qua
      if (hiddenOverlappedObject == null) {
        lastOverlappedObjectId = -1; // Reset lại ID khi không còn va chạm
        return;
      }

      // Kiểm tra nếu đây là cùng một object như lần trước và thời gian chưa đủ, bỏ qua
      if (hiddenOverlappedObject.id == lastOverlappedObjectId &&
          debounceTimer.elapsedMilliseconds < 200) {
        return;
      }

      // Ghi nhớ object bị va chạm hiện tại và reset timer
      lastOverlappedObjectId = hiddenOverlappedObject.id;
      debounceTimer.reset();

      // Đánh dấu đang xử lý
      steps["get"] = false;
      steps["collect"] = false;
      steps["update"] = false;

      // Xử lý va chạm như trước
      try {
        final expectedBlock = blocks.firstWhere(
          (block) => block.row == hiddenOverlappedObject.row + 1,
        );

        // ...collect blocks...
        List<DragObjectState> localBlocks = _collectBlocks(
          overlappedObject: expectedBlock,
          draggedObject: draggedObjectState,
          dragDirection: dragDirection,
        );
        steps["collect"] = true;

        // ...reorder blocks...
        List<DragObjectState> reorderedBlocks = _reorderBlocks(
          result: localBlocks,
          draggedObject: draggedObjectState,
        );

        // ...update positions...
        List<DragObjectState> newBlocksState = _updateBlocksPosition(
          draggedObj: draggedObjectState,
          reorderBlocks: reorderedBlocks,
        );

        _updateHiddenBlocksWidths(blocks);
      } catch (e) {
        debugPrint("Error handling hidden blocks: $e");
      }

      // Đánh dấu hoàn thành để lần sau xử lý lại
      steps["get"] = true;
      steps["collect"] = true;
      steps["update"] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _printContainerOffset(),
    );

    if (!_isPositionBlock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // _calculateObjectWidths(context);
        _postionBlocks();
        setState(() {
          _isPositionBlock = true;
        });
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Word Blocks')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          setState(() {
            // debugPrint(
            //   "Finger position (global): ${details.globalPosition.dx}, ${details.globalPosition.dy}",
            // );

            final RenderBox? box =
                _containerKey.currentContext?.findRenderObject() as RenderBox?;
            final Offset containerOffset =
                box?.localToGlobal(Offset.zero) ?? Offset.zero;
            final double statusBarHeight = MediaQuery.of(context).padding.top;
            final double appBarHeight = kToolbarHeight;

            double touchX = details.globalPosition.dx;
            double touchY =
                details.globalPosition.dy - statusBarHeight - appBarHeight;

            draggedObjectState.x = touchX - draggedObjectState.width / 2;
            draggedObjectState.y = touchY - draggedObjectState.height / 2;

            // find the overlapped object by using the position of draggedObject.x, y
            double centerDX =
                draggedObjectState.x + draggedObjectState.width / 2;
            double centerDY =
                draggedObjectState.y + draggedObjectState.height / 2;

            lastFingerPosition = Offset(centerDX, centerDY);

            // get the first touched object
            // debugPrint("On touch position: ${centerDX}, ${centerDY}");

            DragObjectState? touchObject = getOverlappedObjectByTouch(
              centerDX,
              centerDY,
              blocks,
            );

            // debugPrint("On touch object: ${touchObject == null}");

            if (touchObject != null && touchObject.text != "last") {
              //   debugPrint("On touch object: ${touchObject.text}");

              touchObject.display = false;

              draggedObjectState.id = touchObject.id;
              draggedObjectState.index = touchObject.index;
              draggedObjectState.row = touchObject.row;
              draggedObjectState.col = touchObject.col;
              draggedObjectState.x = touchObject.x;
              draggedObjectState.y = touchObject.y;
              draggedObjectState.width = touchObject.width;
              draggedObjectState.height = touchObject.height;
              draggedObjectState.color = touchObject.color;
              draggedObjectState.text = touchObject.text;
              //   draggedObject.display = true;
              //   draggedObject.isDragging = true;

              touchedObjectState = touchObject;
            }

            draggedObjectState.display = true;
            draggedObjectState.isDragging = true;

            // reset drag direction for the new touched object
            dragDirection = DragDirection.none;
          });
        },
        onPanUpdate: (details) async {
          setState(() {
            final RenderBox? box =
                _containerKey.currentContext?.findRenderObject() as RenderBox?;
            final Offset containerOffset =
                box?.localToGlobal(Offset.zero) ?? Offset.zero;
            final double statusBarHeight = MediaQuery.of(context).padding.top;
            final double appBarHeight = kToolbarHeight;

            double touchX = details.globalPosition.dx;
            double touchY =
                details.globalPosition.dy - statusBarHeight - appBarHeight;

            lastFingerPosition = Offset(
              draggedObjectState.x,
              draggedObjectState.y,
            );

            draggedObjectState.x = touchX - draggedObjectState.width / 2;
            draggedObjectState.y = touchY - draggedObjectState.height / 2;

            // debugPrint("[Drag Object Index]: ${draggedObjectState.index}");

            // debugPrint(
            //   "Finger position (global): ${details.globalPosition.dx}, ${details.globalPosition.dy + statusBarHeight + appBarHeight}",
            // );

            // when having the touched object set up then check its collisions
            // get drag direction

            // keep track of current center
            // before update the value save the prev state first

            Offset currentPosition = Offset(
              draggedObjectState.x,
              draggedObjectState.y,
            );

            // debugPrint("[Prev Position]: $lastFingerPosition");
            // debugPrint("[Curr Position]: $currentPosition");

            // handle visible blocks
            DragDirection localDragDirection = _getDragDirection(
              curPosition: currentPosition,
              prevPosition: lastFingerPosition,
            );

            dragDirection = localDragDirection;

            _handleHiddenBlocks();
            _handleVisibleBlocks();
          });
        },
        onPanEnd: (details) {
          setState(() {
            draggedObjectState.display = false;
            draggedObjectState.isDragging = false;

            touchedObjectState.display = true;
          });
        },
        child: SizedBox.expand(
          child: Stack(
            key: _containerKey,
            children: [
              for (final block in blocks) _buildObject(block),

              for (final hiddenBlock in hiddenBlocks) _buildObject(hiddenBlock),

              DraggableObject(
                x: draggedObjectState.x,
                y: draggedObjectState.y,
                row: draggedObjectState.row,
                isDragging: draggedObjectState.isDragging,
                width: draggedObjectState.width,
                height: draggedObjectState.height,
                color: draggedObjectState.color,
                label: draggedObjectState.text,
                display: draggedObjectState.display,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObject(DragObjectState obj) {
    // Thêm biến lưu vị trí ban đầu
    return DraggableObject(
      x: obj.x,
      y: obj.y,
      isDragging: obj.isDragging,
      width: obj.width,
      height: obj.height,
      color: obj.color,
      label: obj.text,
      display: obj.display,
    );
  }
}
