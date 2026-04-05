import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';

class ShowTagWidget extends StatelessWidget {
  final String tagName;
  final IconData icon;
  final Color color;
  final VoidCallback? onDelete;

  const ShowTagWidget({
    super.key,
    required this.tagName,
    required this.icon,
    required this.color,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // // Design: Using a Container instead of Card for more control over decoration
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // // Visual: Subtle background color based on the tag color with low opacity
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          // // UI: Icon wrapper with a soft circular background
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 16),

          // // Layout: Expanded text to push the delete button to the end
          Expanded(
            child: Text(
              tagName,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // // Logic: Implementing the delete action with visual feedback
          if (onDelete != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white30,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
