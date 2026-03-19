import 'package:flutter/material.dart';
import '../models/comment_model.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isReply ? const Color(0xFFF9F9F9) : Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReply)
            const Padding(
              padding: EdgeInsets.only(right: 10.0, top: 2.0),
              child: Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.black12),
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
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTime(comment.createdAt),
                          style: const TextStyle(color: Colors.black26, fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (onEdit != null)
                          _actionIcon(Icons.edit_outlined, () => _showEditDialog(context)),
                        if (onDelete != null)
                          _actionIcon(Icons.delete_outline, onDelete!),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(color: Color(0xFF444444), fontSize: 14, height: 1.5),
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
                          color: Colors.blueAccent,
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

  Widget _actionIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, size: 16, color: Colors.black26),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("댓글 수정", style: TextStyle(color: Color(0xFF333333), fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Color(0xFF333333)),
            decoration: const InputDecoration(
              hintText: "수정할 내용을 입력하세요",
              hintStyle: TextStyle(color: Colors.black26),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소", style: TextStyle(color: Colors.black38)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  onEdit!(controller.text.trim());
                }
              },
              child: const Text("수정", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}