import 'package:flutter/material.dart';
import 'package:flutter_app/service/post_service.dart';
import 'package:flutter_app/service/post_service_impl.dart';
import 'package:flutter_app/models/post_model.dart';

class PopularPostsWidget extends StatefulWidget {
  const PopularPostsWidget({super.key});

  @override
  State<PopularPostsWidget> createState() => _PopularPostsWidgetState();
}

class _PopularPostsWidgetState extends State<PopularPostsWidget> {
  final PostService _postService = PostServiceImpl();

  late Future<List<PostDto>> _posts;
  String _searchKeyword = "";
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
        _buildSearchBar(),
        _buildSortDropdown(),
        Expanded(child: _buildPostList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchKeyword = value;
            _posts = fetchPopularPosts().then((list) {
              return list
                  .where((post) =>
                  post.title.toLowerCase().contains(_searchKeyword.toLowerCase()))
                  .toList();
            });
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "검색어를 입력하세요",
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<String>(
        value: _selectedSort,
        dropdownColor: const Color(0xFF1A1A1A),
        style: const TextStyle(color: Colors.white),
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
                  style: TextStyle(color: Colors.white54)));
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
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
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
                Text(post.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(post.category ?? '기타',
                        style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11)),
                    const SizedBox(width: 10),
                    Text(post.authorName,
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(width: 10),
                    Text(post.createdAt,
                        style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text("💬 ${post.commentCnt}",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}