import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/bouncing_text_box/bouncing_text_box.dart';

// BouncingTextBox(
//           text:
//               "Flutter is an open-source UI software development toolkit created by Google. It is used to develop cross platform applications for Android, iOS, Linux, macOS, Windows, and web from a single codebase. This is a long text to test the sliding effect of the SlidingTextBox widget. Enjoy watching the text smoothly slide back and forth!",
//           width: MediaQuery.of(context).size.width,
//           height: 60,
//           duration: Duration(seconds: 100),
//         )

class BouncingTextBoxScreen extends StatelessWidget {
  const BouncingTextBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sliding Text Box')),
      body: Align(
        alignment: Alignment.topLeft,
        child: BouncingTextBox(
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
