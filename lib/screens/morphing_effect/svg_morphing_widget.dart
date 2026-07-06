import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';

/// Widget duy nhất để morph giữa nhiều SVG path.
/// Ví dụ dùng:
/// SvgMorphingWidget(
///   svgPaths: [path0, path1, path2],
///   size: Size(200, 300),
///   color: Colors.blue,
/// )
class SvgMorphingWidget extends StatefulWidget {
  final List<String> svgPaths;
  final Size size;
  final Color color;
  final Duration duration;

  const SvgMorphingWidget({
    super.key,
    required this.svgPaths,
    this.size = const Size(200, 300),
    this.color = Colors.blue,
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<SvgMorphingWidget> createState() => _SvgMorphingWidgetState();
}

class _SvgMorphingWidgetState extends State<SvgMorphingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;
  late final List<List<_CubicControlPoint>> _shapes;
  int _currentShape = 0;

  @override
  void initState() {
    super.initState();

    // 1. SVG string -> cubic points (bỏ qua path rỗng/lỗi)
    final rawShapes = <List<_CubicControlPoint>>[];
    for (int i = 0; i < widget.svgPaths.length; i++) {
      final p = widget.svgPaths[i];
      if (p.trim().isEmpty) {
        debugPrint('⚠️ Path[$i]: empty, skipped');
        continue;
      }
      try {
        final points = _svgPathToCubicPoints(p);
        if (points.isNotEmpty) {
          debugPrint('✅ Path[$i]: ${points.length} points');
          rawShapes.add(points);
        } else {
          debugPrint('⚠️ Path[$i]: 0 points, skipped');
        }
      } catch (e) {
        debugPrint('⚠️ Path[$i]: INVALID SVG, skipped ($e)');
      }
    }

    debugPrint('📊 Total valid shapes: ${rawShapes.length}');

    // 2. Chuẩn hóa số điểm giữa các shape
    _shapes = _normalizeShapes(rawShapes);

    debugPrint('📊 After normalize: ${_shapes.map((s) => s.length).toList()}');

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _t = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _shapes.length > 1) {
        setState(() {
          _currentShape = (_currentShape + 1) % _shapes.length;
        });
        _controller.forward(from: 0);
      }
    });

    if (_shapes.length > 1) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shapes.isEmpty) {
      // Không có shape -> vẽ box trơn
      return Container(
        width: widget.size.width,
        height: widget.size.height,
        color: widget.color,
      );
    }

    if (_shapes.length == 1) {
      // Chỉ 1 shape -> vẽ cố định
      return ClipPath(
        clipper: _MorphClipper(
          shapeA: _shapes.first,
          shapeB: _shapes.first,
          t: 0,
        ),
        child: Container(
          width: widget.size.width,
          height: widget.size.height,
          color: widget.color,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final nextIndex = (_currentShape + 1) % _shapes.length;
        return ClipPath(
          clipper: _MorphClipper(
            shapeA: _shapes[_currentShape],
            shapeB: _shapes[nextIndex],
            t: _t.value,
          ),
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            color: widget.color,
          ),
        );
      },
    );
  }
}

// ================== Internals (ẩn trong file) ==================

class _CubicControlPoint {
  final Offset anchor;
  final Offset control1;
  final Offset control2;

  const _CubicControlPoint({
    required this.anchor,
    required this.control1,
    required this.control2,
  });
}

class _MorphClipper extends CustomClipper<Path> {
  final List<_CubicControlPoint> shapeA;
  final List<_CubicControlPoint> shapeB;
  final double t;

  _MorphClipper({required this.shapeA, required this.shapeB, required this.t});

  @override
  Path getClip(Size size) {
    final path = Path();

    if (shapeA.isEmpty || shapeB.isEmpty) return path;

    final firstA = shapeA.first;
    final firstB = shapeB.first;
    final firstAnchor =
        Offset.lerp(firstA.anchor, firstB.anchor, t) ?? firstA.anchor;

    path.moveTo(firstAnchor.dx, firstAnchor.dy);

    final len = math.min(shapeA.length, shapeB.length);

    for (int i = 1; i < len; i++) {
      final a = shapeA[i];
      final b = shapeB[i];

      final anchor = Offset.lerp(a.anchor, b.anchor, t)!;
      final c1 = Offset.lerp(a.control1, b.control1, t)!;
      final c2 = Offset.lerp(a.control2, b.control2, t)!;

      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, anchor.dx, anchor.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _MorphClipper oldClipper) =>
      t != oldClipper.t ||
      shapeA != oldClipper.shapeA ||
      shapeB != oldClipper.shapeB;
}

// ---------- SVG -> cubic points ----------

List<_CubicControlPoint> _svgPathToCubicPoints(String svgPath) {
  final List<_CubicControlPoint> points = [];

  PathProxy proxy = _CubicPathProxy(
    (anchor, c1, c2) {
      points.add(
        _CubicControlPoint(anchor: anchor, control1: c1, control2: c2),
      );
    },
    (x, y) {
      final offset = Offset(x, y);
      points.add(
        _CubicControlPoint(anchor: offset, control1: offset, control2: offset),
      );
    },
  );

  writeSvgPathDataToPath(svgPath, proxy);
  return points;
}

class _CubicPathProxy extends PathProxy {
  final void Function(Offset anchor, Offset c1, Offset c2) onCubic;
  final void Function(double x, double y) onMoveTo;

  Offset _current = Offset.zero;
  Offset? _firstPoint;

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
    final double x1 = _current.dx + (x - _current.dx) / 3;
    final double y1 = _current.dy + (y - _current.dy) / 3;
    final double x2 = _current.dx + (x - _current.dx) * 2 / 3;
    final double y2 = _current.dy + (y - _current.dy) * 2 / 3;

