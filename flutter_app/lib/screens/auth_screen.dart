import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http; // 서버 통신용 패키지 (pubspec.yaml 추가 필수)
import 'dart:convert';

// Toast 메시지 출력 함수
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
  final _formKey = GlobalKey<FormState>();

  // 입력 필드 변수들
  late String email;
  late String password;
  late String loginId; // 추가: 사용자 아이디
  late String nickname; // 추가: 닉네임

  bool isInput = true;  // 입력창 출력 여부
  bool isSignIn = true; // 로그인/회원가입 모드 전환

  // [중요] 스프링 서버(MySQL)에 회원 정보 저장 요청
  Future<void> registerToMySql(String uid, String email, String loginId, String nickname) async {
    try {
      // 주소
      final url = Uri.parse('http://50.239.58.243');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "uid": uid,           // 파이어베이스 고유번호
          "email": email,
          "loginId": loginId,   // 사용자 지정 아이디
          "nickname": nickname, // 닉네임
        }),
      );

      if (response.statusCode == 200) {
        print("MySQL 저장 성공!");
      } else {
        print("MySQL 저장 실패: ${response.body}");
      }
    } catch (e) {
      print("서버 통신 에러: $e");
    }
  }

  // 로그인 로직
  void signIn() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        if (value.user!.emailVerified) {
          setState(() { isInput = false; });
        } else {
          showToast('이메일 인증을 완료해주세요.');
        }
      });
    } on FirebaseAuthException catch (e) {
      showToast('이메일 또는 비밀번호를 확인해주세요.');
    }
  }

  // 로그아웃 로직
  void signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() { isInput = true; });
  }

  // 회원가입 로직 (Firebase 인증 + MySQL 저장)
  void signUp() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        if (value.user != null) {
          // 1. 파이어베이스 이메일 인증 메일 발송
          await value.user?.sendEmailVerification();

          // 2. [필살기] 성공 즉시 스프링 서버(MySQL)로 데이터 전송
          await registerToMySql(value.user!.uid, email, loginId, nickname);

          setState(() { isInput = false; });
          showToast('회원가입 성공! 이메일 인증 후 로그인하세요.');
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') showToast('비밀번호가 너무 취약합니다.');
      else if (e.code == 'email-already-in-use') showToast('이미 사용 중인 이메일입니다.');
      else showToast('회원가입 중 오류가 발생했습니다.');
    }
  }

  // 입력 폼 UI
  List<Widget> getInputWidget() {
    return [
      Text(
        isSignIn ? '로그인' : '회원가입',
        style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 24.0),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16.0),
      Form(
        key: _formKey,
        child: Column(
          children: [
            // 회원가입 시에만 '아이디'와 '닉네임' 필드 노출
            if (!isSignIn) ...[
              TextFormField(
                decoration: const InputDecoration(labelText: '아이디', hintText: '사용하실 아이디를 입력하세요'),
                validator: (value) => (value?.isEmpty ?? true) ? '아이디를 입력하세요' : null,
                onSaved: (value) => loginId = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '닉네임', hintText: '닉네임을 입력하세요'),
                validator: (value) => (value?.isEmpty ?? true) ? '닉네임을 입력하세요' : null,
                onSaved: (value) => nickname = value ?? '',
              ),
            ],
            TextFormField(
              decoration: const InputDecoration(labelText: '이메일', hintText: '이메일을 입력하세요'),
              validator: (value) => (value?.isEmpty ?? true) ? '이메일을 입력하세요' : null,
              onSaved: (value) => email = value ?? '',
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '비밀번호', hintText: '비밀번호를 입력하세요'),
              obscureText: true,
              validator: (value) => (value?.isEmpty ?? true) ? '비밀번호를 입력하세요' : null,
              onSaved: (value) => password = value ?? '',
            ),
          ],
        ),
      ),
      const SizedBox(height: 20.0),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _formKey.currentState?.save();
            isSignIn ? signIn() : signUp();
          }
        },
        child: Text(isSignIn ? '로그인' : '회원가입'),
      ),
      const SizedBox(height: 10.0),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: isSignIn ? '계정이 없으신가요? ' : '이미 계정이 있으신가요? ',
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
                text: isSignIn ? '회원가입' : '로그인',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() { isSignIn = !isSignIn; });
                  }
            ),
          ],
        ),
      ),
    ];
  }

  // 결과 화면 UI (로그인/가입 성공 시)
  List<Widget> getResultWidget() {
    String? resultEmail = FirebaseAuth.instance.currentUser?.email;
    return [
      const Icon(Icons.check_circle, size: 80, color: Colors.indigoAccent),
      const SizedBox(height: 20),
      Text(
        isSignIn ? '$resultEmail님 환영합니다!' : '회원가입 완료!\n인증 메일을 확인해 주세요.',
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          if (isSignIn) signOut();
          else setState(() { isInput = true; isSignIn = true; });
        },
        child: Text(isSignIn ? '로그아웃' : '로그인하러 가기'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: isInput ? getInputWidget() : getResultWidget(),
          ),
        ),
      ),
    );
  }
}