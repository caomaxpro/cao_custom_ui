import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/sentence_completion_game_3.dart';

Rect getLeftRect(double x, double y, double width, double height) {
  final double leftWidth = width * 0.2;
  return Rect.fromLTWH(x, y, leftWidth, height);
}

Rect getMiddleRect(double x, double y, double width, double height) {
  final double leftWidth = width * 0.2;
  final double middleWidth = width * 0.6;
  return Rect.fromLTWH(x + leftWidth, y, middleWidth, height);
}

Rect getRightRect(double x, double y, double width, double height) {
  final double rightWidth = width * 0.2;
  return Rect.fromLTWH(x + width - rightWidth, y, rightWidth, height);
}

bool isInContainerBound({
  required DragObjectState draggedObj,
  required BuildContext context,
  required List<List<DragObjectState>> rows,
}) {
  // calculate bounds

  double leftBound = 0;
  double rightBound = MediaQuery.of(context).size.width;
  double upperBound = 0;
  double lowerBound = draggedObj.height * rows.length;

  // create a box
  final containerRect = Rect.fromLTWH(
    leftBound,
    upperBound,
    rightBound,
    lowerBound,
  );

  // dragged rect
  final draggedRect = Rect.fromLTWH(
    draggedObj.x,
    draggedObj.y,
    draggedObj.width,
    draggedObj.height,
  );

  if (containerRect.overlaps(draggedRect)) {
    return true;
  }

  return false;
}

DragObjectState? getOverlappedObjectByTouch(
  double touchX,
  double touchY,
  List<DragObjectState> blocks,
) {
  for (final obj in blocks) {
    final objRect = Rect.fromLTWH(obj.x, obj.y, obj.width, obj.height);
    if (objRect.contains(Offset(touchX, touchY))) {
      debugPrint(
        '[Touch Overlap] text=${obj.text}, id=${obj.id}, index=${obj.index}, x=${obj.x}, y=${obj.y}, row=${obj.row}, col=${obj.col}',
      );
      return obj;
    }
  }
  return null;
}

DragObjectState? getOverlappedObjectByPercentage(
  DragObjectState dragged,
  List<DragObjectState> blocks,
) {
  // debugPrint(
  //   '[dragged] id=${dragged.id}, x=${dragged.x}, y=${dragged.y}, row=${dragged.row}, isDragging=${dragged.isDragging}',
  // );

  final double contactDepthW = dragged.width * 0.3;
  final double contactDepthH = dragged.height * 0.5;

  final draggedRect = Rect.fromLTWH(
    dragged.x + contactDepthW / 2,
    dragged.y + contactDepthH / 2,
    dragged.width - contactDepthW,
    dragged.height - contactDepthH,
  );

  for (final obj in blocks) {
    if (obj.index == dragged.index) continue;
    final objRect = Rect.fromLTWH(obj.x, obj.y, obj.width, obj.height);

    if (draggedRect.overlaps(objRect)) {
      final overlapRect = draggedRect.intersect(objRect);
      final overlapArea = overlapRect.width * overlapRect.height;
      final percent = overlapArea / (draggedRect.width * draggedRect.height);

      if (percent >= 0.6) {
        debugPrint(
          '[Va chạm] text=${obj.text}, id=${obj.id}, index=${obj.index}, percent=${(percent * 100).toStringAsFixed(2)}%',
        );
        return obj;
      }
    }
  }
  return null;
}

DragObjectState? getOverlappedObjectByDirection({
  required DragObjectState dragged,
  required List<DragObjectState> blocks,
  required DragDirection dragDirection,
}) {
  final double leftWidth = dragged.width * 0.2;
  final double rightWidth = dragged.width * 0.2;

  Rect getLeftRect(DragObjectState obj) =>
      Rect.fromLTWH(obj.x, obj.y, leftWidth, obj.height);

  Rect getRightRect(DragObjectState obj) => Rect.fromLTWH(
    obj.x + obj.width - rightWidth,
    obj.y,
    rightWidth,
    obj.height,
  );

  for (final obj in blocks) {
    if (obj.index == dragged.index) continue;

    if (dragDirection == DragDirection.up ||
        dragDirection == DragDirection.down) {
      // Kiểm tra cả left và right
      final draggedLeftRect = getLeftRect(dragged);
      final objLeftRect = getLeftRect(obj);
      final draggedRightRect = getRightRect(dragged);
      final objRightRect = getRightRect(obj);

      // Left va chạm
      if (draggedLeftRect.overlaps(objLeftRect)) {
        final overlapRect = draggedLeftRect.intersect(objLeftRect);
        final percent =
            (overlapRect.width * overlapRect.height) /
            (objLeftRect.width * objLeftRect.height);
        if (percent > 0.5) {
          debugPrint(
            '[Direction Overlap LEFT] text=${obj.text}, percent=${(percent * 100).toStringAsFixed(2)}%',
          );
          return obj;
        }
      }
      // Right va chạm
      if (draggedRightRect.overlaps(objRightRect)) {
        final overlapRect = draggedRightRect.intersect(objRightRect);
        final percent =
            (overlapRect.width * overlapRect.height) /
            (objRightRect.width * objRightRect.height);
        if (percent > 0.5) {
          debugPrint(
            '[Direction Overlap RIGHT] text=${obj.text}, percent=${(percent * 100).toStringAsFixed(2)}%',
          );
          return obj;
        }
      }
    } else if (dragDirection == DragDirection.left) {
      final draggedLeftRect = getLeftRect(dragged);
      final objLeftRect = getLeftRect(obj);
      if (draggedLeftRect.overlaps(objLeftRect)) {
        final overlapRect = draggedLeftRect.intersect(objLeftRect);
        final percent =
            (overlapRect.width * overlapRect.height) /
            (objLeftRect.width * objLeftRect.height);
        if (percent > 0.5) {
          debugPrint(
            '[Direction Overlap LEFT] text=${obj.text}, percent=${(percent * 100).toStringAsFixed(2)}%',
          );
          return obj;
        }
      }
    } else if (dragDirection == DragDirection.right) {
      final draggedRightRect = getRightRect(dragged);
      final objRightRect = getRightRect(obj);
      if (draggedRightRect.overlaps(objRightRect)) {
        final overlapRect = draggedRightRect.intersect(objRightRect);
        final percent =
            (overlapRect.width * overlapRect.height) /
            (objRightRect.width * objRightRect.height);
        if (percent > 0.5) {
          debugPrint(
            '[Direction Overlap RIGHT] text=${obj.text}, percent=${(percent * 100).toStringAsFixed(2)}%',
          );
          return obj;
        }
      }
    }
    // Các hướng khác thì xử lý như cũ nếu cần
  }
  return null;
}
