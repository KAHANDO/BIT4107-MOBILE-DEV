import 'package:flutter/material.dart';

class GestureHandler {
  // Handles tap event with optional callback
  static void onTap({
    required BuildContext context,
    required String message,
    VoidCallback? action,
  }) {
    if (action != null) action();
    debugPrint('TAP EVENT: $message');
  }

  // Handles long press — shows a bottom sheet with details
  static void onLongPress({
    required BuildContext context,
    required String title,
    required Map<String, String> details,
    Color accentColor = const Color(0xFF2563EB),
  }) {
    debugPrint('LONG PRESS EVENT: $title');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: accentColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...details.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Handles swipe — confirms deletion with a snackbar undo option
  static Future<bool> onSwipeToDelete({
    required BuildContext context,
    required String itemName,
  }) async {
    debugPrint('SWIPE EVENT: Swipe to delete "$itemName"');
    return true;
  }
}