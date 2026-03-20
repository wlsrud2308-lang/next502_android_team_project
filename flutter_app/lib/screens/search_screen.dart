import 'package:flutter/material.dart';
import 'package:flutter_app/service/post_service_impl.dart';
import 'package:flutter_app/models/post_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Future<List<PostDto>>? _searchResults;

  final postService = PostServiceImpl();

  void _search() {
    String query = _controller.text.trim();

    if (query.isEmpty) return;

    setState(() {
      _searchResults = postService.searchPosts(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 검색 화면 전체 배경 흰색
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // 원본 유지
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "검색어 입력...",
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _search,
          ),
        ],
      ),
      body: _searchResults == null
          ? Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            "검색어를 입력하세요",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      )
          : FutureBuilder<List<PostDto>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.indigoAccent,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                "검색 오류",
                style: TextStyle(color: Colors.black54),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "검색 결과 없음",
                style: TextStyle(color: Colors.black54),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var post = snapshot.data![index];
                return _buildPostItem(post);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildPostItem(PostDto post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35,
            child: Text(
              post.postId.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      post.category ?? '기타',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      post.authorName ?? '익명',
                      style: const TextStyle(color: Colors.black54, fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      post.createdAt ?? '',
                      style: const TextStyle(color: Colors.black38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "💬 ${post.commentCnt}",
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}