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

  int? _resolvedUserNum;
  bool _isUserLoading = true;

  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color pointBlue = Colors.blueAccent;

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
        if (mounted) setState(() { _resolvedUserNum = -1; _isUserLoading = false; });
      } else {
        int num = await _postService.getUserNumByUid(user.uid);
        if (mounted) setState(() { _resolvedUserNum = num; _isUserLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _resolvedUserNum = -1; _isUserLoading = false; });
    }
    _loadData();
  }

  void _loadData() {
    setState(() {
      _postFuture = _postService.getPostDetail(widget.postId);
      _commentsFuture = _postService.getComments(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: const Color(0xFF333333),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 90),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text("로그인 필요", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("로그인이 필요한 서비스입니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.black38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(title: "로그인")));
            },
            child: const Text("로그인", style: TextStyle(color: pointBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCommentSubmit() async {
    if (_myUserNum <= 0) { _showLoginDialog(); return; }
    String text = _commentController.text.trim();
    if (text.isEmpty) return;
    bool success = await _postService.insertComment(text, widget.postId, _myUserNum, "POST", targetId: _replyToCommentId);
    if (success) {
      _commentController.clear();
      _cancelReply();
      _loadData();
      FocusScope.of(context).unfocus();
    }
  }

  void _onReplyRequested(CommentDto parent) {
    setState(() {
      _replyToCommentId = parent.commentId;
      _replyToNickname = parent.nickname;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToNickname = null;
    });
  }

  Future<void> _handleDeletePost() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text("삭제 확인"),
        content: const Text("정말 이 게시글을 삭제하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소", style: TextStyle(color: Colors.black38))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      bool success = await _postService.deletePost(widget.postId, _myUserNum);
      if (success) Navigator.pop(context, true);
    }
  }

  Future<void> _handleDeleteComment(CommentDto c) async {
    bool success = await _postService.deleteComment(c.commentId, _myUserNum);
    if (success) _loadData();
  }

  Future<void> _handleUpdateComment(CommentDto c, String n) async {
    if (n.trim().isEmpty) return;
    bool success = await _postService.updateComment(c.commentId, _myUserNum, n);
    if (success) _loadData();
  }

  void _handleEditPost(PostDto p) async {
    final r = await Navigator.push(context, MaterialPageRoute(builder: (context) => PostEditScreen(post: p)));
    if (r == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isUserLoading) {
      return const Scaffold(backgroundColor: bgLight, body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return FutureBuilder<PostDto>(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(backgroundColor: bgLight, body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(backgroundColor: bgLight, body: Center(child: Text("게시글을 불러올 수 없습니다.")));
        }

        final post = snapshot.data!;
        bool isPostAuthor = post.userNum == _myUserNum;

        return Scaffold(
          backgroundColor: bgLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text("${post.boardType ?? '게시판'} 상세보기", style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.black12, height: 1),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(post, isPostAuthor),
                _buildPostContent(post),
                _buildReactionSection(post),
                Container(height: 8, color: Colors.black.withOpacity(0.03)),
                _buildCommentHeader(post.commentCnt),

                FutureBuilder<List<CommentDto>>(
                  future: _commentsFuture,
                  builder: (context, commentSnapshot) {
                    final comments = commentSnapshot.data ?? [];
                    if (comments.isEmpty) {
                      return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text("등록된 댓글이 없습니다.", style: TextStyle(color: Colors.black26))));
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.black12, height: 1),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final bool isReply = comment.targetId != null && comment.targetId != 0;
                        return Padding(
                          padding: EdgeInsets.only(left: isReply ? 30.0 : 0.0),
                          child: CommentTile(
                            comment: comment,
                            onDelete: comment.userNum == _myUserNum ? () => _handleDeleteComment(comment) : null,
                            onEdit: comment.userNum == _myUserNum ? (newContent) => _handleUpdateComment(comment, newContent) : null,
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

  Widget _buildPostHeader(PostDto post, bool isAuthor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.movie_outlined, size: 16, color: Colors.black12),
              const SizedBox(width: 8),
              Text(post.authorName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(width: 10),
              Text(post.createdAt, style: const TextStyle(color: Colors.black26, fontSize: 12)),
              const Spacer(),
              if (isAuthor) ...[
                GestureDetector(onTap: () => _handleEditPost(post), child: const Text("수정", style: TextStyle(color: Colors.black38, fontSize: 13))),
                const Text("  ·  ", style: TextStyle(color: Colors.black12)),
                GestureDetector(onTap: _handleDeletePost, child: const Text("삭제", style: TextStyle(color: Colors.redAccent, fontSize: 13))),
              ]
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildPostContent(PostDto post) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(post.content, style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF444444))),
    );
  }

  Widget _buildReactionSection(PostDto post) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: () async {
            if (_myUserNum <= 0) { _showLoginDialog(); return; }
            bool success = await _postService.pushLike(widget.postId, _myUserNum);
            if (success) {
              _loadData();
              _showMsg("추천되었습니다!");
            } else {
              _showMsg("이미 추천한 게시글입니다.");
            }
          },
          icon: Icon(Icons.thumb_up_alt_outlined, size: 16, color: post.likeCnt > 0 ? Colors.orange : Colors.black26),
          label: Text("추천 ${post.likeCnt}", style: TextStyle(color: post.likeCnt > 0 ? Colors.orange : Colors.black45)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: post.likeCnt > 0 ? Colors.orange.withOpacity(0.5) : Colors.black12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentHeader(int count) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      child: Row(
        children: [
          const Text("댓글", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text("$count", style: const TextStyle(color: pointBlue, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 5, top: 10, bottom: MediaQuery.of(context).viewInsets.bottom + 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyToCommentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.subdirectory_arrow_right, size: 16, color: pointBlue),
                  const SizedBox(width: 8),
                  Text("$_replyToNickname님에게 답글 작성 중", style: const TextStyle(color: pointBlue, fontSize: 12)),
                  const Spacer(),
                  IconButton(onPressed: _cancelReply, icon: const Icon(Icons.close, size: 14, color: Colors.black26), constraints: const BoxConstraints()),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  decoration: InputDecoration(
                    hintText: "댓글을 입력하세요",
                    hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF8F8F8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.send, color: pointBlue), onPressed: _handleCommentSubmit),
            ],
          ),
        ],
      ),
    );
  }
}