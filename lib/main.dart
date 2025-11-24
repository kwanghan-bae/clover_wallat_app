import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:clover_wallet_app/screens/home_screen.dart';
import 'package:clover_wallet_app/services/community_api_service.dart';
import 'package:clover_wallet_app/viewmodels/community_viewmodel.dart';
import 'package:clover_wallet_app/services/lotto_spot_api_service.dart';
import 'package:clover_wallet_app/viewmodels/lotto_spot_viewmodel.dart';
import 'package:clover_wallet_app/viewmodels/history_viewmodel.dart';
import 'package:clover_wallet_app/services/winning_check_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<CommunityApiService>(
          create: (_) => CommunityApiService(),
        ),
        ChangeNotifierProvider<CommunityViewModel>(
          create: (context) => CommunityViewModel(
            apiService: context.read<CommunityApiService>(),
          ),
        ),
        Provider<LottoSpotApiService>(
          create: (_) => LottoSpotApiService(),
        ),
        ChangeNotifierProvider<LottoSpotViewModel>(
          create: (context) => LottoSpotViewModel(
            apiService: context.read<LottoSpotApiService>(),
          ),
        ),
        Provider<WinningCheckService>(
          create: (_) => WinningCheckService(),
        ),
        ChangeNotifierProvider<HistoryViewModel>(
          create: (context) => HistoryViewModel(
            winningCheckService: context.read<WinningCheckService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clover Lotto',
      theme: CloverTheme.themeData,
      home: const HomeScreen(),
    );
  }
}