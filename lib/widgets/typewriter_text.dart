import 'dart:async';
import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
    this.duration = const Duration(milliseconds: 50),
  });
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Duration duration;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _currentIndex = 0;
      _displayedText = '';
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    _timer?.cancel();
    final chars = widget.text.characters;
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_currentIndex < chars.length) {
        setState(() {
          _currentIndex++;
          _displayedText = chars.take(_currentIndex).toString();
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
