import 'package:flutter/material.dart';

class ReusableButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final TextStyle? textStyle;
  final ButtonStyle? style;
  final bool isEnabled;

  const ReusableButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textStyle,
    this.style,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null, 
      style: style ??
          ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
      child: Text(
        text,
        style: textStyle ?? const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
