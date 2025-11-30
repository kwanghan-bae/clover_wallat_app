import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckService {
  Future<Map<String, dynamic>> checkVersion() async {
    try {
      // 현재 앱 버전 가져오기
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/app/version?currentVersion=$currentVersion');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      
      // Fallback
      return {
        'needsUpdate': false,
        'hasUpdate': false,
        'updateMessage': '버전 확인 실패',
      };
    } catch (e) {
      return {
        'needsUpdate': false,
        'hasUpdate': false,
        'updateMessage': '버전 확인 실패',
      };
    }
  }
}
