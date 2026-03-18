import 'package:flutter/material.dart';
import '../dto/post_dto.dart';
import '../dto/comment_dto.dart';
import '../service/post_service.dart';
import '../service/post_service_impl.dart';
import '../widgets/comment_tile.dart';
import 'post_edit_screen.dart';

class DetailScreen extends StatefulWidget {
  final int postId;
  const DetailScreen({super.key, required this.postId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PostService _postService = PostServiceImpl();
  late Future<PostDto> _postFuture;
  late Future<List<CommentDto>> _commentsFuture;
  final TextEditingController _commentController = TextEditingController();

  static const Color bgDark = Color(0xFF121212);
  static const Color contentDark = Color(0xFF1E1E1E);
  static const Color accentPurple = Color(0xFF9D50BB);

  // 현재 테스트 중인 유저 번호 (서버 DB와 일치해야 함)
  final int _myUserNum = 123;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _postFuture = _postService.getPostDetail(widget.postId);
      _commentsFuture = _postService.getComments(widget.postId);
    });
  }

  // --- 게시글 관리 로직 ---
  void _handleEditPost(PostDto post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostEditScreen(post: post)),
    );
    if (result == true) _loadData();
  }

  Future<void> _handleDeletePost() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: contentDark,
        title: const Text("게시글 삭제", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("정말 이 게시글을 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소", style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await _postService.deletePost(widget.postId, _myUserNum);
      if (success) {
        _showMsg("게시글이 삭제되었습니다.");
        Navigator.pop(context, true);
      } else {
        _showMsg("삭제 권한이 없거나 실패했습니다.");
      }
    }
  }

  // --- 댓글 관리 로직 ---
  Future<void> _handleCommentSubmit() async {
    String text = _commentController.text.trim();
    if (text.isEmpty) return;
    bool success = await _postService.insertComment(text, widget.postId, _myUserNum);
    if (success) {
      _commentController.clear();
      _loadData();
      _showMsg("댓글이 등록되었습니다.");
      FocusScope.of(context).unfocus();
    } else {
      _showMsg("댓글 등록에 실패했습니다.");
    }
  }

  Future<void> _handleDeleteComment(CommentDto comment) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: contentDark,
        title: const Text("댓글 삭제", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("정말 이 댓글을 삭제하시겠습니까?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소", style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      bool success = await _postService.deleteComment(comment.commentId, _myUserNum);
      if (success) {
        _showMsg("댓글이 삭제되었습니다.");
        _loadData();
      } else {
        _showMsg("삭제 권한이 없거나 실패했습니다.");
      }
    }
  }

  Future<void> _handleUpdateComment(CommentDto comment, String newContent) async {
    if (newContent.trim().isEmpty) return;
    bool success = await _postService.updateComment(comment.commentId, _myUserNum, newContent);
    if (success) {
      _showMsg("댓글이 수정되었습니다.");
      _loadData();
    } else {
      _showMsg("수정 권한이 없거나 실패했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PostDto>(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(backgroundColor: bgDark, body: const Center(child: CircularProgressIndicator(color: accentPurple)));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(backgroundColor: bgDark, body: const Center(child: Text("오류가 발생했습니다.", style: TextStyle(color: Colors.white54))));
        }

        final post = snapshot.data!;

        return Scaffold(
          backgroundColor: bgDark,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            title: const Text("상세보기", style: TextStyle(fontSize: 16, color: Colors.white70)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(post),
                _buildPostContent(post),
                _buildReactionSection(post),
                Container(height: 8, color: Colors.black),
                _buildCommentHeader(post.commentCnt),

                FutureBuilder<List<CommentDto>>(
                  future: _commentsFuture,
                  builder: (context, commentSnapshot) {
                    if (commentSnapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: accentPurple)));
                    }
                    final comments = commentSnapshot.data ?? [];
                    if (comments.isEmpty) {
                      return const Padding(padding: EdgeInsets.all(30.0), child: Center(child: Text("등록된 댓글이 없습니다.", style: TextStyle(color: Colors.white54))));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length, // ✅ 필수 추가됨
                      itemBuilder: (context, index) {
                        final comment = comments[index];

                        debugPrint("---------- [댓글 권한 체크] ----------");
                        debugPrint("내 로그인 번호: $_myUserNum");
                        debugPrint("댓글 작성자 번호: ${comment.userNum}");

                        final bool isAuthor = comment.userNum == _myUserNum;

                        return CommentTile(
                          comment: comment,
                          // ✅ isAuthor가 true일 때만 콜백 함수를 전달합니다.
                          onDelete: isAuthor ? () => _handleDeleteComment(comment) : null,
                          onEdit: isAuthor ? (newContent) => _handleUpdateComment(comment, newContent) : null,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomSheet: _buildCommentInput(),
        );
      },
    );
  }

  // --- UI 헬퍼 함수들 ---

  Widget _buildPostHeader(PostDto post) {
    bool isAuthor = post.userNum == _myUserNum;

    return Container(
      color: contentDark,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 14, backgroundColor: accentPurple, child: Icon(Icons.person, size: 16, color: Colors.white)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("조회 ${post.viewCnt} · ${post.createdAt}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              if (isAuthor)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _handleEditPost(post),
                      child: const Text("수정", style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("|", style: TextStyle(color: Colors.white12, fontSize: 13)),
                    ),
                    GestureDetector(
                      onTap: _handleDeletePost,
                      child: const Text("삭제", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white10, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 5, top: 10, bottom: MediaQuery.of(context).viewInsets.bottom + 10),
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "댓글을 입력하세요...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _handleCommentSubmit(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: accentPurple), onPressed: _handleCommentSubmit),
        ],
      ),
    );
  }

  Widget _buildPostContent(PostDto post) {
    return Container(
      color: contentDark,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(post.content, style: const TextStyle(fontSize: 16, height: 1.8, color: Color(0xFFE0E0E0))),
    );
  }

  // ✅ 스크랩 버튼을 지우고 추천 버튼만 남겼습니다.
  Widget _buildReactionSection(PostDto post) {
    return Container(
      color: contentDark,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
        children: [
          GestureDetector(
            onTap: () async {
              bool success = await _postService.pushLike(widget.postId, _myUserNum);
              if (success) {
                _loadData();
                _showMsg("추천되었습니다!");
              } else {
                _showMsg("이미 추천한 게시글입니다.");
              }
            },
            child: _reactionButton(Icons.thumb_up_alt, "추천 ${post.likeCnt}", Colors.orangeAccent),
          ),
          // ❌ 스크랩 버튼(Star Icon)과 SizedBox 간격 삭제됨
        ],
      ),
    );
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  Widget _reactionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCommentHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text("댓글", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text("$count", style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}