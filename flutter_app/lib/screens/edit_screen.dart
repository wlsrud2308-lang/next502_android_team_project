import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
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
            _buildInfoTile("이메일 계정", "movie_lover@gmail.com", isEditable: false),
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
                    onPressed: () {},
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