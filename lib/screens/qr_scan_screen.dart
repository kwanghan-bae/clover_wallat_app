import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 코드 스캔'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return;
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _isScanned = true;
              final String code = barcode.rawValue!;
              // Here we would parse the lotto QR code
              // For MVP, we just show the result
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('스캔 성공: $code')),
              );
              Navigator.pop(context, code);
              break;
            }
          }
        },
      ),
    );
  }
}
