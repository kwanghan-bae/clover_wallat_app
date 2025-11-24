import 'package:flutter/material.dart';
import 'package:clover_wallet_app/models/lotto_spot_model.dart';
import 'package:clover_wallet_app/services/lotto_spot_api_service.dart';

class LottoSpotViewModel extends ChangeNotifier {
  final LottoSpotApiService _apiService;
  List<LottoSpot> _spots = [];
  bool _isLoading = false;

  List<LottoSpot> get spots => _spots;
  bool get isLoading => _isLoading;

  LottoSpotViewModel({required LottoSpotApiService apiService})
      : _apiService = apiService {
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    _isLoading = true;
    notifyListeners();

    try {
      _spots = await _apiService.getLottoSpots();
    } catch (e) {
      // print('Error loading spots: $e');
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
