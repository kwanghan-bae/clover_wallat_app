import 'package:flutter/material.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clover_wallet_app/screens/notification_settings_screen.dart';
import 'package:clover_wallet_app/screens/privacy_policy_screen.dart';
import 'package:clover_wallet_app/services/user_stats_service.dart';
import 'package:clover_wallet_app/services/user_service.dart';
import 'package:clover_wallet_app/widgets/glass_card.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'user@example.com';
    final name = user?.userMetadata?['full_name'] ?? '사용자';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: CloverTheme.primaryGradient,
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: UserStatsService().getUserStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data ?? {'totalWinnings': 0, 'roi': 0, 'totalGames': 0};
            
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Card
                    _buildProfileCard(context, name, email),
                    const SizedBox(height: 24),

                    // Badges Section
                    _buildSectionHeader('나의 뱃지'),
                    const SizedBox(height: 12),
                    _buildBadgesSection(stats),
                    const SizedBox(height: 24),

                    // Stats Section
                    _buildSectionHeader('당첨 통계'),
                    const SizedBox(height: 12),
                    _buildStatsGrid(stats),
                    const SizedBox(height: 24),

                    // Menu
                    _buildMenuSection(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name, String email) {
    return GlassCard(
      opacity: 0.15,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white
                ),
              ),
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
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    final totalWinnings = stats['totalWinnings'] as int? ?? 0;
    final roi = stats['roi'] as int? ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '총 당첨금',
            '₩ ${_formatCurrency(totalWinnings)}',
            const Color(0xFF4CAF50), // Brighter Green
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            '수익률', 
            '${roi >= 0 ? '+' : ''}$roi%', 
            roi >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(Map<String, dynamic> stats) {
    final List<Map<String, dynamic>> badges = [];
    final user = Supabase.instance.client.auth.currentUser;

    if ((stats['totalWinnings'] as num? ?? 0) > 0) {
      badges.add({'icon': Icons.emoji_events_rounded, 'label': '첫 당첨', 'color': Colors.amber});
    }
    if ((stats['totalGames'] as num? ?? 0) >= 5) {
      badges.add({'icon': Icons.local_fire_department_rounded, 'label': '열정', 'color': Colors.redAccent});
    }
    if (user?.emailConfirmedAt != null) {
      badges.add({'icon': Icons.verified_rounded, 'label': '인증됨', 'color': Colors.blueAccent});
    }
    if ((stats['totalWinnings'] as num? ?? 0) >= 1000000) {
      badges.add({'icon': Icons.star_rounded, 'label': 'VIP', 'color': Colors.purpleAccent});
    }

    if (badges.isEmpty) {
      return GlassCard(
        opacity: 0.1,
        child: Center(
          child: Column(
            children: [
              Icon(Icons.lock_outline_rounded, color: Colors.white60, size: 32),
              const SizedBox(height: 8),
              const Text(
                '아직 획득한 뱃지가 없어요',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final badge = badges[index];
          return GlassCard(
            width: 100,
            padding: const EdgeInsets.all(12),
            borderRadius: 20,
            opacity: 0.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (badge['color'] as Color).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(badge['icon'] as IconData, color: badge['color'] as Color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  badge['label'] as String,
                  style: const TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(1)}억';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만';
    } else {
      return amount.toString();
    }
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return GlassCard(
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
    return GlassCard(
      opacity: 0.15,
      padding: EdgeInsets.zero, // Custom padding for list items
      child: Column(
        children: [
          _buildMenuItem(Icons.notifications_outlined, '알림 설정', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
            );
          }),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          _buildMenuItem(Icons.privacy_tip_outlined, '개인정보 처리방침', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
            );
          }),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          _buildMenuItem(Icons.info_outline_rounded, '앱 정보'),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          _buildMenuItem(Icons.logout_rounded, '로그아웃', onTap: () async {
            await Supabase.instance.client.auth.signOut();
          }),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          _buildMenuItem(Icons.person_off_rounded, '회원 탈퇴', isDestructive: true, onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF2C3E50),
                title: const Text('회원 탈퇴', style: TextStyle(color: Colors.white)),
                content: const Text(
                  '정말로 탈퇴하시겠습니까?\n모든 데이터가 즉시 삭제되며 복구할 수 없습니다.',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await UserService().deleteAccount();
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('회원 탈퇴 실패: $e')),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('탈퇴', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isDestructive ? const Color(0xFFFF5252) : Colors.white70
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? const Color(0xFFFF5252) : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white30),
      onTap: onTap,
    );
  }
}
