import 'package:flutter/material.dart';
import '../dto/comment_dto.dart';

class CommentTile extends StatelessWidget {
  final CommentDto comment;
  final VoidCallback? onDelete;
  final Function(String newContent)? onEdit;

  const CommentTile({
    super.key,
    required this.comment,
    this.onDelete,
    this.onEdit,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatTime(comment.createdAt),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  if (onEdit != null)
                    GestureDetector(
                      onTap: () => _showEditDialog(context),
                      child: const Icon(Icons.edit, size: 18, color: Colors.white54),
                    ),
                  const SizedBox(width: 12),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete, size: 18, color: Colors.white54),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            comment.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
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
          title: const Text("댓글 수정", style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "수정할 내용을 입력하세요",
              hintStyle: TextStyle(color: Colors.white24),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
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