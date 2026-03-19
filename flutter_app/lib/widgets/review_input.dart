import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewInput extends StatefulWidget {
  final int movieId;
  final VoidCallback onReviewSubmitted;

  const ReviewInput({
    super.key,
    required this.movieId,
    required this.onReviewSubmitted,
  });

  @override
  State<ReviewInput> createState() => _ReviewInputState();
}

class _ReviewInputState extends State<ReviewInput> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final TextEditingController _contentController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인이 필요합니다")),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("평점과 내용을 모두 입력해주세요")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userRes = await _dio.get("/users/uid/${currentUser.uid}");
      final userData = Map<String, dynamic>.from(userRes.data);

      final userNum = userData['userNum'] ?? userData['user_num'];

      if (userNum == null) {
        throw Exception("user_num 조회 실패");
      }

      await _dio.post("/reviews", data: {
        "movieId": widget.movieId,
        "movie_id": widget.movieId,
        "rating": _rating,
        "ratting": _rating,
        "content": _contentController.text.trim(),
        "userNum": userNum,
        "user_num": userNum,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰가 등록되었습니다!")),
      );

      _contentController.clear();

      setState(() {
        _rating = 0;
      });

      widget.onReviewSubmitted();
    } catch (e) {
      print("리뷰 등록 오류: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰 등록 실패")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          RatingBar(
            initialRating: _rating,
            minRating: 0.5,
            maxRating: 5,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            ratingWidget: RatingWidget(
              full: const Icon(Icons.star, color: Colors.yellowAccent),
              half: const Icon(Icons.star_half, color: Colors.yellowAccent),
              empty: const Icon(Icons.star_border, color: Colors.yellowAccent),
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF141414),
              hintText: "리뷰 내용을 입력하세요",
              hintStyle: const TextStyle(color: Colors.white38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              child: _isSubmitting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text("등록"),
            ),
          ),
        ],
      ),
    );
  }
}