import 'package:flutter/material.dart';

import '../dto/post_dto.dart';
import '../service/post_service.dart';
import '../service/post_service_impl.dart';

class DetailScreen extends StatefulWidget {
  final String postId;
  const DetailScreen({super.key, required this.postId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PostService _postService = PostServiceImpl();
  late Future<PostDto> _postFuture;

  static const Color bgDark = Color(0xFF121212);
  static const Color contentDark = Color(0xFF1E1E1E);
  static const Color accentPurple = Color(0xFF9D50BB);

  @override
  void initState() {
    super.initState();
    _postFuture = _postService.getPostDetail(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        title: const Text("상세보기", style: TextStyle(fontSize: 16, color: Colors.white70)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<PostDto>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accentPurple));
          }
          if (snapshot.hasError) {
            return Center(child: Text("오류가 발생했습니다.", style: const TextStyle(color: Colors.white54)));
          }

          final post = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(post),

                _buildPostContent(post),

                _buildReactionSection(post),

                Container(height: 8, color: Colors.black),

                _buildCommentHeader(post.commentCnt),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostHeader(PostDto post) {
    return Container(
      color: contentDark,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const CircleAvatar(
                  radius: 14,
                  backgroundColor: accentPurple,
                  child: Icon(Icons.person, size: 16, color: Colors.white)
              ),
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
          const SizedBox(height: 15),
          const Divider(color: Colors.white10, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildPostContent(PostDto post) {
    return Container(
      color: contentDark,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        post.content,
        style: const TextStyle(fontSize: 16, height: 1.8, color: Color(0xFFE0E0E0)),
      ),
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
              bool success = await _postService.pushLike(widget.postId, 1);

              if (success) {
                setState(() {
                  _postFuture = _postService.getPostDetail(widget.postId);
                });
                _showMsg("추천되었습니다!");
              } else {
                _showMsg("이미 추천한 게시글입니다.");
              }
            },
            child: _reactionButton(Icons.thumb_up_alt, "추천 ${post.likeCnt}", Colors.orangeAccent),
          ),
          const SizedBox(width: 15),
          _reactionButton(Icons.star_border, "스크랩", Colors.blueAccent),
        ],
      ),
    );
  }

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _reactionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
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