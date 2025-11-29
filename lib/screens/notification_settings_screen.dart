import 'package:flutter/material.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _winningNotification = true;
  bool _drawResultNotification = true;
  bool _promotionNotification = false;
  
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      backgroundColor: CloverTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User Info Card
          Container(
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
                    color: CloverTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: CloverTheme.primaryColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('알림 상태', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '로그인이 필요합니다',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Settings Section
          const Text('알림 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: CloverTheme.softShadow,
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.emoji_events_rounded,
                  title: '당첨 알림',
                  subtitle: '내 로또 번호가 당첨되면 알려드려요',
                  value: _winningNotification,
                  onChanged: (value) {
                    setState(() {
                      _winningNotification = value;
                    });
                  },
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.calendar_today_rounded,
                  title: '추첨 결과 알림',
                  subtitle: '매주 토요일 추첨 결과를 받아보세요',
                  value: _drawResultNotification,
                  onChanged: (value) {
                    setState(() {
                      _drawResultNotification = value;
                    });
                  },
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.campaign_rounded,
                  title: '프로모션 알림',
                  subtitle: '특별 이벤트와 혜택 정보',
                  value: _promotionNotification,
                  onChanged: (value) {
                    setState(() {
                      _promotionNotification = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '알림을 받으려면 디바이스 설정에서 알림 권한을 허용해주세요.',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: CloverTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeColor: CloverTheme.primaryColor,
    );
  }
}
