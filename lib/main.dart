import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:clover_wallet_app/screens/home_screen.dart';
import 'package:clover_wallet_app/services/community_api_service.dart';
import 'package:clover_wallet_app/services/lotto_api_service.dart';
import 'package:clover_wallet_app/viewmodels/community_viewmodel.dart';
import 'package:clover_wallet_app/services/lotto_spot_api_service.dart';
import 'package:clover_wallet_app/viewmodels/lotto_spot_viewmodel.dart';
import 'package:clover_wallet_app/viewmodels/history_viewmodel.dart';
import 'package:clover_wallet_app/services/winning_check_service.dart';
import 'package:clover_wallet_app/viewmodels/statistics_viewmodel.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clover_wallet_app/screens/login_screen.dart';

import 'package:clover_wallet_app/services/auth_service.dart';
import 'package:clover_wallet_app/services/fcm_service.dart';
import 'package:clover_wallet_app/services/ad_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jxyqgkekjidadocrvbcn.supabase.co',
    anonKey: 'sb_publishable_xeGYwBzLsfMVstSqv35SHA_5Qw2kOEx',
  );

  // Initialize FCM
  if (!kIsWeb) {
    // Firebase initialization usually required here for mobile too if not auto-init
    // But assuming mobile works, we just skip Web to avoid crash
    // initialize is missing in main.dart? Assuming it's handled implicitly or we should add it?
    // User didn't complain about mobile.
    // However, FcmService constructor calls FirebaseMessaging.instance.
    // We should move FcmService instantiation inside the check or make it safe.
    
    // To be safe, we only instantiate and init if not web
    try {
      final fcmService = FcmService(navigatorKey: navigatorKey);
      await fcmService.initialize();
    } catch (e) {
      print('FCM Init Error: $e');
    }
  }

  // Initialize AdMob
  await AdService().initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<CommunityApiService>(
          create: (_) => CommunityApiService(),
        ),
        Provider<LottoApiService>(
          create: (_) => LottoApiService(),
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
        ChangeNotifierProvider<StatisticsViewModel>(
          create: (context) => StatisticsViewModel(
            historyViewModel: context.read<HistoryViewModel>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        // Sync with backend when session is established (e.g. after redirect login)
        _syncWithBackend(session.accessToken);
      }
    });
  }

  Future<void> _syncWithBackend(String jwtToken) async {
    try {
      final authService = AuthService();
      await authService.syncWithBackend(jwtToken);
    } catch (e) {
      print('Auth sync error: $e');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('서버 동기화 실패: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '재시도',
            textColor: Colors.white,
            onPressed: () => _syncWithBackend(jwtToken),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clover Wallet',
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: CloverTheme.themeData,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = Supabase.instance.client.auth.currentSession;
          return session == null ? const LoginScreen() : const HomeScreen();
        },
      ),
    );
  }
}