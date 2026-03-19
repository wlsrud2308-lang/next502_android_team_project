import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/review_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewList extends StatefulWidget {
  final int movieId;
  const ReviewList({super.key, required this.movieId});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews();
  }

  Future<List<Review>> fetchReviews() async {
    try {
      final res = await _dio.get("/reviews/${widget.movieId}");
      print("리뷰 조회 주소: ${res.realUri}");
      print("리뷰 조회 응답: ${res.data}");

      return (res.data as List)
          .map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print("리뷰 조회 오류: $e");
      rethrow;
    }
  }
  // Future<List<Review>> fetchReviews() async {
  //   final res = await _dio.gePerforming hot restart...
  // Syncing files to device sdk gphone64 x86 64...
  // Restarted application in 1,357ms.
  // D/WindowOnBackDispatcher( 8501): setTopOnBackInvokedCallback (unwrapped): android.view.ImeBackAnimationController@6e04a32
  // D/FlutterJNI( 8501): Sending viewport metrics to the engine.
  // D/FlutterJNI( 8501): Sending viewport metrics to the engine.
  // D/WindowOnBackDispatcher( 8501): setTopOnBackInvokedCallback (unwrapped): io.flutter.embedding.android.FlutterActivity$1@27cf7a3
  // I/flutter ( 8501): 리뷰 조회 오류: DioException [bad response]: This exception was thrown because the response has a status code of 500 and RequestOptions.validateStatus was configured to throw for this status code.
  // I/flutter ( 8501): The status code of 500 has the following meaning: "Server error - the server failed to fulfil an apparently valid request"
  // I/flutter ( 8501): Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
  // I/flutter ( 8501): In order to resolve this exception you typically have either to verify and fix your request code or you have to fix the server code.
  // I/ImeTracker( 8501): com.example.flutter_app:dac4c8bd: onRequestShow at ORIGIN_CLIENT reason SHOW_SOFT_INPUT fromUser false
  // D/InsetsController( 8501): show(ime())
  // I/ImeTracker( 8501): com.example.flutter_app:dac4c8bd: onCancelled at PHASE_CLIENT_APPLY_ANIMATION
  // I/AssistStructure( 8501): Flattened final assist data: 500 bytes, containing 1 windows, 3 views
  // D/InputConnectionAdaptor( 8501): The input method toggled cursor monitoring on
  // I/ImeTracker( 8501): com.example.flutter_app:5a35cbc4: onRequestShow at ORIGIN_CLIENT reason SHOW_SOFT_INPUT fromUser false
  // D/InsetsController( 8501): show(ime())
  // I/ImeTracker( 8501): com.example.flutter_app:5a35cbc4: onCancelled at PHASE_CLIENT_APPLY_ANIMATION
  // I/flutter ( 8501): 리뷰 등록 오류: DioException [bad response]: This exception was thrown because the response has a status code of 404 and RequestOptions.validateStatus was configured to throw for this status code.
  // I/flutter ( 8501): The status code of 404 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
  // I/flutter ( 8501): Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
  // I/flutter ( 8501): In order to resolve this exception you typically have either to verify and fix your request code or you have to fix the server code.t("/reviews/${widget.movieId}");
  //   return (res.data as List)
  //       .map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
  //       .toList();
  // }

  void refresh() {
    setState(() {
      _reviewsFuture = fetchReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "리뷰 불러오기 실패",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "등록된 리뷰가 없습니다.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "리뷰",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...reviews.map(
                    (r) => Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingBarIndicator(
                          rating: r.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.yellowAccent,
                          ),
                          itemCount: 5,
                          itemSize: 18,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.content,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          r.createdAt,
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}