import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:clover_wallet_app/models/lotto_spot.dart'; // Import the new LottoSpot model
import 'package:clover_wallet_app/viewmodels/lotto_spot_viewmodel.dart'; // Import the new LottoSpotViewModel

class LuckySpotsScreen extends StatefulWidget {
  const LuckySpotsScreen({super.key});

  @override
  State<LuckySpotsScreen> createState() => _LuckySpotsScreenState();
}

class _LuckySpotsScreenState extends State<LuckySpotsScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  // Initial camera position (e.g., Seoul)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.5665, 126.9780), // Seoul coordinates
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    // Fetch initial lotto spots when the screen loads
    // This will be called after the ViewModel is properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LottoSpotViewModel>(context, listen: false).fetchLottoSpots(
        _initialCameraPosition.target.latitude,
        _initialCameraPosition.target.longitude,
        10.0, // Example radius
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Listen to changes in lotto spots from the ViewModel
    Provider.of<LottoSpotViewModel>(context, listen: false).addListener(_updateMarkers);
    _updateMarkers(); // Initial marker update
  }

  void _updateMarkers() {
    markers.clear();
    final lottoSpots = Provider.of<LottoSpotViewModel>(context, listen: false).lottoSpots;

    for (var spot in lottoSpots) {
      markers.add(
        Marker(
          markerId: MarkerId(spot.id.toString()),
          position: LatLng(spot.latitude, spot.longitude),
          infoWindow: InfoWindow(
            title: spot.name,
            snippet: '${spot.address}\n1등: ${spot.firstPlaceWins}회, 2등: ${spot.secondPlaceWins}회',
          ),
          onTap: () {
            // Optionally show a bottom sheet or navigate to detail screen
          },
        ),
      );
    }
    setState(() {}); // Update the map with new markers
  }

  @override
  void dispose() {
    Provider.of<LottoSpotViewModel>(context, listen: false).removeListener(_updateMarkers);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로또 명당 찾기'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          Consumer<LottoSpotViewModel>(
            builder: (context, viewModel, child) {
              // This consumer ensures the map rebuilds when lottoSpots change
              // However, _updateMarkers is called via listener, so this might not be strictly necessary here
              // but good for observing state changes.
              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _initialCameraPosition,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '명당 검색 또는 지역 필터링',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                ),
                onSubmitted: (query) {
                  // Implement search logic here
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
