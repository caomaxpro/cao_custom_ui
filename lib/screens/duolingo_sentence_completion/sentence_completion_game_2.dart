// import 'package:flutter/material.dart';
// import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/draggable_word.dart';
// import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/helper.dart';
// import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/sentence_completion_game_2.dart';

// enum DragDirection {
//   none,
//   left,
//   right,
//   up,
//   down,
//   upLeft,
//   upRight,
//   downLeft,
//   downRight,
// }

// class DragObjectState {
//   int id; // Thêm id
//   int index;
//   int row;
//   int col;
//   double x;
//   double y;
//   DragDirection dragDirection;
//   bool isDragging;
//   double width;
//   bool display;
//   double height;
//   Color color;
//   String text;

//   DragObjectState({
//     required this.id, // Thêm vào constructor
//     required this.index,
//     required this.x,
//     required this.y,
//     this.dragDirection = DragDirection.none,
//     this.row = -1,
//     this.col = -1,
//     this.isDragging = false,
//     this.width = 0,
//     required this.display,
//     required this.height,
//     required this.color,
//     required this.text,
//   });
// }

// class DuolingoSentenceSortScreen extends StatefulWidget {
//   const DuolingoSentenceSortScreen({super.key});

//   @override
//   State<DuolingoSentenceSortScreen> createState() =>
//       _DuolingoSentenceSortScreenState();
// }

// class _DuolingoSentenceSortScreenState
//     extends State<DuolingoSentenceSortScreen> {
//   final GlobalKey _containerKey = GlobalKey();
//   final double blockHeight = 54;
//   final double blockSpacing = 12;
//   final double listTop = 100;
//   final double listLeft = 16;
//   final double dragOutThreshold = 200; // y > threshold => ra khỏi list
//   DragDirection dragDirection = DragDirection.none;
//   Offset? startPosition;

//   bool _isPositionBlock = false;

//   static final List<String> words = [
//     'Flutter',
//     'makes',
//     'building',
//     'beautiful',
//     'apps',
//     'really',
//     'fast',
//     'and',
//     'fun',
//     '.',
//   ];

//   static final List<Color> colors = [
//     Colors.blue,
//     Colors.indigo,
//     Colors.teal,
//     Colors.orange,
//     Colors.purple,
//     Colors.green,
//     Colors.red,
//     Colors.cyan,
//     Colors.brown,
//     Colors.grey,
//   ];

//   late List<List<DragObjectState>> rows;

//   DragObjectState touchedObjectState = DragObjectState(
//     id: -1,
//     index: -1,
//     row: -1,
//     col: -1,
//     x: 0,
//     y: 0,
//     dragDirection: DragDirection.none,
//     isDragging: true,
//     width: 100,
//     display: false,
//     height: 54,
//     color: const Color.fromARGB(0, 9, 0, 0),
//     text: 'Dragged',
//   );

//   // ignore: avoid_init_to_null
//   DragObjectState draggedObjectState = DragObjectState(
//     id: -1,
//     index: -1,
//     row: -1,
//     col: -1,
//     x: 0,
//     y: 0,
//     dragDirection: DragDirection.none,
//     isDragging: true,
//     width: 100,
//     display: false,
//     height: 54,
//     color: const Color.fromARGB(0, 9, 0, 0),
//     text: 'Dragged',
//   );
//   // ignore: avoid_init_to_null
//   DragObjectState overlappedObject = DragObjectState(
//     id: -1,
//     index: -1,
//     row: -1,
//     col: -1,
//     x: 0,
//     y: 0,
//     dragDirection: DragDirection.none,
//     isDragging: false,
//     width: 0,
//     display: false,
//     height: 54,
//     color: Colors.transparent,
//     text: '',
//   );

//   List<DragObjectState> beforeObjects = [];
//   List<DragObjectState> afterObjects = [];

//   Offset lastFingerPosition = Offset(-1, -1);

//   /*
//     process steps:
//     1, get overlapped object
//     2, collect objects
//     3, update position
//    */

//   Map<String, bool> steps = {"get": false, "collect": false, "update": false};

//   int loops = 5;

//   @override
//   void initState() {
//     super.initState();
//     rows = [[]];
//   }

//   void _setDefaultDraggedObject() {
//     draggedObjectState = DragObjectState(
//       id: -1,
//       index: -1,
//       row: -1,
//       col: -1,
//       x: 0,
//       y: 0,
//       dragDirection: DragDirection.none,
//       isDragging: false,
//       width: 0,
//       display: false,
//       height: 54,
//       color: Colors.transparent,
//       text: '',
//     );
//   }

