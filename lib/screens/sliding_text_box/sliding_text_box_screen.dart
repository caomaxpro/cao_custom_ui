import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/sliding_text_box/sliding_text_box_widget.dart';

class SlidingTextBoxScreen extends StatelessWidget {
  const SlidingTextBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sliding Text Box')),
      body: Align(
        alignment: Alignment.topLeft,
        child: SlidingTextBox(
          text:
              "Flutter is an open-source UI software development toolkit created by Google. It is used to develop cross platform applications for Android, iOS, Linux, macOS, Windows, and web from a single codebase. This is a long text to test the sliding effect of the SlidingTextBox widget. Enjoy watching the text smoothly slide back and forth!",
          width: MediaQuery.of(context).size.width,
          height: 60,
          duration: Duration(seconds: 100),
        ),
      ),
    );
  }
}
