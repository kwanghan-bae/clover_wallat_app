import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_native_ocr/flutter_native_ocr.dart';
import 'package:clover_wallet_app/utils/theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isProcessing = false;
  List<int>? _recognizedNumbers;
  int? _recognizedRound;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용 가능한 카메라가 없습니다.')),
          );
        }
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카메라 초기화 실패: $e')),
        );
      }
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      final ocr = FlutterNativeOcr();
      final recognizedText = await ocr.recognizeText(image.path);

      // Parse lotto numbers from recognized text
      final numbers = _parseLottoNumbers(recognizedText);
      final round = _parseRound(recognizedText);

      setState(() {
        _recognizedNumbers = numbers;
        _recognizedRound = round;
        _isProcessing = false;
      });

      if (numbers.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('번호를 인식할 수 없습니다. 다시 시도해주세요.')),
          );
        }
      } else {
        _showConfirmationDialog();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR 처리 실패: $e')),
        );
      }
    }
  }

  List<int> _parseLottoNumbers(String text) {
    // Extract numbers from text
    final regex = RegExp(r'\b([1-9]|[1-3][0-9]|4[0-5])\b');
    final matches = regex.allMatches(text);
    final numbers = matches.map((m) => int.parse(m.group(0)!)).toList();

    // Filter to get exactly 6 unique numbers between 1-45
    final uniqueNumbers = numbers.toSet().where((n) => n >= 1 && n <= 45).toList();
    
    if (uniqueNumbers.length >= 6) {
      return uniqueNumbers.sublist(0, 6)..sort();
    }
    
    return [];
  }

  int? _parseRound(String text) {
    // Try to extract round number (e.g., "1234회")
    final regex = RegExp(r'(\d{3,4})회');
    final match = regex.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('인식된 번호 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recognizedRound != null)
              Text('회차: ${_recognizedRound}회', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('번호:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              _recognizedNumbers!.join(', '),
              style: const TextStyle(fontSize: 18, color: CloverTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            const Text(
              '※ 인식된 번호가 정확한지 확인해주세요.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _recognizedNumbers = null;
                _recognizedRound = null;
              });
            },
            child: const Text('다시 촬영'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, {
                'numbers': _recognizedNumbers,
                'round': _recognizedRound,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CloverTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('티켓 스캔'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(color: CloverTheme.primaryColor),
            )
          : Stack(
              children: [
                // Camera preview
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),
                
                // Overlay guide
                Positioned.fill(
                  child: CustomPaint(
                    painter: ScanOverlayPainter(),
                  ),
                ),
                
                // Instructions
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '로또 티켓의 번호 부분을 가이드에 맞춰주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                
                // Processing indicator
                if (_isProcessing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: CloverTheme.primaryColor),
                            SizedBox(height: 16),
                            Text(
                              '번호 인식 중...',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: _isInitialized && !_isProcessing
          ? FloatingActionButton.extended(
              onPressed: _captureAndRecognize,
              backgroundColor: CloverTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.camera_alt),
              label: const Text('촬영'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.3,
    );

    canvas.drawRect(rect, paint);

    // Draw corner markers
    final cornerLength = 20.0;
    final corners = [
      // Top-left
      [Offset(rect.left, rect.top), Offset(rect.left + cornerLength, rect.top)],
      [Offset(rect.left, rect.top), Offset(rect.left, rect.top + cornerLength)],
      // Top-right
      [Offset(rect.right, rect.top), Offset(rect.right - cornerLength, rect.top)],
      [Offset(rect.right, rect.top), Offset(rect.right, rect.top + cornerLength)],
      // Bottom-left
      [Offset(rect.left, rect.bottom), Offset(rect.left + cornerLength, rect.bottom)],
      [Offset(rect.left, rect.bottom), Offset(rect.left, rect.bottom - cornerLength)],
      // Bottom-right
      [Offset(rect.right, rect.bottom), Offset(rect.right - cornerLength, rect.bottom)],
      [Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - cornerLength)],
    ];

    paint.strokeWidth = 5;
    for (var corner in corners) {
      canvas.drawLine(corner[0], corner[1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
