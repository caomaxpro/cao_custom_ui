// import 'package:flutter/material.dart';
// import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/draggable_word.dart';
// import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/helper.dart';

// enum DragDirection { none, left, right, up, down }

// class DragObjectState {
//   int id; // Thêm id
//   int index;
//   int row;
//   double x;
//   double y;
//   DragDirection dragDirection;
//   bool isDragging;
//   double width;
//   bool display;
//   final double height;
//   final Color color;
//   final String text;

//   DragObjectState({
//     required this.id, // Thêm vào constructor
//     required this.index,
//     required this.x,
//     required this.y,
//     this.dragDirection = DragDirection.none,
//     this.row = -1,
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

//   // ignore: avoid_init_to_null
//   DragObjectState? draggedObject = null;

//   Set<int> overlappedIds = {};

//   List<int> separator = [0, 0];

//   @override
//   void initState() {
//     super.initState();
//     rows = [[]];
//   }

//   void _printContainerOffset() {
//     final RenderBox? box =
//         _containerKey.currentContext?.findRenderObject() as RenderBox?;
//     if (box != null) {
//       final Offset topLeft = box.localToGlobal(Offset.zero);
//     }
//   }

//   List<List<DragObjectState>> copyRows(List<List<DragObjectState>> rows) {
//     return rows
//         .map(
//           (row) => row
//               .map(
//                 (obj) => DragObjectState(
//                   id: obj.id,
//                   index: obj.index,
//                   x: obj.x,
//                   y: obj.y,
//                   isDragging: obj.isDragging,
//                   width: obj.width,
//                   display: obj.display,
//                   height: obj.height,
//                   color: obj.color,
//                   text: obj.text,
//                 ),
//               )
//               .toList(),
//         )
//         .toList();
//   }

//   void _updateBlocksPostion(
//     DragObjectState draggedObject,
//     DragObjectState overlappedObject,
//     List<List<DragObjectState>> rows,
//     BuildContext context,
//   ) {
//     // make a copy of rows

//     debugPrint("${overlappedObject.row}, ${draggedObject.row}");

//     // check to see the overlapped object is in which row
//     if (overlappedObject.row == draggedObject.row) {
//       // if in the same row, it doesn't matter where the dragged object move, the total width wont' change

//       // so for this just recalculate x, and y of objects in a row

//       debugPrint("it is in the same row");
//       debugPrint(
//         "Row 0 ids: ${rows[draggedObject.row].map((obj) => obj.id).toList()}",
//       );

//       final row = rows[draggedObject.row];
//       final draggedIndex = row.indexWhere((obj) => obj.id == draggedObject.id);
//       final overlappedIndex = row.indexWhere(
//         (obj) => obj.id == overlappedObject.id,
//       );

//       List<DragObjectState> betweenObjects;

//       debugPrint("Indexes: $draggedIndex, $overlappedIndex");

//       if (draggedObject.dragDirection == DragDirection.right &&
//           overlappedObject.dragDirection == DragDirection.none) {
//         final tempId = draggedObject.id;
//         draggedObject.id = overlappedObject.id;
//         overlappedObject.id = tempId;
//         overlappedObject.x -= draggedObject.width;
//         overlappedObject.dragDirection = DragDirection.left;
//       } else if (draggedObject.dragDirection == DragDirection.left &&
//           overlappedObject.dragDirection == DragDirection.none) {
//         final tempId = draggedObject.id;
//         draggedObject.id = overlappedObject.id;
//         overlappedObject.id = tempId;
//         overlappedObject.x += draggedObject.width;
//         overlappedObject.dragDirection = DragDirection.right;
//       }

//       debugPrint(
//         "Row 0 ids after: ${rows[draggedObject.row].map((obj) => obj.id).toList()}",
//       );
//     } else if (overlappedObject.row != draggedObject.row) {
//       // move all items to fill the blank created by the dragged item