//   void _printContainerOffset() {
//     final RenderBox? box =
//         _containerKey.currentContext?.findRenderObject() as RenderBox?;
//     if (box != null) {
//       final Offset topLeft = box.localToGlobal(Offset.zero);
//     }
//   }

//   void _postionBlocks() {
//     double total = 0;
//     double height = 0;
//     int cLine = 0;
//     int rowItemId = 0;

//     final screenWidth = MediaQuery.of(context).size.width;

//     for (int i = 0; i < words.length; i++) {
//       final obj = DragObjectState(
//         id: i,
//         index: i,
//         col: rowItemId,
//         x: 0,
//         y: 0,
//         dragDirection: DragDirection.none,
//         display: true,
//         height: 54,
//         color: colors[i % colors.length],
//         text: words[i],
//       );
//       // Tính width cho obj
//       final textPainter = TextPainter(
//         text: TextSpan(
//           text: obj.text,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         maxLines: 1,
//         textDirection: TextDirection.ltr,
//       )..layout();

//       obj.width = textPainter.width + 32;

//       if (total + obj.width > screenWidth) {
//         rows.add([]);
//         total = 0;
//         height += 54;
//         cLine += 1;
//         rowItemId = 0; // reset id for new row
//       }
//       rows.last.add(obj);
//       obj.x = total;
//       obj.y = height * cLine;
//       obj.id = rowItemId;
//       obj.col = rowItemId;
//       obj.row = cLine;
//       total += obj.width;
//       rowItemId++; // tăng id cho block tiếp theo trong hàng
//     }
//   }

//   void _updateRowsState() {
//     List<DragObjectState> blocks = [...beforeObjects, ...afterObjects];
//   }

//   DragDirection _getDragDirection({
//     required Offset prevPosition,
//     required Offset curPosition,
//   }) {
//     double deltaX = curPosition.dx - prevPosition.dx;
//     double deltaY = curPosition.dy - prevPosition.dy;

//     const double threshold = 0;

//     if (deltaX > threshold && deltaY > threshold) {
//       return DragDirection.downRight;
//     } else if (deltaX < -threshold && deltaY > threshold) {
//       return DragDirection.downLeft;
//     } else if (deltaX > threshold && deltaY < -threshold) {
//       return DragDirection.upRight;
//     } else if (deltaX < -threshold && deltaY < -threshold) {
//       return DragDirection.upLeft;
//     } else if (deltaX > threshold) {
//       return DragDirection.right;
//     } else if (deltaX < -threshold) {
//       return DragDirection.left;
//     } else if (deltaY > threshold) {
//       return DragDirection.down;
//     } else if (deltaY < -threshold) {
//       return DragDirection.up;
//     }
//     return DragDirection.none;
//   }

//   List<DragObjectState> _collectBlocks({
//     required DragObjectState overlappedObject,
//     required DragObjectState draggedObject,
//   }) {
//     debugPrint(
//       "[overlappedObject] ${overlappedObject.text} row: ${overlappedObject.row}, col: ${overlappedObject.col}",
//     );
//     // debugPrint(
//     //   "[draggedObject] row: ${draggedObject.row}, col: ${draggedObject.col}",
//     // );

//     debugPrint("before clear");
//     debugPrint(
//       "[before objects]: ${beforeObjects.map((obj) => obj.text).toList()}",
//     );
//     debugPrint(
//       "[after objects]: ${afterObjects.map((obj) => obj.text).toList()}",
//     );

//     beforeObjects.clear();
//     afterObjects.clear();

//     for (int r = 0; r < rows.length; r++) {
//       if (r < overlappedObject.row) {
//         beforeObjects.addAll(rows[r]);
//       }

//       if (r == overlappedObject.row) {
//         beforeObjects.addAll(rows[r].sublist(0, draggedObject.col));
//         afterObjects.addAll(rows[r].sublist(draggedObject.col + 1));
//       }

//       if (r > overlappedObject.row) {
//         afterObjects.addAll(rows[r]);
//       }
//     }

//     if ([
//       DragDirection.left,
//       DragDirection.up,
//       DragDirection.down,
//     ].contains(dragDirection)) {
//       DragObjectState? dragInRowObj;

//       for (final row in rows) {
//         dragInRowObj = row.firstWhere(
//           (obj) => obj.index == draggedObject.index,
//         );

//         if (dragInRowObj != null) {
//           break;
//         }
//       }

//       if (dragInRowObj != null) {
//         beforeObjects.add(dragInRowObj);
//         afterObjects.add(overlappedObject);
//       }
//     }

//     if ([
//       DragDirection.right,
//     ].contains(dragDirection)) {

//     }

