import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 처리방침'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SelectableText(
          _privacyPolicyText,
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
      ),
    );
  }

  static const String _privacyPolicyText = '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
개인정보 처리방침
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Clover Wallet은 정보통신망 이용촉진 및 정보보호 등에 관한 법률, 개인정보보호법 등 관련 법령상의 개인정보보호 규정을 준수합니다.

시행일자: 2024년 1월 1일

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 수집하는 개인정보 항목

▪ 필수 항목
  - 회원 가입: 이메일 주소
  - 로또 티켓 관리: 구매한 로또 번호, QR 코드 정보
  - 커뮤니티 활동: 게시글 및 댓글 내용

▪ 선택 항목
  - 알림 서비스: FCM 토큰 (푸시 알림용)
  - 번호 생성: 생년월일 (사주팔자, 별자리 기반)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2. 개인정보의 이용 목적

- 회원 가입 및 로그인, 본인 확인
- 로또 티켓 관리, 당첨 확인
- 커뮤니티 게시글 및 댓글 관리
- 당첨 알림, 추첨 결과 알림
- 서비스 개선 및 통계 분석

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

3. 개인정보의 보유 기간

- 회원 정보: 회원 탈퇴 시까지
- 로또 티켓 정보: 마지막 게임 종료 후 5년
- 커뮤니티 게시글: 게시글 삭제 시까지
- 로그 기록: 3개월

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

4. 개인정보의 제3자 제공

원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

5. 개인정보 처리 위탁

▪ Supabase: 회원 인증 및 데이터베이스
▪ Firebase: 푸시 알림 발송
▪ Render: 서버 호스팅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

6. 정보주체의 권리

- 개인정보 열람 요구
- 개인정보 정정·삭제 요구
- 개인정보 처리 정지 요구
- 회원 탈퇴 (마이페이지 > 설정 > 회원 탈퇴)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

7. 개인정보 보호책임자

이름: 배광한
이메일: kwanghan.bae@gmail.com

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

공고 일자: 2024년 1월 1일
시행 일자: 2024년 1월 1일
''';
}
