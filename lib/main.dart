import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/custom_reorderable_grid_view/custom_reorderable_grid_view.dart';
import 'package:mobile_custom_ui/screens/drag_n_drop_object/basic_dragging.dart';
import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/reorderable_words.dart';
import 'package:mobile_custom_ui/screens/duolingo_sentence_completion/sentence_completion_game_3.dart';
import 'package:mobile_custom_ui/screens/library/library_screen.dart';
import 'package:mobile_custom_ui/screens/sliding_text_box/sliding_text_box_screen.dart';
import 'screens/ball_bouncing/ball_bouncing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SlidingTextBoxScreen(), // Render the bouncing balls screen
    );
  }
}