//     debugPrint("after");
//     debugPrint(
//       "[before objects]: ${beforeObjects.map((obj) => obj.text).toList()}",
//     );
//     debugPrint(
//       "[after objects]: ${afterObjects.map((obj) => obj.text).toList()}",
//     );

//     List<DragObjectState> result = [...beforeObjects, ...afterObjects];

//     steps["collect"] = true;
//     steps["update"] = false;

//     return result;
//   }

//   List<List<DragObjectState>> _updateBlocksPosition({
//     required DragObjectState draggedObj,
//     required List<DragObjectState> blocks,
//   }) {
//     List<List<DragObjectState>> newRowsState = [[]];

//     int curRow = 0;
//     int curCol = 0;
//     double curX = 0;
//     double curY = 0;
//     double screenWidth = MediaQuery.of(context).size.width;

//     debugPrint("[screen width]: $screenWidth");

//     for (int i = 0; i < blocks.length; i++) {
//       final block = blocks[i];

//       if (screenWidth - curX < blocks[i].width) {
//         curX = 0;
//         curY += block.height;
//         curCol = 0;
//         curRow += 1;
//         newRowsState.add([]);
//       }

//       // set value for block
//       if (block.index != draggedObj.index) {
//         block.x = curX;
//         block.y = curY;
//       }

//       block.row = curRow;
//       block.col = curCol;

//       newRowsState.last.add(block);

//       // update value for the next, only for x and col
//       // check if there is a space left for the next box

//       curX += block.width;
//       curCol += 1;
//     }

//     // debugPrint("Length: ${newRowsState.length}");

//     // for (int r = 0; r < newRowsState.length; r++) {
//     //   debugPrint(
//     //     "newRowsState Row $r: ${newRowsState[r].map((obj) => obj.text).toList()}",
//     //   );
//     // }

//     // rows = newRowsState;

//     // debugPrint each block in rows
//     // for (int r = 0; r < rows.length; r++) {
//     //   debugPrint("Row $r:");
//     //   for (final obj in rows[r]) {
//     //     debugPrint(
//     //       "  [${obj.text}] id=${obj.id}, index=${obj.index}, row=${obj.row}, col=${obj.col}, x=${obj.x}, y=${obj.y}",
//     //     );
//     //   }
//     // }

//     steps["update"] = true;
//     steps["get"] = false;