//       // clone state of overlapped item for use later
//       DragObjectState overlappedClone = DragObjectState(
//         id: overlappedObject.id,
//         index: overlappedObject.index,
//         x: overlappedObject.x,
//         y: overlappedObject.y,
//         row: overlappedObject.row,
//         dragDirection: overlappedObject.dragDirection,
//         isDragging: overlappedObject.isDragging,
//         width: overlappedObject.width,
//         display: overlappedObject.display,
//         height: overlappedObject.height,
//         color: overlappedObject.color,
//         text: overlappedObject.text,
//       );

//       DragObjectState missingObj = draggedObject;

//       if (draggedObject.dragDirection == DragDirection.down &&
//           overlappedObject.dragDirection == DragDirection.none) {
//         final screenWidth = MediaQuery.of(context).size.width;

//         // run a for loop from dragged item's row to the rest to update block position
//         for (
//           int i = 0;
//           i < rows.sublist(draggedObject.row, separator.last + 1).length;
//           i++
//         ) {
//           /*
//             check the current position of dragged item to see if it's in its own row or not

//             if not or out of bound then set emptyWidth to its width
//             */

//           debugPrint("Missing Obj: ${missingObj.text}");

//           double emptyWidth = 0;

//           double totalRemainWidthInRow = 0;

//           for (final obj in rows[missingObj.row]) {
//             if (obj.id == missingObj.id && obj.row == missingObj.row) {
//               continue;
//             }
//             totalRemainWidthInRow += obj.width;
//           }

//           emptyWidth = screenWidth - totalRemainWidthInRow;

//           List<DragObjectState> objBehind = [];

//           if (separator.last != missingObj.row) {
//             objBehind = rows[missingObj.row].sublist(missingObj.id + 1);
//           } else if (separator.last == missingObj.row) {
//             objBehind = rows[missingObj.row].sublist(
//               missingObj.id + 1,
//               separator.first + 1,
//             );
//           }

//           // locate the position of dragged obj in which row, and it in index

//           // objects behind dragged item move to the left

//           for (final obj in objBehind) {
//             if (obj.dragDirection == DragDirection.none) {
//               obj.x -= missingObj.width;
//               obj.dragDirection = DragDirection.left;
//             }
//           }

//           // move the first item of next row up if it fits the remaining space created by dragged object

//           // check if there is a next row

//           DragObjectState? firstItemNextRow;

//           if (i + 1 < rows.length) {
//             firstItemNextRow = rows[i + 1][0];
//           }

//           // reset empty width
//           if (firstItemNextRow != null &&
//               emptyWidth >= firstItemNextRow.width) {
//             emptyWidth = screenWidth - firstItemNextRow.width;

//             // get the last item in dragged row except the dragged;

//             DragObjectState lastItem = rows[i].last;

//             if (rows[i].last.id == missingObj.id &&
//                 rows[i].last.row == missingObj.row) {
//               lastItem = rows[i][missingObj.id - 1];
//             }

//             // firstItemNextRow.row = lastItem.row;
//             firstItemNextRow.x = lastItem.x + lastItem.width;
//             firstItemNextRow.y = lastItem.y;
//             firstItemNextRow.dragDirection = DragDirection.up;
//             missingObj = firstItemNextRow;
//           }
//         }
//       }

//       // test object behind dragged
//       //   List<DragObjectState> objBehindDragged = rows[separator.last].sublist(
//       //     separator.first + 1,
//       //   );

//       //   for (final obj in objBehindDragged) {
//       //     obj.x += (draggedObject.width - missingObj.width);
//       //     obj.dragDirection = DragDirection.right;
//       //   }
//     }
//   }

//   void _postionBlocks() {
//     double total = 0;
//     double height = 0;
//     int cLine = 0;
//     int rowItemId = 0;

//     final screenWidth =
//         WidgetsBinding.instance.window.physicalSize.width /
//         WidgetsBinding.instance.window.devicePixelRatio;

