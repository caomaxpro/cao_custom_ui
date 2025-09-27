import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/morphing_effect/helper.dart';
import 'package:mobile_custom_ui/screens/morphing_effect/morphing_object.dart';
import 'package:mobile_custom_ui/screens/morphing_effect/morphing_shapes.dart';
import 'package:mobile_custom_ui/screens/morphing_effect/shape_widget.dart';

class MorphingEffectScreen extends StatefulWidget {
  const MorphingEffectScreen({super.key});

  @override
  State<MorphingEffectScreen> createState() => _MorphingEffectScreenState();
}

class _MorphingEffectScreenState extends State<MorphingEffectScreen> {
  late Path path_0;

  @override
  void initState() {
    super.initState();
  }

  // TODO: Implement extractCubicPoints function or define shape1 directly
  // static const List<Offset> shape1 = [];
  final List<List<CubicControlPoint>> defaultShapes = [
    svgPathToCubicPoints(path0),
    svgPathToCubicPoints(path1),
    svgPathToCubicPoints(path2),
    svgPathToCubicPoints(path3),
    svgPathToCubicPoints(path5),
    svgPathToCubicPoints(path6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pizza Topping Picker')),
      body: Align(
        // alignment: Alignment.topCenter,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: (MediaQuery.of(context).size.width - 200) / 2,
                top: 0,
                child: MorphingObject(shapes: defaultShapes),
              ),
              // CustomPaint(size: const Size(200, 146), painter: Shape1()),
            ],
          ),
        ),
      ),
    );
  }
}
