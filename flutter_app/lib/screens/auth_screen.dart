import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:dio/dio.dart';

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
      baseUrl: 'http://10.100.202.5:8080/flutter',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
    ),
  );

  final _formKey = GlobalKey<FormState>();

  late String email;
  late String password;
  late String loginId;
  late String nickname;

  bool isInput = true;
  bool isSignIn = true;

  // MySQL 회원 저장
  Future<void> registerToMySql(
      String uid,
      String email,
      String loginId,
      String nickname) async {

    try {

      Response res = await _dio.post(
        '/signup',
        data: {
          "uid": uid,
          "email": email,
          "loginId": loginId,
          "nickname": nickname
        },
      );

      print("서버 응답 : ${res.data}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        showToast("MySQL 저장 성공");
      }

    } catch (e) {

      print("서버 통신 오류 : $e");
      showToast("서버 연결 실패");

    }

  }

  // 로그인
  void signIn() async {

    try {

      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email,
          password: password
      );

      if (user.user!.emailVerified) {

        setState(() {
          isInput = false;
        });

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

    setState(() {
      isInput = true;
    });

  }

  // 회원가입
  void signUp() async {

    try {

      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      if (user.user != null) {

        // 이메일 인증
        await user.user!.sendEmailVerification();

        // MySQL 저장
        await registerToMySql(
            user.user!.uid,
            email,
            loginId,
            nickname
        );

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
            color: Colors.indigoAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24),
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 16),

      Form(
        key: _formKey,
        child: Column(
          children: [

            if (!isSignIn) ...[

              TextFormField(
                decoration: const InputDecoration(labelText: "아이디"),
                validator: (v) => v!.isEmpty ? "아이디 입력" : null,
                onSaved: (v) => loginId = v!,
              ),

              TextFormField(
                decoration: const InputDecoration(labelText: "닉네임"),
                validator: (v) => v!.isEmpty ? "닉네임 입력" : null,
                onSaved: (v) => nickname = v!,
              ),

            ],

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
                  setState(() {
                    isSignIn = !isSignIn;
                  });
                },
            ),
          ],
        ),
      )

    ];

  }

  // 로그인 성공 UI
  List<Widget> getResultWidget() {

    String? resultEmail = FirebaseAuth.instance.currentUser?.email;

    return [

      const Icon(Icons.check_circle,
          size: 80,
          color: Colors.indigoAccent),

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
            children: isInput
                ? getInputWidget()
                : getResultWidget(),
          ),

        ),

      ),

    );

  }

}