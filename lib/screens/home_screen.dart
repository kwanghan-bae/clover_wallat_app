import 'package:flutter/material.dart';
import 'package:clover_wallet_app/screens/number_generation_screen.dart';
import 'package:clover_wallet_app/screens/history_screen.dart';
import 'package:clover_wallet_app/screens/hotspot_screen.dart';
import 'package:clover_wallet_app/screens/qr_scan_screen.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:clover_wallet_app/services/lotto_info_service.dart';
import 'package:clover_wallet_app/screens/statistics_screen.dart';
import 'package:clover_wallet_app/screens/community_screen.dart';
import 'package:clover_wallet_app/screens/mypage_screen.dart';
import 'package:clover_wallet_app/screens/notification_screen.dart';
import 'package:clover_wallet_app/screens/travel_screen.dart';
import 'package:clover_wallet_app/widgets/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      DashboardTab(onTabChange: _onItemTapped),
      const HistoryScreen(),
      const HotspotScreen(),
      const CommunityScreen(),
      const MyPageScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: '내 로또'),
            BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: '명당'),
            BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: '커뮤니티'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: '마이페이지'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: CloverTheme.primaryColor,
          unselectedItemColor: CloverTheme.textGrey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrScanScreen()),
                );
              },
              backgroundColor: CloverTheme.secondaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.qr_code_scanner_rounded),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class DashboardTab extends StatelessWidget {
  final Function(int) onTabChange;

  const DashboardTab({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloverTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.filter_vintage, color: CloverTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('Clover Wallet', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Next Draw Info Card
                  _buildNextDrawCard(context),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  const Text('빠른 실행', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(context),
                  const SizedBox(height: 24),

                  // Recent History Preview (Placeholder)
                  const Text('최근 당첨 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildRecentHistoryCard(context),
                ],
              ),
            ),
          ),
          // 배너 광고
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildNextDrawCard(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: LottoInfoService().getNextDrawInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: CloverTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
           return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: CloverTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                const Text('정보를 불러올 수 없습니다', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    (context as Element).markNeedsBuild();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: CloverTheme.primaryColor,
                  ),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: CloverTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: CloverTheme.softShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '제 ${data['currentRound']} 회',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '당첨 발표까지',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '${data['daysLeft']}일 ${data['hoursLeft']}시간 ${data['minutesLeft']}분',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NumberGenerationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: CloverTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('번호 생성하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem(context, Icons.casino_rounded, '번호 추첨', Colors.purple, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NumberGenerationScreen()));
        }),
        _buildQuickActionItem(context, Icons.qr_code_scanner_rounded, 'QR 스캔', Colors.blue, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScanScreen()));
        }),
        _buildQuickActionItem(context, Icons.analytics_rounded, '번호 분석', Colors.orange, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
        }),
        _buildQuickActionItem(context, Icons.travel_explore, '여행 플랜', Colors.purple, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TravelScreen()));
        }),
        _buildQuickActionItem(context, Icons.store_rounded, '로또 명당', Colors.green, () {
          onTabChange(2); // Switch to Hotspot tab
        }),
      ],
    );
  }

  Widget _buildQuickActionItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRecentHistoryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: CloverTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('최근 구매 내역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('아직 구매한 로또가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
