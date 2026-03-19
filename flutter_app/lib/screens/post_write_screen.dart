import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../service/post_service.dart';
import '../service/post_service_impl.dart';

class PostWriteScreen extends StatefulWidget {
  const PostWriteScreen({super.key});

  @override
  State<PostWriteScreen> createState() => _PostWriteScreenState();
}

class _PostWriteScreenState extends State<PostWriteScreen> {
  final PostService _postService = PostServiceImpl();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  static const Color bgDark = Color(0xFF121212);
  static const Color contentDark = Color(0xFF1E1E1E);
  static const Color accentPurple = Color(0xFF9D50BB);

  final int _myUserNum = 3;

  Future<void> _handleSavePost() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목과 내용을 모두 입력해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _postService.insertPost(title, content, _myUserNum);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("게시글이 등록되었습니다.")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("게시글 등록에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text("글쓰기", style: TextStyle(fontSize: 16, color: Colors.white70)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSavePost,
            child: Text(
              _isLoading ? "저장 중..." : "등록",
              style: const TextStyle(color: accentPurple, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "제목을 입력하세요",
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Colors.white12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                decoration: const InputDecoration(
                  hintText: "내용을 입력하세요",
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}