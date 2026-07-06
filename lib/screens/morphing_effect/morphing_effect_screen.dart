import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/morphing_effect/morphing_shapes.dart';
import 'package:mobile_custom_ui/screens/morphing_effect/svg_morphing_widget.dart';

class MorphingEffectScreen extends StatefulWidget {
  const MorphingEffectScreen({super.key});

  @override
  State<MorphingEffectScreen> createState() => _MorphingEffectScreenState();
}

class _MorphingEffectScreenState extends State<MorphingEffectScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Pizza Topping Picker')),
      body: Align(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: (screenWidth - 200) / 2,
                top: 0,
                child: SvgMorphingWidget(
                  svgPaths: [path0, path1, path2, path3, path5, path6],
                  size: const Size(200, 300),
                  color: Colors.blue,
                  duration: const Duration(seconds: 5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
