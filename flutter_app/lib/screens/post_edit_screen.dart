import 'package:flutter/material.dart';
import '../dto/post_dto.dart';
import '../service/post_service.dart';
import '../service/post_service_impl.dart';

class PostEditScreen extends StatefulWidget {
  final PostDto post;
  const PostEditScreen({super.key, required this.post});

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  final PostService _postService = PostServiceImpl();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  static const Color bgDark = Color(0xFF121212);
  static const Color accentPurple = Color(0xFF9D50BB);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePost() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목과 내용을 모두 입력해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final updatedPost = PostDto(
      postId: widget.post.postId,
      userNum: widget.post.userNum,
      title: title,
      content: content,
      authorName: widget.post.authorName,
      viewCnt: widget.post.viewCnt,
      likeCnt: widget.post.likeCnt,
      commentCnt: widget.post.commentCnt,
      createdAt: widget.post.createdAt,
    );

    bool success = await _postService.updatePost(updatedPost);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("게시글이 수정되었습니다."), behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("게시글 수정에 실패했습니다."), behavior: SnackBarBehavior.floating),
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
        title: const Text("글 수정", style: TextStyle(fontSize: 16, color: Colors.white70)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleUpdatePost,
            child: Text(
              _isLoading ? "수정 중..." : "완료",
              style: TextStyle(
                color: _isLoading ? Colors.white24 : accentPurple,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
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