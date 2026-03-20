import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  bool _isLoading = false;      // 저장 중 상태
  bool _isUserLoading = true;   // 유저 정보 가져오는 중 상태
  int? _resolvedUserNum;        // DB에서 조회한 실제 유저 번호

  String _selectedBoard = "해외";
  String _selectedCategory = "리뷰";

  final List<String> _boards = ["해외", "국내", "자유"];
  final Map<String, List<String>> _categoriesByBoard = {
    "해외": ["리뷰", "정보", "질문", "추천"],
    "국내": ["리뷰", "정보", "질문", "추천"],
    "자유": ["질문", "잡담"],
  };

  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color accentIndigo = Colors.indigoAccent;

  @override
  void initState() {
    super.initState();
    _prepareUserInfo();
  }

  Future<void> _prepareUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() { _resolvedUserNum = -1; _isUserLoading = false; });
      } else {
        int num = await _postService.getUserNumByUid(user.uid);
        if (mounted) setState(() { _resolvedUserNum = num; _isUserLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _resolvedUserNum = -1; _isUserLoading = false; });
    }
  }

  void _onBoardChange(String board) {
    setState(() {
      _selectedBoard = board;
      _selectedCategory = _categoriesByBoard[board]![0];
    });
  }

  Future<void> _handleSavePost() async {
    print("현재 유저 번호 확인: $_resolvedUserNum");

    if (_resolvedUserNum == null || _resolvedUserNum! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("유저 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.")),
      );
      return;
    }

    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목과 내용을 모두 입력해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _postService.insertPost(
      title,
      content,
      _resolvedUserNum!,
      boardType: _selectedBoard,
      category: _selectedCategory,
    );

    if (mounted) setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("게시글이 등록되었습니다.")),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("등록에 실패했습니다. 다시 시도해주세요.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUserLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("글 쓰기",
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSavePost,
            child: Text(_isLoading ? "..." : "완료",
                style: const TextStyle(color: accentIndigo, fontWeight: FontWeight.bold, fontSize: 16)),
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
          _buildSettingsSection(),
          const Divider(height: 1, color: Colors.black12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: "제목을 입력하세요",
                    hintStyle: TextStyle(color: Colors.black26),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                const Divider(height: 1, color: Colors.black12),
                TextField(
                  controller: _contentController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                  decoration: const InputDecoration(
                    hintText: "내용을 입력하세요",
                    hintStyle: TextStyle(color: Colors.black26),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: bgLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("게시판 선택",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 10),
          Row(
            children: _boards.map((board) => _buildSelectChip(
              label: board,
              isSelected: _selectedBoard == board,
              onTap: () => _onBoardChange(board),
            )).toList(),
          ),
          const SizedBox(height: 20),

          const Text("말머리 선택",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categoriesByBoard[_selectedBoard]!.map((cat) => _buildSelectChip(
              label: cat,
              isSelected: _selectedCategory == cat,
              onTap: () => setState(() => _selectedCategory = cat),
              isSmall: true,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isSmall = false
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentIndigo : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? accentIndigo : Colors.black12),
          boxShadow: isSelected
              ? [BoxShadow(color: accentIndigo.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: isSmall ? 12 : 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}