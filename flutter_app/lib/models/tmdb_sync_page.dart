import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TMDBSyncPage extends StatefulWidget {
  @override
  _TMDBSyncPageState createState() => _TMDBSyncPageState();
}

class _TMDBSyncPageState extends State<TMDBSyncPage> {
  String _status = "아직 요청하지 않음";

  Future<void> syncMovies() async {
    final url = Uri.parse("http://10.0.2.2:8080/movies/sync"); // 서버 주소 확인!

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          _status = "데이터 업데이트 완료 ✅";
        });
      } else {
        setState(() {
          _status = "서버 오류: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _status = "요청 실패: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TMDB 데이터 갱신"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: syncMovies,
              child: Text("지금 업데이트"),
            ),
          ],
        ),
      ),
    );
  }
}