import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/services/database.service.dart';
import 'package:nustar_turnstile_scanner/utility/shared/loader.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class QRScannerScreen extends StatefulWidget {
  static const routeName = "/qr-scanner-screen";
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {

  final GlobalKey _qrKey = GlobalKey();
  QRViewController? _scannerController;
  bool _isScanning = true;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  _onQRViewCreated(QRViewController controller) {
    _scannerController = controller;
    controller.scannedDataStream.listen((scanData) {
      String? qrCode = scanData.code;
      // Routes.navigateToScreen(QRScanResultPage(qrData: 'displayText', values: ['values'])); 

      // if (_hasScanned || !_isScanning || !mounted) return;

      if (qrCode != null) {
        _hasScanned = true;
        _isScanning = false;
      //   _scannerController?.pauseCamera();

      //   debugPrint(">>> _onQRViewCreated -- scanData.code != null");

        // ignore: use_build_context_synchronously
        Loader.show(context, 0);

        _scannerController?.dispose();

        Timer(const Duration(milliseconds: 500), () {
          _processScannedData(qrCode);
        });
      } else {
        debugPrint(">>> _onQRViewCreated -- scanData.code is null");
      }

      
    });
  }

  void _processScannedData(String qrData) {
    if (!mounted || !_hasScanned) return;

    debugPrint(">>> _processScannedData -- Scanned QR Data: $qrData");

    List<String> values = qrData.split("||");
    String displayText = '';

    if (values.length >= 10) {
      displayText = "Player ID: ${values[0]}\n"
          "Voucher ID: ${values[1]}\n"
          "Item: ${values[8]}\n"
          "Comp ID: ${values[9]}";
    } else {
      displayText = qrData;
    }

    Loader.stop();
    debugPrint(">>> _processScannedData -- displayText: $displayText");

    /// Insert QR record into Firestore
    // if (values.length >= 10) {
    //   DatabaseService.insertQrRecord(
    //     context: context,
    //     playerId: values[0],
    //     voucherId: values[1],
    //     item: values[8],
    //     compId: values[9],
    //   );
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint(">>> _processScannedData -- WidgetsBinding.instance.addPostFrameCallback");
      Routes.navigateToScreen(QRScanResultPage(qrData: displayText, values: values)); 
    debugPrint(">>> _processScannedData -- Routes.navigateToScreen");
      // Routes.pushNamed(context, QRScannerScreen.routeName);
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!mounted || !_hasScanned) return;
      
    //   Routes.navigateToScreen(QRScanResultPage(qrData: qrData, values: values));
      
    //   // Navigator.of(context).pushReplacement(
    //   //   MaterialPageRoute(
    //   //     builder: (context) =>
    //   //         QRScanResultPage(qrData: qrData, values: values),
    //   //   ),
    //   // );
    // });
  }

  void _resetScanner() async {
    if (!mounted) return;
    setState(() {
      _hasScanned = false;
      _isScanning = true;
    });
    await _scannerController?.resumeCamera();
  }

  void _switchCamera() async {
    await _scannerController?.flipCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'QR Scanner',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: _switchCamera,
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
            // overlayMargin: EdgeInsets.zero,
          ),
          _buildScannerOverlay(),
          _buildScanIndicator(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return CustomPaint(
      painter: ScannerOverlayPainter(
        borderColor: const Color(0xFF00D9FF),
        borderLength: 40,
        borderWidth: 4,
        cornerRadius: 16,
        scanAreaSize: 280,
      ),
      child: SizedBox(
        width: 100.w,
        height: 100.h,
      ),
    );
  }

  Widget _buildScanIndicator() {
    return Positioned(
      top: 35.h,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Align QR code within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.cameraswitch,
              label: 'Switch',
              onTap: _switchCamera,
            ),
            const SizedBox(width: 30),
            _buildControlButton(
              icon: Icons.refresh,
              label: 'Reset',
              onTap: _resetScanner,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderLength;
  final double borderWidth;
  final double cornerRadius;
  final double scanAreaSize;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.borderLength,
    required this.borderWidth,
    required this.cornerRadius,
    required this.scanAreaSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaLeft = (size.width - scanAreaSize) / 2;
    final double scanAreaTop = (size.height - scanAreaSize) / 2 - 50;

    final Paint paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaSize, scanAreaSize),
        Radius.circular(cornerRadius),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final RRect scanAreaRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaSize, scanAreaSize),
      Radius.circular(cornerRadius),
    );

    canvas.drawRRect(scanAreaRRect, borderPaint);

    _drawCorner(canvas, scanAreaLeft, scanAreaTop, cornerRadius, borderPaint,
        isTopLeft: true);
    _drawCorner(canvas, scanAreaLeft + scanAreaSize, scanAreaTop, cornerRadius,
        borderPaint,
        isTopRight: true);
    _drawCorner(canvas, scanAreaLeft, scanAreaTop + scanAreaSize, cornerRadius,
        borderPaint,
        isBottomLeft: true);
    _drawCorner(canvas, scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize,
        cornerRadius, borderPaint,
        isBottomRight: true);
  }

  void _drawCorner(
    Canvas canvas,
    double x,
    double y,
    double radius,
    Paint paint, {
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    final Path path = Path();

    if (isTopLeft) {
      path.moveTo(x, y + borderLength);
      path.lineTo(x, y + radius);
      path.quadraticBezierTo(x, y, x + radius, y);
      path.lineTo(x + borderLength, y);
    } else if (isTopRight) {
      path.moveTo(x - borderLength, y);
      path.lineTo(x - radius, y);
      path.quadraticBezierTo(x, y, x, y + radius);
      path.lineTo(x, y + borderLength);
    } else if (isBottomLeft) {
      path.moveTo(x, y - borderLength);
      path.lineTo(x, y - radius);
      path.quadraticBezierTo(x, y, x + radius, y);
      path.lineTo(x + borderLength, y);
    } else if (isBottomRight) {
      path.moveTo(x - borderLength, y);
      path.lineTo(x - radius, y);
      path.quadraticBezierTo(x, y, x, y - radius);
      path.lineTo(x, y - borderLength);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QRScanResultBottomSheet extends StatelessWidget {
  final String qrData;
  final List<String> values;

  const QRScanResultBottomSheet({
    super.key,
    required this.qrData,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValidData = values.length >= 10;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(
            Icons.qr_code_scanner,
            color: Color(0xFF00D9FF),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'QR Code Scanned',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: hasValidData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Player ID', values[0]),
                      _buildDetailRow('Voucher ID', values[1]),
                      _buildDetailRow('Item', values[8]),
                      _buildDetailRow('Comp ID', values[9]),
                    ],
                  )
                : Text(
                    qrData,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRScanResultPage extends StatelessWidget {
  static const routeName = "/qr-scanner-result-screen";
  final String qrData;
  final List<String> values;

  const QRScanResultPage({
    super.key,
    required this.qrData,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValidData = values.length >= 10;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'QR Code Scanned',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.qr_code_scanner,
                color: Color(0xFF00D9FF),
                size: 64,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00D9FF), width: 1),
                ),
                child: hasValidData
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Player ID', values[0]),
                          _buildDetailRow('Voucher ID', values[1]),
                          _buildDetailRow('Item', values[8]),
                          _buildDetailRow('Comp ID', values[9]),
                        ],
                      )
                    : Text(
                        qrData,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Scan Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
