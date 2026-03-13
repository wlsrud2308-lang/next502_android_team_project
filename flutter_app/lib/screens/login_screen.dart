import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/auth_screen.dart';

class LoginPage extends StatelessWidget {
  final String title;

  const LoginPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.indigoAccent, // 남색 계열 배경
        centerTitle: true, // 제목 가운데 정렬
        elevation: 0, // 상단바 그림자 제거 (깔끔하게)
      ),
      // 화면의 몸통 부분에 실제 로그인/회원가입 입력창(AuthScreen)을 배치
      body: const AuthScreen(),
    );
  }
}