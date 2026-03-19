import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';


import 'package:flutter_app/screens/home_screen.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Map<String, dynamic>? userData;
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // 화면이 켜질 때 자동으로 데이터 불러오기
  }

  Future<void> _fetchUserData() async {
    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final dio = Dio();
      // 내 파이어베이스 UID를 주소에 넣어서 백엔드에 요청
      final response = await dio.get('http://10.0.2.2:8080/flutter/user/${currentUser!.uid}');

      if (response.statusCode == 200) {
        setState(() {
          userData = response.data; // 가져온 데이터 저장
          isLoading = false;
        });
      }
    } catch (e) {
      print("유저 정보 로드 실패: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때는 동그라미 로딩창 표시
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
      );
    }

    final String displayEmail = currentUser?.email ?? "이메일 정보 없음";

    // DB에서 가져온 정보 세팅 (없으면 '정보 없음' 표시)
    final String displayNickname = userData?['nickname'] ?? "정보 없음";
    final String displayName = userData?['userName'] ?? "정보 없음";
    final String displayTel = userData?['userTel']?.toString() ?? "정보 없음";
    final String displayBirth = userData?['userBirth'] ?? "정보 없음";

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
            _buildInfoTile("이메일 계정", displayEmail, isEditable: false),

            _buildInfoTile("비밀번호 변경", "마지막 변경: 3개월 전", isEditable: true),

            _buildInfoTile("닉네임", displayNickname, isEditable: true),

            const SizedBox(height: 30),

            // 2. 개인정보 섹션
            _buildSectionTitle("개인정보"),
            // DB에서 가져온 값 세팅
            _buildInfoTile("이름 / 실명", displayName, isEditable: true),
            _buildInfoTile("휴대폰 번호", displayTel, isEditable: true),
            _buildInfoTile("생년월일", displayBirth, isEditable: false),

            const SizedBox(height: 30),

            // 하단 로그아웃/탈퇴
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
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