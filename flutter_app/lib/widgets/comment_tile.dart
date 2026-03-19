import 'package:flutter/material.dart';
import '../dto/comment_dto.dart';

class CommentTile extends StatelessWidget {
  final CommentDto comment;
  final VoidCallback? onDelete;
  final Function(String newContent)? onEdit;
  final VoidCallback? onReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.onDelete,
    this.onEdit,
    this.onReply,
  });

  String formatTime(DateTime? time) {
    if (time == null) return "";
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return "방금 전";
    if (diff.inMinutes < 60) return "${diff.inMinutes}분 전";
    if (diff.inHours < 24) return "${diff.inHours}시간 전";
    return "${diff.inDays}일 전";
  }

  @override
  Widget build(BuildContext context) {
    final bool isReply = comment.targetId != null && comment.targetId != 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isReply ? Colors.white.withOpacity(0.02) : Colors.transparent,
        border: const Border(
          bottom: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReply)
            const Padding(
              padding: EdgeInsets.only(right: 8.0, top: 2.0),
              child: Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.white24),
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.nickname,
                          style: TextStyle(
                            color: isReply ? Colors.white70 : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTime(comment.createdAt),
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (onEdit != null)
                          GestureDetector(
                            onTap: () => _showEditDialog(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.edit_outlined, size: 16, color: Colors.white38),
                            ),
                          ),
                        if (onDelete != null)
                          GestureDetector(
                            onTap: onDelete,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.delete_outline, size: 16, color: Colors.white38),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 8),

                if (onReply != null && !isReply)
                  GestureDetector(
                    onTap: onReply,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Text(
                        "답글 달기",
                        style: TextStyle(
                          color: Color(0xFF9D50BB),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("댓글 수정", style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "수정할 내용을 입력하세요",
              hintStyle: TextStyle(color: Colors.white24),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF9D50BB))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  onEdit!(controller.text.trim());
                }
              },
              child: const Text("수정", style: TextStyle(color: Color(0xFF9D50BB), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}