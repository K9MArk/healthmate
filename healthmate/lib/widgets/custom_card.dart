import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const CustomCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4.0),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (icon != null) ...[
                CircleAvatar(
                  backgroundColor: (iconColor ?? Theme.of(context).primaryColor)
                      .withOpacity(0.1),
                  foregroundColor: iconColor ?? Theme.of(context).primaryColor,
                  child: Icon(icon),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
