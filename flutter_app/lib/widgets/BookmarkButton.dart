import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/main.dart';


class BookmarkButton extends StatefulWidget {
  final int movieId;
  final bool initialIsFavorite;

  const BookmarkButton({
    super.key,
    required this.movieId,
    this.initialIsFavorite = false,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}


class _BookmarkButtonState extends State<BookmarkButton> {
  late bool isFavorite;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialIsFavorite;
  }

  @override
  void didUpdateWidget(covariant BookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsFavorite != widget.initialIsFavorite) {
      isFavorite = widget.initialIsFavorite;
    }
  }

  Future<void> _toggleBookmark() async {
    if (sessionUserNum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인이 필요한 서비스입니다.")),
      );
      return;
    }

    if (isProcessing) return;

    setState(() => isProcessing = true);

    try {
      // 1. [수정] 포트 번호 8080 추가
      final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080'));

      // 2. 서버 통신
      final response = await dio.post(
        '/bookmark',
        data: {
          "userNum": sessionUserNum, // 전역 변수 (3)
          "movieId": widget.movieId,
        },
      );

      // 3. [수정] 서버에서 보내준 Boolean 결과값(isAdded)으로 상태 업데이트
      // 서버 컨트롤러가 ResponseEntity.ok(isAdded)를 반환하므로 response.data가 결과값입니다.
      setState(() {
        isFavorite = response.data;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite ? "북마크에 추가되었습니다." : "북마크가 해제되었습니다."),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print("북마크 통신 오류: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("오류가 발생했습니다. 다시 시도해주세요.")),
      );
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isProcessing ? null : _toggleBookmark, // 처리 중에는 클릭 방지
      child: Container(
        padding: const EdgeInsets.all(4), // 클릭 영역 확보
        child: Icon(
          isFavorite ? Icons.bookmark : Icons.bookmark_border,
          color: isFavorite ? Colors.deepPurple : Colors.black26,
          size: 24,
        ),
      ),
    );
  }
}
