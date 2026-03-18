import 'package:flutter/material.dart';
import '../dto/comment_dto.dart';

class CommentTile extends StatelessWidget {
  final CommentDto comment;
  final String nickname; // 나중에 서버에서 가져올 수도 있음
  final VoidCallback? onDelete;
  final Function(String newContent)? onEdit;

  const CommentTile({
    super.key,
    required this.comment,
    required this.nickname,
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
              // 닉네임 + 시간
              Row(
                children: [
                  Text(nickname, style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  )
                  ),
                  const SizedBox(width: 8),
                  Text(formatTime(comment.createdAt), style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  )),
                ],
              ),

              // 수정/삭제 버튼 (작성자인 경우만 표시 가능)
              Row(
                children: [
                  if (onEdit != null)
                    GestureDetector(
                      onTap: () {
                        // Dialog로 수정 내용 입력 후 onEdit 호출
                        showDialog(
                          context: context,
                          builder: (context) {
                            final controller = TextEditingController(text: comment.content);
                            return AlertDialog(
                              title: const Text("댓글 수정"),
                              content: TextField(controller: controller),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onEdit!(controller.text);
                                  },
                                  child: const Text("수정"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.edit, size: 18, color: Colors.white54),
                    ),
                  const SizedBox(width: 8),
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

          // 댓글 내용
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
}