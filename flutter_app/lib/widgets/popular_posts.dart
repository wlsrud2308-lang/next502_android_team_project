import 'package:flutter/material.dart';
import 'package:flutter_app/service/post_service.dart';
import 'package:flutter_app/service/post_service_impl.dart';
import 'package:flutter_app/models/post_model.dart';

class PopularPosts extends StatefulWidget {
  const PopularPosts({super.key});

  @override
  State<PopularPosts> createState() => _PopularPostsState();
}

class _PopularPostsState extends State<PopularPosts> {
  final PostService _postService = PostServiceImpl();

  late Future<List<PostDto>> _posts;
  String _selectedSort = '조회수';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _posts = fetchPopularPosts();
  }

  Future<List<PostDto>> fetchPopularPosts() async {
    try {
      var posts = await _postService.getPopularPosts();
      if (posts.isEmpty) throw '게시글이 없습니다';
      return posts;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSortDropdownWithLabel(),
        Expanded(child: _buildPostList()),
      ],
    );
  }

  // 인기글 라벨 + 드롭다운
  Widget _buildSortDropdownWithLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "인기글",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16, // 글자 키움
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedSort,
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              underline: const SizedBox(),
              items: <String>['조회수', '추천수', '댓글수']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedSort = value;
                  _posts = _posts.then((list) {
                    List<PostDto> sorted = List.from(list);
                    if (_selectedSort == '조회수') {
                      sorted.sort((a, b) => (b.viewCnt ?? 0).compareTo(a.viewCnt ?? 0));
                    } else if (_selectedSort == '추천수') {
                      sorted.sort((a, b) => (b.likeCnt ?? 0).compareTo(a.likeCnt ?? 0));
                    } else if (_selectedSort == '댓글수') {
                      sorted.sort((a, b) => (b.commentCnt ?? 0).compareTo(a.commentCnt ?? 0));
                    }
                    return sorted;
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList() {
    return FutureBuilder<List<PostDto>>(
      future: _posts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('게시글이 없습니다.',
                  style: TextStyle(color: Colors.black38)));
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
    );
  }

  Widget _buildPostItem(PostDto post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      post.category ?? '기타',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.createdAt,
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "💬 ${post.commentCnt}",
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}