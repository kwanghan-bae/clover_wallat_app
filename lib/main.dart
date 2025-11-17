import 'package:clover_wallet_app/services/community_api_service.dart';
import 'package:clover_wallet_app/viewmodels/community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:clover_wallet_app/screens/home_screen.dart';
import 'package:clover_wallet_app/screens/my_numbers_screen.dart';
import 'package:clover_wallet_app/screens/lucky_spots_screen.dart';
import 'package:clover_wallet_app/screens/community_screen.dart';
import 'package:provider/provider.dart';
import 'package:clover_wallet_app/services/lotto_spot_api_service.dart'; // New import
import 'package:clover_wallet_app/viewmodels/lotto_spot_viewmodel.dart'; // New import

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
        Provider<LottoSpotApiService>( // New provider
          create: (_) => LottoSpotApiService(),
        ),
        ChangeNotifierProvider<LottoSpotViewModel>(
          create: (context) => LottoSpotViewModel(
            apiService: context.read<LottoSpotApiService>(), // Use the new service
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    MyNumbersScreen(),
    LuckySpotsScreen(),
    CommunityScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clover Lotto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_6),
            label: '내 번호',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: '명당',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '커뮤니티',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}