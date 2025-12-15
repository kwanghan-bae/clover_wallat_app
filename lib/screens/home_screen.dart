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
import 'package:clover_wallet_app/widgets/glass_card.dart';

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
      // Global Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: CloverTheme.primaryGradient,
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Handled by container
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
      backgroundColor: Colors.transparent, // Let gradient show through
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.filter_vintage, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 8),
            const Text(
              'Clover Wallet',
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
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
                  // Next Draw Info Card - Highlighted
                  _buildNextDrawCard(context),
                  const SizedBox(height: 32),
                  
                  // Quick Actions
                  const Text(
                    '빠른 실행',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(context),
                  const SizedBox(height: 32),

                  // Recent History Preview
                  const Text(
                    '최근 당첨 결과',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
          return const GlassCard(
            height: 220,
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
           return GlassCard(
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white70, size: 48),
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
        
        return GlassCard(
          opacity: 0.2, // Slightly more opaque for emphasis
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    )
                  ]
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
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                  shadowColor: Colors.black45,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuickActionItem(context, Icons.casino_rounded, '번호 추첨', Colors.purpleAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NumberGenerationScreen()));
        }),
        _buildQuickActionItem(context, Icons.qr_code_scanner_rounded, 'QR 스캔', Colors.blueAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScanScreen()));
        }),
        _buildQuickActionItem(context, Icons.analytics_rounded, '번호 분석', Colors.orangeAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
        }),
        _buildQuickActionItem(context, Icons.travel_explore, '여행 플랜', Colors.cyanAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TravelScreen()));
        }),
        _buildQuickActionItem(context, Icons.store_rounded, '로또 명당', Colors.greenAccent, () {
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
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            onTap: onTap, // Ripple effect
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistoryCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최근 구매 내역',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '아직 구매한 로또가 없습니다.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white70),
        ],
      ),
    );
  }
}

