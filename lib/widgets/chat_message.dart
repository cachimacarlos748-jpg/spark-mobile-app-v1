import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatMessage extends StatelessWidget {
  final String role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = role == 'user';
    final isError = role == 'error';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && !isError) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isError
                        ? Colors.red.withOpacity(0.1)
                        : isUser
                            ? const Color(0xFF3B82F6)
                            : isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isError
                          ? Colors.red
                          : isUser
                              ? Colors.transparent
                              : isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: isError
                      ? Text(
                          content,
                          style: const TextStyle(color: Colors.red),
                        )
                      : role == 'system'
                          ? Text(
                              content,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isUser ? Colors.white : null,
                                  ),
                            )
                          : MarkdownBody(
                              data: content,
                              styleSheet: MarkdownStyleSheet(
                                p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isUser ? Colors.white : null,
                                    ),
                                code: TextStyle(
                                  backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
                                  color: isUser ? Colors.white : null,
                                ),
                              ),
                            ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 12),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