    cubicTo(x1, y1, x2, y2, x, y);
  }

  @override
  void close() {
    if (_firstPoint != null && _current != _firstPoint) {
      lineTo(_firstPoint!.dx, _firstPoint!.dy);
    }
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    final double cx1 = _current.dx + 2 / 3 * (x1 - _current.dx);
    final double cy1 = _current.dy + 2 / 3 * (y1 - _current.dy);
    final double cx2 = x2 + 2 / 3 * (x1 - x2);
    final double cy2 = y2 + 2 / 3 * (y1 - y2);

    cubicTo(cx1, cy1, cx2, cy2, x2, y2);
  }

  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    lineTo(arcEnd.dx, arcEnd.dy);
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {
    quadraticBezierTo(x1, y1, x2, y2);
  }
}

// ---------- Chuẩn hóa số điểm giữa các shape ----------

List<List<_CubicControlPoint>> _normalizeShapes(
  List<List<_CubicControlPoint>> shapes,
) {
  if (shapes.isEmpty) return shapes;

  final int maxPoints = shapes
      .map((s) => s.length)
      .fold<int>(0, (p, c) => math.max(p, c));

  if (maxPoints <= 1) return shapes;

  return shapes
      .map((s) => _subdivideToMatch(s, maxPoints))
      .toList(growable: false);
}

/// Chia nhỏ các segment cubic để shape có đúng [targetCount] điểm.
/// Dùng thuật toán De Casteljau để điểm mới nằm chính xác trên đường cong.
List<_CubicControlPoint> _subdivideToMatch(
  List<_CubicControlPoint> shape,
  int targetCount,
) {
  if (shape.isEmpty) return shape;
  if (shape.length >= targetCount) return shape;
  if (shape.length == 1) {
    return List<_CubicControlPoint>.filled(targetCount, shape.first);
  }

  // Số segment hiện tại (mỗi segment = 2 điểm liền kề: start -> end)
  // shape[0] = moveTo, shape[1..n-1] = cubicTo segments
  // => có (shape.length - 1) segments

  List<_CubicControlPoint> result = List.from(shape);

  while (result.length < targetCount) {
    // Tìm segment dài nhất để chia đôi
    int longestIndex = 0;
    double longestDist = 0;

    for (int i = 0; i < result.length - 1; i++) {
      final dist = (result[i + 1].anchor - result[i].anchor).distance;
      if (dist > longestDist) {
        longestDist = dist;
        longestIndex = i;
      }
    }

    // Chia đôi segment tại longestIndex -> longestIndex+1
    final start = result[longestIndex];
    final end = result[longestIndex + 1];

    final split = _splitCubicAt(start, end, 0.5);

    // Thay 1 segment bằng 2 segment
    result = [
      ...result.sublist(0, longestIndex + 1),
      split.midPoint,
      // Cập nhật end point với control points mới
      _CubicControlPoint(
        anchor: end.anchor,
        control1: split.secondC1,
        control2: split.secondC2,
      ),
      ...result.sublist(longestIndex + 2),
    ];

    // Cập nhật control points của segment đầu
    result[longestIndex + 0] = _CubicControlPoint(
      anchor: start.anchor,
      control1: start.control1,
      control2: start.control2,
    );

    // midPoint đã có control1 = firstC1, control2 = firstC2 từ split
  }

  return result;
}

/// Kết quả chia đôi 1 cubic bézier segment bằng De Casteljau
class _SplitResult {
  final _CubicControlPoint midPoint;
  final Offset secondC1;
  final Offset secondC2;

  _SplitResult({
    required this.midPoint,
    required this.secondC1,
    required this.secondC2,
  });
}

/// De Casteljau: chia cubic bézier [start -> end] tại t
/// P0 = start.anchor
/// P1 = end.control1  (control point 1 của segment)
/// P2 = end.control2  (control point 2 của segment)
/// P3 = end.anchor
_SplitResult _splitCubicAt(
  _CubicControlPoint start,
  _CubicControlPoint end,
  double t,
) {
  final p0 = start.anchor;
  final p1 = end.control1;
  final p2 = end.control2;
  final p3 = end.anchor;

  // Level 1
  final p01 = Offset.lerp(p0, p1, t)!;
  final p12 = Offset.lerp(p1, p2, t)!;
  final p23 = Offset.lerp(p2, p3, t)!;

  // Level 2
  final p012 = Offset.lerp(p01, p12, t)!;
  final p123 = Offset.lerp(p12, p23, t)!;

  // Level 3 - điểm giữa trên curve
  final p0123 = Offset.lerp(p012, p123, t)!;

  // Nửa đầu: P0 -> p01 -> p012 -> p0123
  // => midPoint.control1 = p01, midPoint.control2 = p012, midPoint.anchor = p0123

  // Nửa sau: p0123 -> p123 -> p23 -> P3
  // => secondC1 = p123, secondC2 = p23

  return _SplitResult(
    midPoint: _CubicControlPoint(anchor: p0123, control1: p01, control2: p012),
    secondC1: p123,
    secondC2: p23,
  );
}

_CubicControlPoint _lerpCubicPoint(
  _CubicControlPoint a,
  _CubicControlPoint b,
  double t,
) {
  return _CubicControlPoint(
    anchor: Offset.lerp(a.anchor, b.anchor, t)!,
    control1: Offset.lerp(a.control1, b.control1, t)!,
    control2: Offset.lerp(a.control2, b.control2, t)!,
  );
}
