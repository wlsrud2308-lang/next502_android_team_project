import 'package:flutter/material.dart';

class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? movieData;
  const MovieDetailScreen({super.key, required this.movieData});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.movieData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(child: Text("데이터를 불러올 수 없습니다.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white70), onPressed: () {}),
          IconButton(icon: const Icon(Icons.star_border, color: Colors.white70), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMovieHeader(),
                  _buildStatGrid(),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text("줄거리", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "영화의 상세 줄거리 정보입니다. 데이터베이스에서 정보를 가져오지 못한 경우 기본 안내 문구가 출력됩니다.",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.5),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.white10, thickness: 8),

                  _buildCommentHeader(),
                  _buildCommentItem("시네필21", "듄은 역시 아이맥스로 봐야 제맛이네요. 영상미 미쳤습니다.", "10분 전"),
                  _buildCommentItem("무비러버", "평점이 왜 이렇게 높은지 알겠네요. 간만에 수작입니다.", "1시간 전"),
                  _buildCommentItem("익명", "개인적으로는 전편보다 호흡이 길어서 조금 지루했어요.", "3시간 전"),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildMovieHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.movie_filter, color: Colors.white10, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    widget.movieData!['title'] ?? "제목 정보 없음",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                Text(
                    "${widget.movieData!['year'] ?? '연도 미상'} · ${widget.movieData!['genre'] ?? '장르 정보 없음'}",
                    style: const TextStyle(color: Colors.white38, fontSize: 13)
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildBadge("IMAX", Colors.blueAccent),
                    const SizedBox(width: 6),
                    _buildBadge("Dolby", Colors.deepPurpleAccent),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("평점", widget.movieData!['rating'] ?? "0.0", Colors.purpleAccent),
          _buildStatItem("예매율", "1위", Colors.orangeAccent),
          _buildStatItem("관객수", "정보없음", Colors.white70),
          _buildStatItem("신선도", "90%", Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 11)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.5))
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCommentHeader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text("댓글", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          SizedBox(width: 6),
          Text("128", style: TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String user, String content, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.02))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 10, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 12, color: Colors.white24)),
              const SizedBox(width: 8),
              Text(user, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(time, style: const TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10, left: 16, right: 16, top: 10),
      decoration: const BoxDecoration(
          color: Color(0xFF161616),
          border: Border(top: BorderSide(color: Colors.white10))
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                    hintText: "따뜻한 댓글을 남겨주세요",
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                    border: InputBorder.none
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("등록", style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}