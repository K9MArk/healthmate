import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool outlined;
  final Color color;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.color = Colors.blue,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 20),
        if (icon != null) const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );

    if (outlined) {
      return SizedBox(
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color),
            foregroundColor: color,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        child: child,
      ),
    );
  }
}
