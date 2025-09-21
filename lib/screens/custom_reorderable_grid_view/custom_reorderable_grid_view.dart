import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/custom_reorderable_grid_view/draggable_grid.dart';
import 'package:mobile_custom_ui/screens/custom_reorderable_grid_view/helper.dart';

// Constants for app configuration
class AppConstants {
  static const double blockHeight = 54.0;
  static const double blockSpacing = 12.0;
  static const double listTop = 100.0;
  static const double listLeft = 16.0;
  static const double dragOutThreshold = 200.0;
  static const int debounceTime = 200;
  static const int visibleDebounceTime = 500;
}

// Enum for drag directions
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

// Model for block state
class DragObjectState {
  int id;
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
    required this.id,
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

  // Factory constructor for creating default/empty blocks
  factory DragObjectState.empty() {
    return DragObjectState(
      id: -1,
      index: -1,
      x: 0,
      y: 0,
      row: -1,
      col: -1,
      isDragging: false,
      width: 0,
      display: false,
      height: AppConstants.blockHeight,
      color: Colors.transparent,
      text: '',
    );
  }

  // Factory for creating hidden blocks
  factory DragObjectState.hidden({
    required int row,
    required int col,
    required double x,
    required double y,
    required double width,
  }) {
    return DragObjectState(
      id: -999,
      index: -999,
      row: row,
      col: col,
      x: x,
      y: y,
      display: true,
      width: width,
      height: AppConstants.blockHeight,
      color: Colors.transparent,
      text: "",
    );
  }
}

// Session model for drag operations
class DragSession {
  DragObjectState draggedObject;
  DragObjectState touchedObject;
  DragDirection dragDirection;
  Offset lastFingerPosition;
  int lastOverlappedObjectId;
  Stopwatch debounceTimer;

  DragSession()
    : draggedObject = DragObjectState.empty(),
      touchedObject = DragObjectState.empty(),
      dragDirection = DragDirection.none,
      lastFingerPosition = Offset.zero,
      lastOverlappedObjectId = -1,
      debounceTimer = Stopwatch()..start();
}

class CustomReorderableGridView extends StatefulWidget {
  const CustomReorderableGridView({super.key});

  @override
  State<CustomReorderableGridView> createState() =>
      _CustomReorderableGridViewState();
}

class _CustomReorderableGridViewState extends State<CustomReorderableGridView> {
  final GlobalKey _containerKey = GlobalKey();

