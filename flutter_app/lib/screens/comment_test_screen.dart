import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import '../widgets/comment_input.dart';
import '../widgets/comment_tile.dart';

class CommentTestScreen extends StatefulWidget {
  const CommentTestScreen({super.key});

  @override
  State<CommentTestScreen> createState() => _CommentTestScreenState();
}

class _CommentTestScreenState extends State<CommentTestScreen> {
  final Dio dio = Dio(
    BaseOptions(baseUrl: "http://10.0.2.2:8080"),
  );

  List<CommentModel> comments = [];

  @override
  void initState() {
    super.initState();
    fetchComments(); // 처음 실행 시 댓글 불러오기
  }

  // 🔥 댓글 불러오기
  Future<void> fetchComments() async {
    try {
      final res = await dio.get("/comments/MOVIE/1");

      final List data = res.data;

      setState(() {
        comments = data.map((e) => CommentModel.fromJson(e)).toList();
      });
    } catch (e) {
      print("댓글 불러오기 실패: $e");
    }
  }

  // 🔥 댓글 추가 (DB 저장)
  Future<void> addComment(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await dio.post("/comments", data: {
        "content": text,
        "userNum": user.uid,
        "targetType": "MOVIE",
        "targetId": "1",
      });

      await fetchComments(); // 저장 후 다시 불러오기
    } catch (e) {
      print("댓글 저장 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("댓글 테스트"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [

          // 댓글 리스트
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];

                return CommentTile(
                  comment: comment,
                  nickname: comment.userNum, // 👉 지금은 UID 표시
                );
              },
            ),
          ),

          // 입력창
          CommentInput(
            onSubmit: addComment,
          ),
        ],
      ),
    );
  }
}