//     for (int i = 0; i < words.length; i++) {
//       final obj = DragObjectState(
//         id: rowItemId,
//         index: i,
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

//       if (total + obj.width > screenWidth - 8) {
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
//       obj.row = cLine;
//       total += obj.width;
//       rowItemId++; // tăng id cho block tiếp theo trong hàng
//     }
//   }

//   // void _calculateObjectWidths(BuildContext context) {
//   //   double total = 0;
//   //   double height = 0;
//   //   int c_line = 0;

//   //   for (int i = 0; i < objects.length; i++) {
//   //     final obj = objects[i];
//   //     final textPainter = TextPainter(
//   //       text: TextSpan(
//   //         text: obj.text,
//   //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//   //       ),
//   //       maxLines: 1,
//   //       textDirection: TextDirection.ltr,
//   //     )..layout();

//   //     // if total >= screen width: break line
//   //     // total = 0; height + 54

//   //     if (total >= MediaQuery.of(context).size.width - 100) {
//   //       total = 0;
//   //       height += 54;
//   //       c_line += 1;
//   //     }

//   //     obj.width = textPainter.width + 32; // 32 là padding ngang
//   //     obj.x = total + 8;
//   //     obj.y = height + 8 * c_line;
//   //     total += obj.width;

//   //     debugPrint("[width $i]: ${obj.width}");
//   //     debugPrint("[total width]: $total");
//   //   }
//   // }

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
//       body: Center(
//         child: Stack(
//           children: [
//             for (int row = 0; row < rows.length; row++)
//               for (int col = 0; col < rows[row].length; col++)
//                 _buildObject(rows[row][col]),

//             // if (draggedObject != null)
//             //   DraggableObject(
//             //     x: draggedObject!.x,
//             //     y: draggedObject!.y,
//             //     row: draggedObject!.row,
//             //     isDragging: draggedObject!.isDragging,
//             //     width: draggedObject!.width,
//             //     height: draggedObject!.height,
//             //     color: draggedObject!.color,
//             //     label: draggedObject!.text,
//             //     display: true,
//             //     onPanStart: (details) {
//             //       setState(() {
//             //         draggedObject!.isDragging = true;
//             //       });
//             //     },
//             //     onPanUpdate: (details) {
//             //       setState(() {
//             //         draggedObject!.x += details.delta.dx;
//             //         draggedObject!.y += details.delta.dy;
//             //       });
//             //     },
//             //     onPanEnd: (details) {
//             //       setState(() {
//             //         draggedObject = null;
//             //       });
//             //     },
//             //   ),
//           ],
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
//       onPanStart: (details) {
//         setState(() {
//           // check ids of each row
//           //   for (int i = 0; i < rows.length; i++) {
//           //     debugPrint("Row $i ids: ${rows[i].map((obj) => obj.id).toList()}");
//           //   }

//           obj.isDragging = true;
//           // obj.display = false;
//           final screenHeight = MediaQuery.of(context).size.height;
//           //   draggedObject = DragObjectState(
//           //     id: obj.id,
//           //     x: obj.x,
//           //     y: obj.y, // vị trí bottom mặc định
//           //     row: obj.row,
//           //     isDragging: true,
//           //     width: obj.width,
//           //     height: obj.height,
//           //     color: obj.color,
//           //     text: obj.text,
//           //     display: true,
//           //   );

//           //   debugPrint(
//           //     "[Dragged Object] x:${draggedObject!.x}, y:${draggedObject!.y}, width:${draggedObject!.width}, height:${draggedObject!.height}, color:${draggedObject!.color}, text:${draggedObject!.text}",
//           //   );

//           startPosition = Offset(obj.x, obj.y);
//           dragDirection = DragDirection.none; // reset direction

//           //   debugPrint("[Dragging Position]: $startPosition");

