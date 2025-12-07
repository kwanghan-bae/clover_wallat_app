import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clover_wallet_app/viewmodels/lotto_spot_viewmodel.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:geolocator/geolocator.dart';

class HotspotScreen extends StatefulWidget {
  const HotspotScreen({super.key});

  @override
  State<HotspotScreen> createState() => _HotspotScreenState();
}

class _HotspotScreenState extends State<HotspotScreen> {
  bool _isMapView = false;
  late GoogleMapController mapController;
  String _selectedRegion = '전체';

  final List<String> _regions = [
    '전체',
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '광주',
    '대전',
    '울산',
    '세종',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];

  final LatLng _center = const LatLng(37.5665, 126.9780); // Seoul City Hall

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloverTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('명당 찾기'),
        actions: [
          // Region filter dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedRegion,
              dropdownColor: CloverTheme.primaryColor,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              underline: Container(),
              items: _regions.map((String region) {
                return DropdownMenuItem<String>(
                  value: region,
                  child: Text(
                    region,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRegion = newValue;
                  });
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(_isMapView ? Icons.list_rounded : Icons.map_rounded),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
        ],
      ),
      body: Consumer<LottoSpotViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.spots.isEmpty) {
            return const Center(child: Text('등록된 명당이 없습니다.'));
          }

          // Filter spots based on selected region
          final filteredSpots = _selectedRegion == '전체'
              ? viewModel.spots
              : viewModel.spots.where((spot) {
                  return spot.address.contains(_selectedRegion);
                }).toList();

          if (filteredSpots.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '$_selectedRegion 지역의 명당이 없습니다.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Pass filtered spots to map/list view
          return _isMapView
              ? _buildMapView(filteredSpots)
              : _buildListView(filteredSpots);
        },
      ),
      floatingActionButton: _isMapView
          ? FloatingActionButton.extended(
              onPressed: () async {
                try {
                  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                  if (!serviceEnabled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('위치 서비스가 비활성화되어 있습니다.')),
                    );
                    return;
                  }

                  LocationPermission permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('위치 권한이 거부되었습니다.')),
                      );
                      return;
                    }
                  }

                  if (permission == LocationPermission.deniedForever) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.')),
                    );
                    return;
                  }

                  final position = await Geolocator.getCurrentPosition();
                  mapController.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(position.latitude, position.longitude),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('위치 확인 중 오류 발생: $e')),
                  );
                }
              },
              label: const Text('내 주변 찾기'),
              icon: const Icon(Icons.my_location),
              backgroundColor: CloverTheme.primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMapView(List spots) {
    // Note: Ensure API Key is added to web/index.html for this to work on Web
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 11.0,
      ),
      markers: spots.map((spot) {
        // Assuming spot has lat/lng, otherwise use random offset from center for demo
        // In real app, use spot.latitude and spot.longitude
        return Marker(
          markerId: MarkerId(spot.id.toString()),
          position: _center, // Replace with actual coordinates
          infoWindow: InfoWindow(
            title: spot.name,
            snippet: '1등 ${spot.firstPrizeCount}회 당첨',
          ),
        );
      }).toSet(),
    );
  }

  Widget _buildListView(List spots) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: spots.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final spot = spots[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: CloverTheme.softShadow,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CloverTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store_rounded, color: CloverTheme.primaryColor),
            ),
            title: Text(
              spot.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(spot.address, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge('1등 ${spot.firstPrizeCount}회', CloverTheme.secondaryColor),
                    const SizedBox(width: 8),
                    _buildBadge('2등 ${spot.secondPrizeCount}회', Colors.blueGrey),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
