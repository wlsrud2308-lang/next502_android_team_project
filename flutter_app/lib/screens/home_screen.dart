import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Dio _dio = Dio(
    BaseOptions(
        baseUrl: 'http://10.100.202.5:8080/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        }
    ),
  );
  String result = "버튼 클릭 시 서버에서 전달받은 데이터가 출력되는 곳!!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Spring Server 와 통신하기',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onPressedDioGet,
                    child: Text('Get 통신'),
                  ),
                  ElevatedButton(
                    onPressed: onPressedDioGetParam,
                    child: Text('Get 통신 파람'),
                  ),
                  ElevatedButton(
                    onPressed: onPressedDioPost,
                    child: Text('Post 통신'),
                  ),
                  ElevatedButton(
                    onPressed: onPressedDioPostParam,
                    child: Text('Post 통신 파람'),
                  ),
                ],
              ),
              SizedBox(height: 8.0,),
              Divider(),
              SizedBox(height: 8.0,),
              Expanded(
                child: Center(
                  child: Text('$result'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onPressedDioGet() async {
    try {
      Response res = await _dio.get('http://10.100.202.5:8080/api/member');

      if (res.statusCode == 200 || res.statusCode == 201) {
        var data = res.data;

        setState(() {
          result = data['result'];
        });
      }
    }
    catch (e, s) {
      print('\n ***** 오류 발생 : $e *****\n');
      print('\n ***** 오류 위치 : $s *****\n');
    }
  }

  Future<void> onPressedDioGetParam() async {
    try {
      // Dio 라이브러리를 사용하여 서버로 Get 방식 통신 시 데이터를 함께 전달할 경우 url 에 전달할 데이터를 함께 입력
      // Response res = await _dio.get('/test1?num1=10&num2=20');
      // url 주소만 입력 후 queryParameters 속성을 사용하여 Json 타입으로 데이터를 전달
      Response res = await _dio.get('/test1', queryParameters: {"num1": 10, "num2": 20});

      if (res.statusCode == 200 || res.statusCode == 201) {
        var data = res.data;
        int num1 = data['num1'];
        int num2 = data['num2'];
        int result = data['result'];
        String str = '파라미터가 있는 Get 방식 통신\n$num1 + $num2 = $result';

        setState(() {
          this.result = str;
        });
      }
    }
    catch (e, s) {
      print('\n ***** 오류 발생 : $e *****\n');
      print('\n ***** 오류 위치 : $s *****\n');
    }
  }

  Future<void> onPressedDioPost() async {
    try {
      Response res = await _dio.post('/member');

      if (res.statusCode == 200 || res.statusCode == 201) {
        var data = res.data;
        setState(() {
          result = data['result'];
        });
      }
    }
    catch (e, s) {
      print('\n ***** 오류 발생 : $e *****\n');
      print('\n ***** 오류 위치 : $s *****\n');
    }
  }

  Future<void> onPressedDioPostParam() async {
    try {
      // Dio 라이브러리를 사용하여 서버로 Post 방식 통신 시 데이터를 함께 전달할 경우 data 속성에 Json 타입으로 데이터를 전달
      Response res = await _dio.post(
          '/test2',
          data: {"num1": "10", "num2": "20"}
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        var data = res.data;
        // print(data);
        String num1 = data['num1'];
        String num2 = data['num2'];
        String result = data['result'];
        String str = '파라미터가 있는 POST 방식 통신\n$num1 + $num2 = $result';

        setState(() {
          this.result = str;
        });
      }
    }
    catch (e, s) {
      print('\n ***** 오류 발생 : $e *****\n');
      print('\n ***** 오류 위치 : $s *****\n');
    }
  }
}

