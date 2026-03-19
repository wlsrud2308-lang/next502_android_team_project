import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../service/post_service.dart';
import '../service/post_service_impl.dart';
import '../widgets/comment_tile.dart';
import 'post_edit_screen.dart';
import 'login_screen.dart';

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
  final FocusNode _commentFocusNode = FocusNode();

  int? _replyToCommentId;
  String? _replyToNickname;

  // 🔥 Firebase 연동 상태 변수
  int? _resolvedUserNum;
  bool _isUserLoading = true;

  static const Color bgDark = Color(0xFF121212);
  static const Color contentDark = Color(0xFF1E1E1E);
  static const Color accentPurple = Color(0xFF9D50BB);

  int get _myUserNum => _resolvedUserNum ?? -1;

  @override
  void initState() {
    super.initState();
    _prepareUserInfo();
  }

  Future<void> _prepareUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("⚠️ [Auth] 로그인된 파이어베이스 유저가 없습니다.");
        if (mounted) {
          setState(() {
            _resolvedUserNum = -1;
            _isUserLoading = false;
          });
        }
      } else {
        print("✅ [Auth] UID 발견: ${user.uid}. 서버에서 번호 조회 시작...");

        int num = await _postService.getUserNumByUid(user.uid);

        print("✅ [Server] 조회된 userNum: $num");

        if (mounted) {
          setState(() {
            _resolvedUserNum = num;
            _isUserLoading = false;
          });
        }
      }
    } catch (e) {
      print("❌ [UserInfo 에러] 원인: $e");
      if (mounted) {
        setState(() {
          _resolvedUserNum = -1;
          _isUserLoading = false;
        });
      }
    }

    _loadData();
  }
  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _postFuture = _postService.getPostDetail(widget.postId);
      _commentsFuture = _postService.getComments(widget.postId);
    });
  }


  void _onReplyRequested(CommentDto parentComment) {
    setState(() {
      _replyToCommentId = parentComment.commentId;
      _replyToNickname = parentComment.nickname;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToNickname = null;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: contentDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("로그인 필요", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text("이 서비스는 로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?",
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(title: "로그인")));
            },
            child: const Text("로그인하기", style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCommentSubmit() async {
    if (_myUserNum <= 0) {
      _showLoginDialog();
      return;
    }

    String text = _commentController.text.trim();
    if (text.isEmpty) return;

    bool success = await _postService.insertComment(
        text,
        widget.postId,
        _myUserNum,
        "POST",
        targetId: _replyToCommentId
    );

    if (success) {
      _commentController.clear();
      _cancelReply();
      _loadData();
      _showMsg(_replyToCommentId == null ? "댓글이 등록되었습니다." : "답글이 등록되었습니다.");
      FocusScope.of(context).unfocus();
    } else {
      _showMsg("댓글 등록에 실패했습니다.");
    }
  }

  Future<void> _handleDeletePost() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: contentDark,
        title: const Text("게시글 삭제", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("정말 이 게시글을 삭제하시겠습니까?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소", style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      bool success = await _postService.deletePost(widget.postId, _myUserNum);
      if (success) { Navigator.pop(context, true); }
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
      if (success) _loadData();
    }
  }

  Future<void> _handleUpdateComment(CommentDto comment, String newContent) async {
    if (newContent.trim().isEmpty) return;
    bool success = await _postService.updateComment(comment.commentId, _myUserNum, newContent);
    if (success) _loadData();
  }

  void _handleEditPost(PostDto post) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PostEditScreen(post: post)));
    if (result == true) _loadData();
  }


  @override
  Widget build(BuildContext context) {
    if (_isUserLoading) {
      return const Scaffold(backgroundColor: bgDark, body: Center(child: CircularProgressIndicator(color: accentPurple)));
    }

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
        bool isPostAuthor = post.userNum == _myUserNum;

        return Scaffold(
          backgroundColor: bgDark,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            title: Text("${post.boardType ?? '게시판'} 상세보기", style: const TextStyle(fontSize: 16, color: Colors.white70)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(post, isPostAuthor),
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
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final bool isAuthor = comment.userNum == _myUserNum;
                        final bool isReply = comment.targetId != null && comment.targetId != 0;

                        return Padding(
                          padding: EdgeInsets.only(left: isReply ? 30.0 : 0.0),
                          child: CommentTile(
                            comment: comment,
                            onDelete: isAuthor ? () => _handleDeleteComment(comment) : null,
                            onEdit: isAuthor ? (newContent) => _handleUpdateComment(comment, newContent) : null,
                            onReply: () => _onReplyRequested(comment),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          bottomSheet: _buildCommentInput(),
        );
      },
    );
  }

  // ====================== UI 컴포넌트 ======================

  Widget _buildPostHeader(PostDto post, bool isAuthor) {
    return Container(
      color: contentDark,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadge(post.boardType ?? "전체", Colors.blueAccent),
              const SizedBox(width: 6),
              _buildBadge(post.category ?? "잡담", Colors.orangeAccent.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 12),
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
                    GestureDetector(onTap: () => _handleEditPost(post), child: const Text("수정", style: TextStyle(color: Colors.white54, fontSize: 13))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("|", style: TextStyle(color: Colors.white12, fontSize: 13))),
                    GestureDetector(onTap: _handleDeletePost, child: const Text("삭제", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500))),
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

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildReactionSection(PostDto post) {
    return Container(
      color: contentDark,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              if (_myUserNum <= 0) { _showLoginDialog(); return; }
              bool success = await _postService.pushLike(widget.postId, _myUserNum);
              if (success) { _loadData(); _showMsg("추천되었습니다!"); } else { _showMsg("이미 추천한 게시글입니다."); }
            },
            child: _reactionButton(Icons.thumb_up_alt, "추천 ${post.likeCnt}", Colors.orangeAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [const Text("댓글", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text("$count", style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildCommentInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyToCommentId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: accentPurple.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.reply, size: 16, color: accentPurple),
                const SizedBox(width: 8),
                Expanded(child: Text("$_replyToNickname님에게 답글 작성 중...", style: const TextStyle(color: accentPurple, fontSize: 12))),
                GestureDetector(onTap: _cancelReply, child: const Icon(Icons.close, size: 16, color: Colors.white54)),
              ],
            ),
          ),
        Container(
          padding: EdgeInsets.only(left: 15, right: 5, top: 10, bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          color: const Color(0xFF1A1A1A),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _replyToCommentId == null ? "댓글을 입력하세요..." : "답글을 입력하세요...",
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
        ),
      ],
    );
  }

  Widget _reactionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))]),
    );
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }
}