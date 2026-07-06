import 'dart:ui';
import 'package:path_parsing/path_parsing.dart';
import 'dart:math' as math;

import 'package:mobile_custom_ui/screens/morphing_effect/morphing_object.dart';

List<CubicControlPoint> svgPathToCubicPoints(String svgPath) {
  final List<CubicControlPoint> points = [];
  Offset? moveToPoint;

  PathProxy proxy = _CubicPathProxy(
    (anchor, c1, c2) {
      points.add(CubicControlPoint(anchor: anchor, control1: c1, control2: c2));
    },
    (x, y) {
      // Khi gặp lệnh moveTo, convert ngay thành cubic point
      final offset = Offset(x, y);
      points.add(
        CubicControlPoint(anchor: offset, control1: offset, control2: offset),
      );
      moveToPoint = offset;
    },
  );

  writeSvgPathDataToPath(svgPath, proxy);

  //   // Nếu điểm đầu bị trùng với điểm cuối, loại bỏ điểm cuối
  //   if (points.length > 1 && points.last.anchor == points.first.anchor) {
  //     points.removeLast();
  //   }

  return points;
}

List<CubicControlPoint> offsetsToCubicPoints(List<Offset> offsets) {
  final List<CubicControlPoint> result = [];
  for (int i = 0; i < offsets.length; i++) {
    final anchor = offsets[i];
    // Control points mặc định: trùng anchor hoặc lấy điểm lân cận
    final control1 = anchor;
    final control2 = anchor;
    result.add(
      CubicControlPoint(anchor: anchor, control1: control1, control2: control2),
    );
  }
  return result;
}

class _CubicPathProxy extends PathProxy {
  final void Function(Offset anchor, Offset c1, Offset c2) onCubic;
  final void Function(double x, double y) onMoveTo;

  Offset _current = Offset.zero;
  Offset? _firstPoint; // Để xử lý closePath

  _CubicPathProxy(this.onCubic, this.onMoveTo);

  @override
  void moveTo(double x, double y) {
    _current = Offset(x, y);
    _firstPoint ??= _current;
    onMoveTo(x, y);
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    onCubic(Offset(x3, y3), Offset(x1, y1), Offset(x2, y2));
    _current = Offset(x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    // Chuyển lineTo thành cubicTo bằng cách đặt điểm điều khiển
    // nằm trên đường thẳng (1/3 và 2/3 đường)
    final double x1 = _current.dx + (x - _current.dx) * 1 / 3;
    final double y1 = _current.dy + (y - _current.dy) * 1 / 3;
    final double x2 = _current.dx + (x - _current.dx) * 2 / 3;
    final double y2 = _current.dy + (y - _current.dy) * 2 / 3;

    cubicTo(x1, y1, x2, y2, x, y);
  }

  @override
  void close() {
    // Khi close, tạo đường cong cubic đến điểm đầu tiên
    if (_firstPoint != null && _current != _firstPoint) {
      lineTo(_firstPoint!.dx, _firstPoint!.dy);
    }
  }

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    // Chuyển quadratic thành cubic
    final double cx1 = _current.dx + 2 / 3 * (x1 - _current.dx);
    final double cy1 = _current.dy + 2 / 3 * (y1 - _current.dy);
    final double cx2 = x2 + 2 / 3 * (x1 - x2);
    final double cy2 = y2 + 2 / 3 * (y1 - y2);

    cubicTo(cx1, cy1, cx2, cy2, x2, y2);
  }

  // Các phương thức khác của PathProxy
  @override
  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    // Đối với hàm phức tạp như arcToPoint, có thể cần triển khai bằng cách
    // tính toán các điểm trên cung và chuyển đổi thành cubicTo
    // Ở đây chỉ nối điểm đầu và cuối
    lineTo(arcEnd.dx, arcEnd.dy);
  }

  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) {
    // Chuyển conic thành cubic (xấp xỉ)
    quadraticBezierTo(x1, y1, x2, y2);
  }
}

/// Chuẩn hóa: mọi shape có cùng số điểm (maxPoints).
List<List<CubicControlPoint>> normalizeShapes(
  List<List<CubicControlPoint>> shapes,
) {
  if (shapes.isEmpty) return shapes;

  final int maxPoints = shapes
      .map((s) => s.length)
      .fold<int>(0, (p, c) => math.max(p, c));

  if (maxPoints <= 1) return shapes;

  return shapes
      .map((s) => _resampleShapeClosed(s, maxPoints))
      .toList(growable: false);
}

List<CubicControlPoint> _resampleShapeClosed(
  List<CubicControlPoint> shape,
  int targetCount,
) {
  if (shape.isEmpty) return shape;
  if (shape.length == 1) {
    // Nếu chỉ có 1 điểm, nhân bản cho đủ
    return List<CubicControlPoint>.filled(targetCount, shape.first);
  }

  final List<CubicControlPoint> out = [];

  for (int i = 0; i < targetCount; i++) {
    // t chạy quanh vòng, t trong [0, length)
    final double t = i * shape.length / targetCount;
    final int i0 = t.floor() % shape.length;
    final int i1 = (i0 + 1) % shape.length;
    final double localT = t - t.floor();

    out.add(_lerpCubicPoint(shape[i0], shape[i1], localT));
  }

  return out;
}

CubicControlPoint _lerpCubicPoint(
  CubicControlPoint a,
  CubicControlPoint b,
  double t,
) {
  return CubicControlPoint(
    anchor: Offset.lerp(a.anchor, b.anchor, t)!,
    control1: Offset.lerp(a.control1, b.control1, t)!,
    control2: Offset.lerp(a.control2, b.control2, t)!,
  );
}
