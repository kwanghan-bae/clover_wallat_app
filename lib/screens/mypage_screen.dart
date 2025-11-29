import 'package:flutter/material.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clover_wallet_app/screens/notification_settings_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'user@example.com';
    final name = user?.userMetadata?['full_name'] ?? '사용자';

    return Scaffold(
      backgroundColor: CloverTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card
            _buildProfileCard(context, name, email),
            const SizedBox(height: 24),

            // Badges Section
            _buildSectionHeader('나의 뱃지'),
            const SizedBox(height: 12),
            _buildBadgesSection(),
            const SizedBox(height: 24),

            // Stats Section
            _buildSectionHeader('당첨 통계'),
            const SizedBox(height: 12),
            _buildStatsGrid(),
            const SizedBox(height: 24),

            // Menu
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: CloverTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: CloverTheme.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: CloverTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    // Mock Badges
    final badges = [
      {'icon': Icons.emoji_events_rounded, 'label': '첫 당첨', 'color': Colors.amber},
      {'icon': Icons.local_fire_department_rounded, 'label': '열정', 'color': Colors.redAccent},
      {'icon': Icons.verified_rounded, 'label': '인증됨', 'color': Colors.blue},
      {'icon': Icons.star_rounded, 'label': 'VIP', 'color': Colors.purple},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final badge = badges[index];
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (badge['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(badge['icon'] as IconData, color: badge['color'] as Color, size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                badge['label'] as String,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('총 당첨금', '₩ 50,000', Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('수익률', '+120%', Colors.red),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: CloverTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: CloverTheme.softShadow,
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.notifications_none_rounded, '알림 설정', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
            );
          }),
          const Divider(height: 1),
          _buildMenuItem(Icons.lock_outline_rounded, '개인정보 처리방침'),
          const Divider(height: 1),
          _buildMenuItem(Icons.info_outline_rounded, '앱 정보'),
          const Divider(height: 1),
          _buildMenuItem(Icons.logout_rounded, '로그아웃', isDestructive: true, onTap: () async {
            await Supabase.instance.client.auth.signOut();
            // Navigation handled by auth state listener in main.dart
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey[700]),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}
