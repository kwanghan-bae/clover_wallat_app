import 'package:flutter/material.dart';
import 'package:clover_wallet_app/models/travel_plan_model.dart';
import 'package:clover_wallet_app/services/travel_api_service.dart';
import 'package:clover_wallet_app/utils/theme.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final TravelApiService _apiService = TravelApiService();
  List<TravelPlanModel> _travelPlans = [];
  bool _isLoading = true;

  // 여행지 데이터 로드 (현재는 Mock Data)
  
  
  @override
  void initState() {
    super.initState();
    _loadTravelPlans();
  }

  Future<void> _loadTravelPlans() async {
    setState(() => _isLoading = true);
    final plans = await _apiService.getAllTravelPlans();
    setState(() {
      _travelPlans = plans;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloverTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('여행 플랜'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _travelPlans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.travel_explore, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        '등록된 여행 플랜이 없습니다.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadTravelPlans,
                        icon: const Icon(Icons.refresh),
                        label: const Text('새로고침'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTravelPlans,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _travelPlans.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final plan = _travelPlans[index];
                      return _buildPlanCard(plan);
                    },
                  ),
                ),
    );
  }

  Widget _buildPlanCard(TravelPlanModel plan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CloverTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with theme badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getThemeColor(plan.theme),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.theme,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${plan.estimatedHours}시간',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Title and description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Places preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plan.places.take(4).map((place) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CloverTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(place.typeIcon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        place.name.length > 10
                            ? '${place.name.substring(0, 10)}...'
                            : place.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Action button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: TravelPlanDetailScreen 구현 (지도, 경로 안내, 예약 기능)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('플랜 상세보기 준비 중입니다.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CloverTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('자세히 보기'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getThemeColor(String theme) {
    switch (theme) {
      case 'HEALING':
      case '자연':
        return Colors.green;
      case 'HISTORY':
      case '문화':
        return Colors.brown;
      case 'FOOD':
      case '맛집':
        return Colors.orange;
      case 'CITY':
      case '관광':
        return Colors.blue;
      default:
        return CloverTheme.primaryColor;
    }
  }
}
