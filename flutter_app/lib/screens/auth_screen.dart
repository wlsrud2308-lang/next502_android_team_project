import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_app/screens/movie_info.dart';

import 'home_screen.dart'; // 홈 화면 이동을 위해 추가

// Toast 메시지
void showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    backgroundColor: Colors.indigoAccent,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreen();
}

class _AuthScreen extends State<AuthScreen> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/flutter', // Android Emulator용
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
    ),
  );

  final _formKey = GlobalKey<FormState>();

  late String email;
  late String password;
  late String nickname;

  bool isInput = true;
  bool isSignIn = true;

  // MySQL 회원 저장
  Future<void> registerToMySql(
      String uid, String email, String nickname) async {
    try {
      Response res = await _dio.post(
        '/signup',
        data: {
          "uid": uid,
          "email": email,
          "nickname": nickname
        },
      );
      print("서버 응답 : ${res.data}");
      if (res.statusCode == 200 || res.statusCode == 201) {
        showToast("MySQL 저장 성공");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          print("서버 상태 코드: ${e.response?.statusCode}");
          print("서버 응답: ${e.response?.data}");
          showToast("서버 오류: ${e.response?.statusCode}");
        } else {
          showToast("요청 실패: ${e.message}");
        }
      } else {
        showToast("알 수 없는 오류 발생");
      }
      print("서버 통신 오류 : $e");
    }
  }

  // 로그인
  void signIn() async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (user.user!.emailVerified) {
        if (!mounted) return;

        showToast("로그인 성공!");

        // 로그인 성공 시 결과 화면 대신 홈 화면으로 강제 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MovieHomeScreen()),
              (route) => false,
        );
      } else {
        showToast("이메일 인증을 완료해주세요");
      }
    } on FirebaseAuthException {
      showToast("이메일 또는 비밀번호 오류");
    }
  }

  // 로그아웃
  void signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    setState(() {
      isInput = true;
    });
  }

  // 회원가입
  void signUp() async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (user.user != null) {
        // 이메일 인증
        await user.user!.sendEmailVerification();

        // MySQL 저장
        await registerToMySql(user.user!.uid, email, nickname);

        if (!mounted) return;
        setState(() {
          isInput = false;
        });

        showToast("회원가입 성공! 이메일 인증하세요");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast("비밀번호가 너무 약합니다");
      } else if (e.code == 'email-already-in-use') {
        showToast("이미 사용중인 이메일");
      } else {
        showToast("회원가입 실패");
      }
    }
  }

  // 입력 UI
  List<Widget> getInputWidget() {
    return [
      Text(
        isSignIn ? '로그인' : '회원가입',
        style: const TextStyle(
            color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 24),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "이메일"),
              validator: (v) => v!.isEmpty ? "이메일 입력" : null,
              onSaved: (v) => email = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "비밀번호"),
              obscureText: true,
              validator: (v) => v!.isEmpty ? "비밀번호 입력" : null,
              onSaved: (v) => password = v!,
            ),
            if (!isSignIn)
              TextFormField(
                decoration: const InputDecoration(labelText: "닉네임"),
                validator: (v) => v!.isEmpty ? "닉네임 입력" : null,
                onSaved: (v) => nickname = v!,
              ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            if (isSignIn) {
              signIn();
            } else {
              signUp();
            }
          }
        },
        child: Text(isSignIn ? "로그인" : "회원가입"),
      ),
      const SizedBox(height: 10),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: isSignIn ? "계정이 없나요? " : "이미 계정이 있나요? ",
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: isSignIn ? "회원가입" : "로그인",
              style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (!mounted) return;
                  setState(() {
                    isSignIn = !isSignIn;
                  });
                },
            ),
          ],
        ),
      ),
    ];
  }

  // 로그인 성공 UI (회원가입 완료 시에만 노출됨)
  List<Widget> getResultWidget() {
    String? resultEmail = FirebaseAuth.instance.currentUser?.email;

    return [
      const Icon(Icons.check_circle, size: 80, color: Colors.indigoAccent),
      const SizedBox(height: 20),
      Text(
        isSignIn
            ? "$resultEmail 님 환영합니다!"
            : "회원가입 완료\n메일 인증하세요",
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          if (isSignIn) {
            signOut();
          } else {
            if (!mounted) return;
            setState(() {
              isInput = true;
              isSignIn = true;
            });
          }
        },
        child: Text(isSignIn ? "로그아웃" : "로그인"),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: isInput ? getInputWidget() : getResultWidget(),
          ),
        ),
      ),
    );
  }
}