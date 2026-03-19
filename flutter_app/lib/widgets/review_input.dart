import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewInput extends StatefulWidget {
  final int movieId;
  final VoidCallback onReviewSubmitted; // 제출 후 부모에게 새로고침 신호

  const ReviewInput({super.key, required this.movieId, required this.onReviewSubmitted});

  @override
  State<ReviewInput> createState() => _ReviewInputState();
}

class _ReviewInputState extends State<ReviewInput> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080', // 서버 URL
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final TextEditingController _contentController = TextEditingController();
  double _rating = 0; // 현재 선택된 평점
  bool _isSubmitting = false; // 제출 중 상태

  // 🔹 리뷰 제출
  void _submitReview() async {
    if (_contentController.text.isEmpty || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("평점과 내용을 모두 입력해주세요")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 서버로 POST 요청
      await _dio.post("/reviews", data: {
        "movie_id": widget.movieId,
        "ratting": _rating,
        "content": _contentController.text,
        "user_num": 1, // TODO: 로그인된 유저의 user_num으로 변경 필요
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰가 등록되었습니다!")),
      );

      // 입력 초기화
      _contentController.clear();
      setState(() {
        _rating = 0;
      });

      widget.onReviewSubmitted(); // 부모에게 새로고침 요청
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰 등록 실패")),
      );
      print("리뷰 등록 오류: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "리뷰 작성",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // ⭐ 평점 선택 (0.5 단위)
          RatingBar(
            initialRating: _rating,
            minRating: 0.5,
            maxRating: 5,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            ratingWidget: RatingWidget(
              full: Icon(Icons.star, color: Colors.yellowAccent),
              half: Icon(Icons.star_half, color: Colors.yellowAccent),
              empty: Icon(Icons.star_border, color: Colors.yellowAccent),
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),

          const SizedBox(height: 8),

          // 📝 리뷰 내용 입력
          TextField(
            controller: _contentController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF141414),
              hintText: "리뷰 내용을 입력하세요",
              hintStyle: const TextStyle(color: Colors.white38),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          const SizedBox(height: 8),

          // 제출 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              child: _isSubmitting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text("등록"),
            ),
          ),
        ],
      ),
    );
  }
}