  // Content data
  static const List<String> words = [
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

  static const List<Color> colors = [
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

  // State variables
  late List<DragObjectState> blocks = [];
  List<DragObjectState> hiddenBlocks = [];
  bool _isPositionBlock = false;

  // Drag session
  late DragSession session;

  // Process tracking
  Map<String, bool> steps = {"get": true, "collect": true, "update": true};

  // Collision tracking
  CollisionResult? prevCollisionResult;
  List<DragObjectState> beforeObjects = [];
  List<DragObjectState> afterObjects = [];

  @override
  void initState() {
    super.initState();
    session = DragSession();
    prevCollisionResult = null;
  }

  // Calculate and position blocks initially
  void _positionBlocks() {
    blocks = [];
    hiddenBlocks = [];
    double total = 0;
    double height = 0;
    int curRow = 0;
    int curCol = 0;
    final screenWidth = MediaQuery.of(context).size.width;

    // Create blocks from words list
    for (int i = 0; i < words.length; i++) {
      final obj = DragObjectState(
        id: i,
        index: i,
        col: curCol,
        x: total,
        y: height,
        display: true,
        height: AppConstants.blockHeight,
        color: colors[i % colors.length],
        text: words[i],
      );

      // Calculate width based on text content
      obj.width = _calculateTextWidth(obj.text) + 32;

      // Check if we need to move to next row
      if (total + obj.width > screenWidth) {
        // Add hidden block at the end of current row
        _addHiddenBlockToRow(curRow, total, height, screenWidth - total);

        // Reset for new row
        total = 0;
        height += AppConstants.blockHeight;
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

    // Add hidden block after the last word
    _addHiddenBlockToRow(curRow, total, height, screenWidth - total);

    // Add "last" block at the end
    blocks.add(
      DragObjectState(
        id: blocks.length,
        index: blocks.length,
        row: curRow + 1,
        col: 0,
        x: 0,
        y: height + AppConstants.blockHeight,
        display: false,
        width: screenWidth,
        height: AppConstants.blockHeight,
        color: Colors.black,
        text: "last",
      ),
    );
  }

  // Helper to add hidden blocks
  void _addHiddenBlockToRow(int row, double x, double y, double width) {
    if (width <= 0) return;

    hiddenBlocks.add(
      DragObjectState.hidden(
        row: row,
        col: blocks.length,
        x: x,
        y: y,
        width: width,
      ),
    );
  }

  // Calculate text width efficiently
  double _calculateTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }

  /// Returns the drag direction based on previous and current finger positions.
  DragDirection _getDragDirection({
    required Offset prevPosition,
    required Offset curPosition,
  }) {
    double deltaX = curPosition.dx - prevPosition.dx;
    double deltaY = curPosition.dy - prevPosition.dy;

    const double threshold = 0;

    // Check diagonal directions first
    if (deltaX > threshold && deltaY > threshold) {
      return DragDirection.downRight;
    } else if (deltaX < -threshold && deltaY > threshold) {
      return DragDirection.downLeft;
    } else if (deltaX > threshold && deltaY < -threshold) {
      return DragDirection.upRight;
    } else if (deltaX < -threshold && deltaY < -threshold) {
      return DragDirection.upLeft;
    }
    // Then check cardinal directions
    else if (deltaX > threshold) {
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

  /// Updates indices after reordering blocks
  List<DragObjectState> _reorderBlocks({
    required List<DragObjectState> result,
    required DragObjectState draggedObject,
  }) {
    for (int i = 0; i < result.length; i++) {
      result[i].index = i;

      if (result[i].id == draggedObject.id) {
        draggedObject.index = i;
      }
    }

    return result;
  }

  /// Collects and reorders blocks based on drag operation
  List<DragObjectState> _collectBlocks({
    required DragObjectState overlappedObject,
    required DragObjectState draggedObject,
    required DragDirection dragDirection,
  }) {
    // If the dragged object is the same as the overlapped object, return the original list
    if (draggedObject.index == overlappedObject.index) {
      return blocks;
    }

    // Separate the special "last" block and normal blocks
    DragObjectState? specialItem;
    List<DragObjectState> normalBlocks = [];
    for (final block in blocks) {
      if (block.text == "last") {
        specialItem = block;
      } else {
        normalBlocks.add(block);
      }
    }
    // Sort normal blocks by their index
    normalBlocks.sort((a, b) => a.index.compareTo(b.index));

    beforeObjects.clear();
    afterObjects.clear();

    // Handle dragging to "last" block
    if (overlappedObject.text == "last") {
      _handleDragToLastBlock(draggedObject, normalBlocks, specialItem);
    } else {
      // Handle dragging between normal blocks
      _handleDragBetweenBlocks(draggedObject, overlappedObject, normalBlocks);
    }

    // Combine before and after objects to get the new order
    List<DragObjectState> result = [];
    result.addAll(beforeObjects);
    result.addAll(afterObjects);

    return result;
  }

  // Handle drag to "last" block
  void _handleDragToLastBlock(
    DragObjectState draggedObject,
    List<DragObjectState> normalBlocks,
    DragObjectState? specialItem,
  ) {
    final p1 = normalBlocks.sublist(0, draggedObject.index);
    final p2 = normalBlocks.sublist(
      draggedObject.index,
      draggedObject.index + 1,
    );
    final p3 = normalBlocks.sublist(draggedObject.index + 1);

    beforeObjects.addAll(p1);
    beforeObjects.addAll(p3);
    afterObjects.addAll(p2);

    if (specialItem != null) {
      afterObjects.add(specialItem);
    }
  }

  // Handle drag between normal blocks
  void _handleDragBetweenBlocks(
    DragObjectState draggedObject,
    DragObjectState overlappedObject,
    List<DragObjectState> normalBlocks,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (draggedObject.index < overlappedObject.index) {
      _handleDragLeftToRight(
        draggedObject,
        overlappedObject,
        normalBlocks,
        screenWidth,
      );
    } else if (draggedObject.index > overlappedObject.index) {
      _handleDragRightToLeft(
        draggedObject,
        overlappedObject,
        normalBlocks,
        screenWidth,
      );
    }
  }

  // Handle drag from left to right
  void _handleDragLeftToRight(
    DragObjectState draggedObject,
    DragObjectState overlappedObject,
    List<DragObjectState> normalBlocks,
    double screenWidth,
  ) {
    // Split into parts
    final p1 = normalBlocks.sublist(0, draggedObject.index);
    final p2 = normalBlocks.sublist(
      draggedObject.index,
      draggedObject.index + 1,
    );
    final p3 = normalBlocks.sublist(
      draggedObject.index + 1,
      overlappedObject.index,
    );
    final p4 = normalBlocks.sublist(
      overlappedObject.index,
      overlappedObject.index + 1,
    );
    final p5 = normalBlocks.sublist(overlappedObject.index + 1);

    // Calculate remaining space
    double empty = _calculateRemainingSpace(
      overlappedObject.index,
      draggedObject.index,
      screenWidth,
    );

    // Add parts based on available space
    if (empty >= p4.first.width) {
      beforeObjects.addAll(p1);
      beforeObjects.addAll(p3);
      beforeObjects.addAll(p4);
      afterObjects.addAll(p2);
      afterObjects.addAll(p5);
    } else {
      beforeObjects.addAll(p1);
      beforeObjects.addAll(p3);
      afterObjects.addAll(p4);
      afterObjects.addAll(p2);
      afterObjects.addAll(p5);
    }
  }

  // Handle drag from right to left
  void _handleDragRightToLeft(
    DragObjectState draggedObject,
    DragObjectState overlappedObject,
    List<DragObjectState> normalBlocks,
    double screenWidth,
  ) {
    // Split into parts
    final p1 = normalBlocks.sublist(0, overlappedObject.index);
    final p2 = normalBlocks.sublist(
      overlappedObject.index,
      overlappedObject.index + 1,
    );
    final p3 = normalBlocks.sublist(
      overlappedObject.index + 1,
      draggedObject.index,
    );
    final p4 = normalBlocks.sublist(
      draggedObject.index,
      draggedObject.index + 1,
    );
    final p5 = normalBlocks.sublist(draggedObject.index + 1);

    // Calculate remaining space
    double empty = _calculateRemainingSpaceForRow(p1, screenWidth);

    // Add parts based on available space
    if (empty >= p2.first.width) {
      beforeObjects.addAll(p1);
      beforeObjects.addAll(p4);
      beforeObjects.addAll(p2);
      beforeObjects.addAll(p3);
      afterObjects.addAll(p5);
    } else {
      beforeObjects.addAll(p1);
      afterObjects.addAll(p4);
      afterObjects.addAll(p2);
      afterObjects.addAll(p3);
      afterObjects.addAll(p5);
    }
  }

  // Calculate remaining space in current row
  double _calculateRemainingSpace(
    int endIndex,
    int skipIndex,
    double screenWidth,
  ) {
    double curX = 0;
    for (int i = 0; i < endIndex; i++) {
      if (i == skipIndex) continue; // Skip the dragged block
      if (screenWidth - curX < blocks[i].width) {
        curX = 0; // Move to next row
      }
      curX += blocks[i].width;
    }
    return screenWidth - curX;
  }

  // Calculate remaining space for row with blocks
  double _calculateRemainingSpaceForRow(
    List<DragObjectState> rowBlocks,
    double screenWidth,
  ) {
    double curX = 0;
    for (final block in rowBlocks) {
      if (screenWidth - curX < block.width) {
        curX = 0; // Move to next row
      }
      curX += block.width;
    }
    return screenWidth - curX;
  }

  // Update position of all blocks after reordering
  void _updateBlocksPosition({
    required DragObjectState draggedObj,
    required List<DragObjectState> reorderBlocks,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double curX = 0;
    double curY = 0;
    int curRow = 0;
    int curCol = 0;

    for (int i = 0; i < reorderBlocks.length; i++) {
      final block = reorderBlocks[i];
      block.index = i;

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
    }
  }

  // Update widths of hidden blocks based on current block layout
  void _updateHiddenBlocksWidths(List<DragObjectState> blocksList) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Group blocks by row
    Map<int, List<DragObjectState>> blocksByRow = {};
    for (final block in blocksList) {
      if (!blocksByRow.containsKey(block.row)) {
        blocksByRow[block.row] = [];
      }
      blocksByRow[block.row]!.add(block);
    }

    // Update each hidden block
    for (final hiddenBlock in hiddenBlocks) {
      final rowBlocks = blocksByRow[hiddenBlock.row] ?? [];
      if (rowBlocks.isEmpty) {
        hiddenBlock.display = false;
        continue;
      }

      rowBlocks.sort((a, b) => a.col.compareTo(b.col));

      double rowWidth = rowBlocks.fold(0.0, (sum, block) => sum + block.width);
      double remainingSpace = screenWidth - rowWidth;

      if (remainingSpace > 0) {
        final lastBlock = rowBlocks.last;
        hiddenBlock.width = remainingSpace;
        hiddenBlock.x = lastBlock.x + lastBlock.width;
        hiddenBlock.y = lastBlock.y;
        hiddenBlock.col = lastBlock.col + 1;
        hiddenBlock.display = true;
      } else {
        hiddenBlock.width = 0;
        hiddenBlock.display = false;
      }
    }
  }

  // Handle visible blocks collision and reordering
  void _handleVisibleBlocks() {
    if (!steps.values.every((v) => v)) return;

    // Find overlapped object
    final collisionResult = getOverlappedObjectByDirection(
      dragged: session.draggedObject,
      blocks: blocks,
      dragDirection: session.dragDirection,
    );
    final overlappedObject = collisionResult?.object;

    // Skip if collision hasn't changed
    if (prevCollisionResult != null &&
        collisionResult != null &&
        prevCollisionResult!.getCollisionPositionString() ==
            collisionResult.getCollisionPositionString()) {
      return;
    }

    // Update previous collision
    if (prevCollisionResult != null &&
        collisionResult != null &&
        prevCollisionResult!.getCollisionPositionString() !=
            collisionResult.getCollisionPositionString()) {
      prevCollisionResult = collisionResult;
    }

    // If no collision, reset and exit
    if (overlappedObject == null) {
      session.lastOverlappedObjectId = -1;
      return;
    }

    // Debounce repeated collisions
    if (overlappedObject.id == session.lastOverlappedObjectId &&
        session.debounceTimer.elapsedMilliseconds <
            AppConstants.visibleDebounceTime) {
      return;
    }

    // Update collision tracking
    session.lastOverlappedObjectId = overlappedObject.id;
    session.debounceTimer.reset();

    // Mark as processing
    steps.updateAll((key, value) => false);

    try {
      // Collect and reorder blocks
      final collectedBlocks = _collectBlocks(
        overlappedObject: overlappedObject,
        draggedObject: session.draggedObject,
        dragDirection: session.dragDirection,
      );
      steps["collect"] = true;

      // Reorder blocks
      final reorderedBlocks = _reorderBlocks(
        result: collectedBlocks,
        draggedObject: session.draggedObject,
      );

      // Update positions
      _updateBlocksPosition(
        draggedObj: session.draggedObject,
        reorderBlocks: reorderedBlocks,
      );

      // Update dragged object with new position
      final updatedDraggedBlock = blocks.firstWhere(
        (block) => block.id == session.draggedObject.id,
        orElse: () => session.draggedObject,
      );

      session.draggedObject.row = updatedDraggedBlock.row;
      session.draggedObject.col = updatedDraggedBlock.col;
      session.draggedObject.index = updatedDraggedBlock.index;
    } catch (e) {
      // Handle errors
    }

    // Mark as completed
    steps.updateAll((key, value) => true);
  }

  // Handle hidden blocks collision and reordering
  bool _handleHiddenBlocks() {
    if (!steps.values.every((v) => v)) return false;

    // Find overlapped hidden block
    DragObjectState? hiddenOverlappedObject = getOverlappedObjectByPercentage(
      session.draggedObject,
      hiddenBlocks,
    );

    // If no collision, reset and exit
    if (hiddenOverlappedObject == null) {
      session.lastOverlappedObjectId = -1;
      return false;
    }

    // Debounce repeated collisions
    if (hiddenOverlappedObject.id == session.lastOverlappedObjectId &&
        session.debounceTimer.elapsedMilliseconds < AppConstants.debounceTime) {
      return false;
    }

    // Update collision tracking
    session.lastOverlappedObjectId = hiddenOverlappedObject.id;
    session.debounceTimer.reset();

    // Mark as processing
    steps.updateAll((key, value) => false);

    try {
      // Sort blocks by index
      blocks.sort((a, b) => a.index.compareTo(b.index));

      // Find the first block in next row
      final expectedBlock = blocks.firstWhere(
        (block) => block.row == hiddenOverlappedObject.row + 1,
      );

      // Collect blocks
      List<DragObjectState> localBlocks = _collectBlocks(
        overlappedObject: expectedBlock,
        draggedObject: session.draggedObject,
        dragDirection: session.dragDirection,
      );

      steps["collect"] = true;

      // Reorder blocks
      List<DragObjectState> reorderedBlocks = _reorderBlocks(
        result: localBlocks,
        draggedObject: session.draggedObject,
      );

      // Update positions
      _updateBlocksPosition(
        draggedObj: session.draggedObject,
        reorderBlocks: reorderedBlocks,
      );
    } catch (e) {
      // Handle errors
    }

    // Mark as completed
    steps.updateAll((key, value) => true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize blocks if needed
    if (!_isPositionBlock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _positionBlocks();
        setState(() {
          _isPositionBlock = true;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Word Blocks')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) => _handlePanStart(details, context),
        onPanUpdate: (details) => _handlePanUpdate(details, context),
        onPanEnd: (details) => _handlePanEnd(),
        child: SizedBox.expand(
          child: Stack(
            key: _containerKey,
            children: [
              // Regular blocks
              ...blocks.map((block) => _buildObject(block)),

              // Hidden blocks
              ...hiddenBlocks.map((hiddenBlock) => _buildObject(hiddenBlock)),

              // Currently dragged block
              ActiveDraggableObject(
                x: session.draggedObject.x,
                y: session.draggedObject.y,
                isDragging: true,
                width: session.draggedObject.width,
                height: session.draggedObject.height,
                color: session.draggedObject.color,
                label: session.draggedObject.text,
                display: session.draggedObject.display,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle pan start event
  void _handlePanStart(DragStartDetails details, BuildContext context) {
    setState(() {
      // Calculate touch position
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final appBarHeight = kToolbarHeight;
      double touchX = details.globalPosition.dx;
      double touchY =
          details.globalPosition.dy - statusBarHeight - appBarHeight;

      // Set initial position
      session.draggedObject.x = touchX - session.draggedObject.width / 2;
      session.draggedObject.y = touchY - session.draggedObject.height / 2;

      // Find touch center
      double centerDX =
          session.draggedObject.x + session.draggedObject.width / 2;
      double centerDY =
          session.draggedObject.y + session.draggedObject.height / 2;
      session.lastFingerPosition = Offset(centerDX, centerDY);

      // Find touched object
      DragObjectState? touchObject = getOverlappedObjectByTouch(
        centerDX,
        centerDY,
        blocks,
      );

      // Setup dragged object based on touch
      if (touchObject != null && touchObject.text != "last") {
        final touchObjectColor = touchObject.color.withAlpha(80);
        touchObject.color = touchObjectColor;

        // Copy properties
        session.draggedObject = DragObjectState(
          id: touchObject.id,
          index: touchObject.index,
          row: touchObject.row,
          col: touchObject.col,
          x: touchObject.x,
          y: touchObject.y,
          width: touchObject.width,
          height: touchObject.height,
          display: true,
          color: touchObjectColor.withAlpha(255),
          text: touchObject.text,
          isDragging: true,
        );

        session.touchedObject = touchObject;
        session.dragDirection = DragDirection.none;
      }
    });
  }

  // Handle pan update event
  void _handlePanUpdate(DragUpdateDetails details, BuildContext context) {
    setState(() {
      // Calculate new position
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final appBarHeight = kToolbarHeight;
      double touchX = details.globalPosition.dx;
      double touchY =
          details.globalPosition.dy - statusBarHeight - appBarHeight;

      // Save previous position
      session.lastFingerPosition = Offset(
        session.draggedObject.x,
        session.draggedObject.y,
      );

      // Update position
      session.draggedObject.x = touchX - session.draggedObject.width / 2;
      session.draggedObject.y = touchY - session.draggedObject.height / 2;

      // Determine drag direction
      Offset currentPosition = Offset(
        session.draggedObject.x,
        session.draggedObject.y,
      );

      session.dragDirection = _getDragDirection(
        curPosition: currentPosition,
        prevPosition: session.lastFingerPosition,
      );

      // Handle collisions - first try hidden blocks, then visible blocks
      if (!_handleHiddenBlocks()) {
        _handleVisibleBlocks();
      }

      // Update hidden blocks widths
      _updateHiddenBlocksWidths(blocks);
    });
  }

  // Handle pan end event
  void _handlePanEnd() {
    setState(() {
      session.draggedObject.display = false;
      session.draggedObject.isDragging = false;
      session.touchedObject.display = true;
      session.touchedObject.isDragging = false;
      session.touchedObject.color = session.touchedObject.color.withAlpha(255);
    });
  }

  // Build a draggable object widget
  Widget _buildObject(DragObjectState obj) {
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
