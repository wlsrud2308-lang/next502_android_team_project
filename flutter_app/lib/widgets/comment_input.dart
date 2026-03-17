import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentInput extends StatefulWidget {
  final Function(String content) onSubmit;

  const CommentInput({
    super.key,
    required this.onSubmit,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();

  void submit() {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        children: [

          // 입력창
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "따뜻한 댓글을 남겨주세요",
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),

          // 등록 버튼
          GestureDetector(
            onTap: submit,
            child: const Text(
              "등록",
              style: TextStyle(
                color: Colors.purpleAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}