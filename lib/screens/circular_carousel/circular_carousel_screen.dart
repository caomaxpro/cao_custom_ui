import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/circular_carousel/circular_carousel.dart';

// ignore: must_be_immutable
class CircularCarouselScreen extends StatefulWidget {
  const CircularCarouselScreen({super.key});

  @override
  State<CircularCarouselScreen> createState() => _CircularCarouselScreenState();
}

class _CircularCarouselScreenState extends State<CircularCarouselScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Circular Carousel')),
      body: Align(
        alignment: Alignment.bottomLeft,
        child: CircularCarousel(
          width: MediaQuery.of(context).size.width,
          height: 250,
          radius: 350,
          center: Offset(MediaQuery.of(context).size.width / 2, 250 / 2 - 330),
        ),
      ),
    );
  }
}
