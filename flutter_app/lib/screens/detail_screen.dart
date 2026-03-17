import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF121212);
    const Color contentDark = Color(0xFF1E1E1E);
    const Color accentPurple = Color(0xFF9D50BB);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text("해외영화 게시판", style: TextStyle(fontSize: 15, color: Colors.white70)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDarkPostContent(contentDark),
            Container(height: 10, color: Colors.black),

            _buildDarkCommentHeader(),

            _buildDarkCommentItem(
                author: "영화광_99",
                content: "이번 영화는 연출이 다했네요. 영상미만으로 볼 가치가 충분합니다.",
                time: "12:10",
                depth: 0,
                cardColor: contentDark
            ),
            _buildDarkCommentItem(
                author: "시네필",
                content: "공감합니다. 특히 후반부 롱테이크 씬은 압권이었어요.",
                time: "12:15",
                depth: 1,
                isAuthor: true,
                cardColor: const Color(0xFF252525)
            ),
            _buildDarkCommentItem(
                author: "영화광_99",
                content: "맞아요 그 부분 때문에 한 번 더 보러 갈까 고민 중입니다 ㅋㅋ",
                time: "12:18",
                depth: 2,
                cardColor: const Color(0xFF2D2D2D)
            ),
            _buildDarkCommentItem(
                author: "평론가A",
                content: "저는 오히려 색감이 너무 과하다는 느낌을 받았습니다.",
                time: "12:30",
                depth: 0,
                cardColor: contentDark
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildDarkCommentInput(bgDark),
    );
  }

  Widget _buildDarkPostContent(Color bgColor) {
    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "오늘 개봉한 [듄: 파트2] 아이맥스 관람 후기",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: Colors.purple, child: Icon(Icons.person, size: 14, color: Colors.white)),
              const SizedBox(width: 8),
              const Text("무비매니아", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              const Text("2026-03-16 12:00", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white10),
          ),
          const Text(
            "방금 아이맥스로 보고 나왔는데 진짜 압도적이네요...\n\n"
                "한스 짐머의 음악이 극장 전체를 울리는데 전율이 돋았습니다. "
                "이건 무조건 큰 화면에서 보셔야 해요. 안 그러면 후회합니다.",
            style: TextStyle(fontSize: 15, height: 1.8, color: Colors.white),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDarkCommentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Icon(Icons.mode_comment_outlined, color: Colors.blueAccent, size: 18),
          const SizedBox(width: 8),
          const Text("댓글", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          const Text("15", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDarkCommentItem({
    required String author,
    required String content,
    required String time,
    int depth = 0,
    bool isAuthor = false,
    required Color cardColor
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (depth > 0) ...[
            SizedBox(width: 15.0 * depth),
            const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
          ],

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 16, bottom: 8, left: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(author, style: TextStyle(fontSize: 12, color: isAuthor ? Colors.orangeAccent : Colors.white70, fontWeight: FontWeight.bold)),
                      if (isAuthor) ...[
                        const SizedBox(width: 4),
                        const Text("WR", style: TextStyle(fontSize: 9, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                      ],
                      const Spacer(),
                      Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(content, style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkCommentInput(Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "댓글을 입력하세요...",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                filled: true,
                fillColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.send, color: Colors.blueAccent),
        ],
      ),
    );
  }
}