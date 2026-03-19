import 'package:flutter/material.dart';
import '../models/post_model.dart';
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

  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color pointBlue = Colors.blueAccent;

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
      _showSnackBar("제목과 내용을 모두 입력해주세요.");
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
      boardType: widget.post.boardType,
    );

    bool success = await _postService.updatePost(updatedPost);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar("게시글이 수정되었습니다.");
      Navigator.pop(context, true);
    } else {
      _showSnackBar("게시글 수정에 실패했습니다.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF333333),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("글 수정",
            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleUpdatePost,
            child: Text(
              _isLoading ? "저장 중" : "완료",
              style: TextStyle(
                color: _isLoading ? Colors.black26 : pointBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black12, height: 1),
        ),
      ),
      body: Column(
        children: [
          // 제목 입력란
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
              decoration: const InputDecoration(
                hintText: "제목을 입력하세요",
                hintStyle: TextStyle(color: Colors.black26),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const Divider(color: Color(0xFFEEEEEE), thickness: 1, indent: 20, endIndent: 20),

          // 내용 입력란
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                style: const TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 16,
                    height: 1.6
                ),
                decoration: const InputDecoration(
                  hintText: "내용을 입력하세요",
                  hintStyle: TextStyle(color: Colors.black26),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}