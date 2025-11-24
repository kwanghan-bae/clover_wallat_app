import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clover_wallet_app/viewmodels/lotto_spot_viewmodel.dart';

class HotspotScreen extends StatelessWidget {
  const HotspotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로또 명당 찾기'),
      ),
      body: Consumer<LottoSpotViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.spots.isEmpty) {
            return const Center(child: Text('등록된 명당이 없습니다.'));
          }

          return ListView.builder(
            itemCount: viewModel.spots.length,
            itemBuilder: (context, index) {
              final spot = viewModel.spots[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(spot.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(spot.address),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('1등: ${spot.firstPrizeCount}회', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      Text('2등: ${spot.secondPrizeCount}회', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
