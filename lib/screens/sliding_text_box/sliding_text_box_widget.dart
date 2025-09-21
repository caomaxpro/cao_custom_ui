import 'package:flutter/material.dart';

class SlidingTextBox extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final String text;
  final TextStyle textStyle;
  final double innerPadding;
  final Color innerBoxColor;
  final Duration duration;

  const SlidingTextBox({
    super.key,
    this.width = 300,
    this.height = 100,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.padding = const EdgeInsets.all(10),
    this.text = 'This is the example text..............................Hello',
    this.textStyle = const TextStyle(fontSize: 20),
    this.innerPadding = 10,
    this.innerBoxColor = Colors.lightBlueAccent,
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<SlidingTextBox> createState() => _SlidingTextBoxState();
}

class _SlidingTextBoxState extends State<SlidingTextBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final GlobalKey _textKey = GlobalKey();
  double _textWidth = 0;
  double _textHeight = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTextWidthAndAnimate();
    });
  }

  void _getTextWidthAndAnimate() {
    final RenderBox? renderBox =
        _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      debugPrint('RenderBox found!');
      setState(() {
        _textWidth = renderBox.size.width;
        _textHeight = renderBox.size.height;
        debugPrint('Measured text width: $_textWidth');
        debugPrint('Measured text height: $_textHeight');
      });
      _startSliding();
    } else {
      debugPrint('RenderBox NOT found!');
    }
  }

  void _startSliding() {
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double mainContainerWidth = widget.width - widget.padding.horizontal;

    return Container(
      padding: widget.padding,
      width: widget.width,
      height: widget.height,
      color: widget.backgroundColor,
      child: ClipRect(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final double maxSlide = (_textWidth > mainContainerWidth)
                    ? _textWidth - mainContainerWidth
                    : 0;
                final double left = -maxSlide * _animationController.value;
                return Positioned(
                  left: left,
                  top:
                      (widget.height - _textHeight - widget.padding.vertical) /
                      2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.innerPadding,
                    ),
                    key: _textKey,
                    height: _textHeight > 0 ? _textHeight : null,
                    alignment: Alignment.centerLeft,
                    color: widget.innerBoxColor,
                    child: Text(
                      widget.text,
                      style: widget.textStyle,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
