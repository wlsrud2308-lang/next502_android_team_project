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

  // ✅ 검색창 (밝게)
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
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: "검색어를 입력하세요",
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: const Icon(Icons.search, color: Colors.black38),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }

  // ✅ 정렬 드롭다운 (밝게)
  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    );
  }

  // ✅ 리스트 (밝게)
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

  // ✅ 게시글 아이템 (게시판 스타일)
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