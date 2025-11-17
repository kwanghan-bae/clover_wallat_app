import 'package:flutter/material.dart';
import 'package:clover_wallet_app/models/lotto_spot.dart';
import 'package:clover_wallet_app/services/lotto_spot_api_service.dart';

class LottoSpotViewModel extends ChangeNotifier {
  final LottoSpotApiService _apiService;
  List<LottoSpot> _lottoSpots = [];
  bool _isLoading = false;
  String? _errorMessage;

  LottoSpotViewModel({required LottoSpotApiService apiService})
      : _apiService = apiService;

  List<LottoSpot> get lottoSpots => _lottoSpots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLottoSpots(double latitude, double longitude, double radiusKm) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lottoSpots = await _apiService.getLottoSpotsNearLocation(latitude, longitude, radiusKm);
    } catch (e) {
      _errorMessage = e.toString();
      _lottoSpots = []; // Clear spots on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllLottoSpots() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lottoSpots = await _apiService.getAllLottoSpots();
    } catch (e) {
      _errorMessage = e.toString();
      _lottoSpots = []; // Clear spots on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