//     return newRowsState;
//   }

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback(
//       (_) => _printContainerOffset(),
//     );

//     if (!_isPositionBlock) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         // _calculateObjectWidths(context);
//         _postionBlocks();
//         setState(() {
//           _isPositionBlock = true;
//         });
//       });
//     }

//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Draggable Word Blocks')),
//       body: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onPanStart: (details) {
//           setState(() {
//             // debugPrint(
//             //   "Finger position (global): ${details.globalPosition.dx}, ${details.globalPosition.dy}",
//             // );

//             final RenderBox? box =
//                 _containerKey.currentContext?.findRenderObject() as RenderBox?;
//             final Offset containerOffset =
//                 box?.localToGlobal(Offset.zero) ?? Offset.zero;
//             final double statusBarHeight = MediaQuery.of(context).padding.top;
//             final double appBarHeight = kToolbarHeight;

//             double touchX = details.globalPosition.dx;
//             double touchY =
//                 details.globalPosition.dy - statusBarHeight - appBarHeight;

//             draggedObjectState.x = touchX - draggedObjectState.width / 2;
//             draggedObjectState.y = touchY - draggedObjectState.height / 2;

//             // find the overlapped object by using the position of draggedObject.x, y
//             double centerDX =
//                 draggedObjectState.x + draggedObjectState.width / 2;
//             double centerDY =
//                 draggedObjectState.y + draggedObjectState.height / 2;

//             lastFingerPosition = Offset(centerDX, centerDY);

//             // get the first touched object
//             // debugPrint("On touch position: ${centerDX}, ${centerDY}");

//             DragObjectState? touchObject = getOverlappedObjectByTouch(
//               centerDX,
//               centerDY,
//               rows,
//             );

//             // debugPrint("On touch object: ${touchObject == null}");

//             if (touchObject != null) {
//               //   debugPrint("On touch object: ${touchObject.text}");

//               touchObject.display = false;

//               draggedObjectState.id = touchObject.id;
//               draggedObjectState.index = touchObject.index;
//               draggedObjectState.row = touchObject.row;
//               draggedObjectState.col = touchObject.col;
//               draggedObjectState.x = touchObject.x;
//               draggedObjectState.y = touchObject.y;
//               draggedObjectState.width = touchObject.width;
//               draggedObjectState.height = touchObject.height;
//               draggedObjectState.color = touchObject.color;
//               draggedObjectState.text = touchObject.text;
//               //   draggedObject.display = true;
//               //   draggedObject.isDragging = true;

//               touchedObjectState = touchObject;
//             }

//             draggedObjectState.display = true;
//             draggedObjectState.isDragging = true;

//             // reset drag direction for the new touched object
//             dragDirection = DragDirection.none;
//           });
//         },
//         onPanUpdate: (details) {
//           setState(() {
//             if (loops >= 0) {
//               final RenderBox? box =
//                   _containerKey.currentContext?.findRenderObject()
//                       as RenderBox?;
//               final Offset containerOffset =
//                   box?.localToGlobal(Offset.zero) ?? Offset.zero;
//               final double statusBarHeight = MediaQuery.of(context).padding.top;
//               final double appBarHeight = kToolbarHeight;

//               double touchX = details.globalPosition.dx;
//               double touchY =
//                   details.globalPosition.dy - statusBarHeight - appBarHeight;

//               lastFingerPosition = Offset(
//                 draggedObjectState.x,
//                 draggedObjectState.y,
//               );

//               draggedObjectState.x = touchX - draggedObjectState.width / 2;
//               draggedObjectState.y = touchY - draggedObjectState.height / 2;

//               // debugPrint(
//               //   "Finger position (global): ${details.globalPosition.dx}, ${details.globalPosition.dy + statusBarHeight + appBarHeight}",
//               // );

//               // when having the touched object set up then check its collisions
//               // get drag direction

//               // keep track of current center
//               // before update the value save the prev state first

//               Offset currentPosition = Offset(
//                 draggedObjectState.x,
//                 draggedObjectState.y,
//               );

//               // debugPrint("[Prev Position]: $lastFingerPosition");
//               // debugPrint("[Curr Position]: $currentPosition");

//               DragDirection dragDirection = _getDragDirection(
//                 curPosition: currentPosition,
//                 prevPosition: lastFingerPosition,
//               );

//               debugPrint("[Drag Direction]: $dragDirection");

//               steps["get"] = false;
//               steps["collect"] = false;
//               steps["update"] = false;

//               DragObjectState? localOverlappedObject;

//               if (!steps["get"]!) {
//                 localOverlappedObject = getOverlappedObjectByDirection(
//                   dragged: draggedObjectState,
//                   rows: rows,
//                   dragDirection: dragDirection,
//                 );
//                 steps["get"] = true;
//               }

//               if (localOverlappedObject != null &&
//                   overlappedObject.index != localOverlappedObject.index) {
//                 loops -= 1;

//                 debugPrint(
//                   "local overlapped object: ${localOverlappedObject.text}",
//                 );

//                 List<DragObjectState> blocks = [];

//                 if (steps["get"]! && !steps["collect"]!) {
//                   blocks = _collectBlocks(
//                     overlappedObject: localOverlappedObject,
//                     draggedObject: draggedObjectState,
//                   );
//                   steps["collect"] = true;
//                 }

//                 if (steps["collect"]! && !steps["update"]!) {
//                   List<List<DragObjectState>> newRowsState =
//                       _updateBlocksPosition(
//                         draggedObj: draggedObjectState,
//                         blocks: blocks,
//                       );
//                   rows = newRowsState;
//                   steps["update"] = true;
//                 }

//                 overlappedObject = localOverlappedObject;
//               }
//             }
//           });
//         },
//         onPanEnd: (details) {
//           setState(() {
//             draggedObjectState.display = false;
//             draggedObjectState.isDragging = false;

//             touchedObjectState.display = true;
//           });
//         },
//         child: SizedBox.expand(
//           child: Stack(
//             key: _containerKey,
//             children: [
//               for (int row = 0; row < rows.length; row++)
//                 for (int col = 0; col < rows[row].length; col++)
//                   _buildObject(rows[row][col]),

//               DraggableObject(
//                 x: draggedObjectState.x,
//                 y: draggedObjectState.y,
//                 row: draggedObjectState.row,
//                 isDragging: draggedObjectState.isDragging,
//                 width: draggedObjectState.width,
//                 height: draggedObjectState.height,
//                 color: draggedObjectState.color,
//                 label: draggedObjectState.text,
//                 display: draggedObjectState.display,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildObject(DragObjectState obj) {
//     // Thêm biến lưu vị trí ban đầu
//     return DraggableObject(
//       x: obj.x,
//       y: obj.y,
//       isDragging: obj.isDragging,
//       width: obj.width,
//       height: obj.height,
//       color: obj.color,
//       label: obj.text,
//       display: obj.display,
//     );
//   }
// }