//           // _calculateObjectWidths(context);
//         });
//       },
//       onPanUpdate: (details) {
//         setState(() {
//           if (obj.isDragging) {
//             obj.x += details.delta.dx;
//             obj.y += details.delta.dy;

//             // debugPrint("[Start Position]: $startPosition");

//             if (details.delta.dx > 2) {
//               dragDirection = DragDirection.right;
//               //   debugPrint("Dragging RIGHT");
//             } else if (details.delta.dx < -2) {
//               dragDirection = DragDirection.left;
//               //   debugPrint("Dragging LEFT");
//             } else if (details.delta.dy > 2) {
//               dragDirection = DragDirection.down;
//               //   debugPrint("Dragging DOWN");
//             } else if (details.delta.dy < -2) {
//               dragDirection = DragDirection.up;
//               //   debugPrint("Dragging UP");
//             }

//             if (obj.dragDirection != dragDirection) {
//               debugPrint("dragging direction: $dragDirection");
//               for (final row in rows) {
//                 for (final o in row) {
//                   o.dragDirection = DragDirection.none;
//                 }
//               }
//               obj.dragDirection = dragDirection;
//             }

//             DragObjectState? overlappedObject = getOverlappedObject(
//               obj,
//               rows,
//               dragDirection,
//             );

//             // separator will be updated according to overlapped object

//             debugPrint("[Overlapped object]: ${overlappedObject?.text}");

//             if (overlappedObject != null) {
//               separator = [overlappedObject.id, overlappedObject.row];

//               _updateBlocksPostion(obj, overlappedObject, rows, context);
//               overlappedIds.add(overlappedObject.id);
//             }

//             // debugPrint(
//             //   "object dragged: ${isOverlappingAny(draggedObject!, rows)}",
//             // );
//           }
//         });
//       },
//       onPanEnd: (details) {
//         setState(() {
//           obj.isDragging = false;
//           // recalculate its position

//           // onPanEnd remove the object out of the row, insert it back to the list according to the obj.id

//           // DragObjectState cloneObj = DragObjectState(
//           //   id: obj.id,
//           //   x: obj.x,
//           //   y: obj.y,
//           //   row: obj.row,
//           //   dragDirection: obj.dragDirection,
//           //   isDragging: false,
//           //   width: obj.width,
//           //   display: obj.display,
//           //   height: obj.height,
//           //   color: obj.color,
//           //   text: obj.text,
//           // );

//           // for (final row in rows) {
//           //   row.remove(obj);
//           // }

//           debugPrint(
//             "[dragObj id]: ${obj.id}, [row ids]: ${rows[obj.row].map((obj) => obj.id).toList()}",
//           );

//           // rows[obj.row].insert(obj.id, cloneObj);

//           // if (draggedObject != null) {
//           //   setState(() {
//           //     draggedObject = null;
//           //   });
//           // }

//           debugPrint(
//             "Before remove: id=${obj.id}, isDragging=${obj.isDragging}, x=${obj.x}, y=${obj.y}",
//           );

//           if (dragDirection != DragDirection.down &&
//               dragDirection != DragDirection.up) {
//             for (final row in rows) {
//               row.remove(obj);
//             }
//             rows[obj.row].insert(obj.id, obj);

//             obj.y = rows[obj.row][0].y;

//             double ex = 0;

//             final subRow = rows[obj.row].sublist(0, obj.id);

//             debugPrint("SubRow ids: ${subRow.map((o) => o.id).toList()}");

//             for (final obj in subRow) {
//               ex += obj.width;
//             }

//             obj.x = ex;
//           }

//           debugPrint(
//             "After insert: id=${obj.id}, isDragging=${obj.isDragging}, x=${obj.x}, y=${obj.y}",
//           );

//           for (final row in rows) {
//             for (final obj in row) {
//               obj.dragDirection = DragDirection.none;
//             }
//           }
//         });
//       },
//     );
//   }
// }
