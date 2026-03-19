import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; //  Firebase Auth  추가
import 'package:flutter_app/screens/movie_info.dart';

import 'home_screen.dart'; //  홈 화면 이동을 위해 추가

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  //  Firebase에서 현재 로그인한 유저 정보를 가져옴
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // 유저 정보가 있으면 이메일을 가져오고, 없으면 기본 텍스트 표시
    final String displayEmail = currentUser?.email ?? "이메일 정보 없음";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("개인정보 관리",
            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. 내 계정 정보 섹션
            _buildSectionTitle("로그인 정보"),
            // 🔥 하드코딩 대신 실제 로그인한 이메일 연동
            _buildInfoTile("이메일 계정", displayEmail, isEditable: false),
            _buildInfoTile("비밀번호 변경", "마지막 변경: 3개월 전", isEditable: true),

            const SizedBox(height: 30),

            // 2. 개인정보 섹션
            _buildSectionTitle("개인정보"),
            _buildInfoTile("이름 / 실명", "김철수", isEditable: true),
            _buildInfoTile("휴대폰 번호", "010-1234-5678", isEditable: true),
            _buildInfoTile("생년월일", "1995년 05월 20일", isEditable: false),

            const SizedBox(height: 30),

            // 하단 로그아웃/탈퇴
            Center(
              child: Column(
                children: [
                  TextButton(
                    //  4. 로그아웃 기능 및 화면 이동 로직 추가
                    onPressed: () async {
                      // Firebase 로그아웃 처리
                      await FirebaseAuth.instance.signOut();

                      // MovieHomeScreen으로 이동
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MovieHomeScreen()),
                            (route) => false,
                      );
                    },
                    child: const Text("로그아웃", style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("서비스 탈퇴하기",
                        style: TextStyle(color: Colors.white24, fontSize: 12, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {required bool isEditable}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
          if (isEditable)
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20)
          else
            const Icon(Icons.lock_outline, color: Colors.white10, size: 18),
        ],
      ),
    );
  }
}