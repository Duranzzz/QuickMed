import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/models/prescription_model.dart';
import 'pharmacy_verification_screen.dart';

/// Pantalla de escaneo QR para el farmacéutico (HU 15).
/// Usa la cámara del dispositivo para leer el QR de la receta del paciente.
class PharmacyScannerScreen extends StatefulWidget {
  const PharmacyScannerScreen({super.key});

  @override
  State<PharmacyScannerScreen> createState() => _PharmacyScannerScreenState();
}

class _PharmacyScannerScreenState extends State<PharmacyScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null || rawValue.isEmpty) continue;

      // Intentar decodificar la receta desde los datos del QR
      final prescription = Prescription.fromQrData(rawValue);
      if (prescription != null) {
        setState(() => _scanned = true);
        _controller.stop();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                PharmacyVerificationScreen(prescription: prescription),
          ),
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Receta'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        actions: [
          // Botón de flash
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Cámara
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay con recuadro de escaneo
          _buildScanOverlay(),

          // Instrucciones en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 36),
                  SizedBox(height: 12),
                  Text(
                    'Apunta la cámara al QR de la receta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'El QR puede estar en la pantalla del paciente\no en una imagen guardada',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanArea = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanArea) / 2;
        final top = (constraints.maxHeight - scanArea) / 2 - 40;

        return Stack(
          children: [
            // Fondo oscuro
            Container(color: Colors.black.withOpacity(0.4)),
            // Recuadro transparente
            Positioned(
              left: left,
              top: top,
              child: Container(
                width: scanArea,
                height: scanArea,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF9800), width: 3),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                ),
              ),
            ),
            // Limpiar el área del recuadro
            ClipPath(
              clipper: _ScanAreaClipper(
                scanArea: scanArea,
                left: left,
                top: top,
              ),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ],
        );
      },
    );
  }
}

/// Clipper para crear un hueco transparente en el overlay oscuro.
class _ScanAreaClipper extends CustomClipper<Path> {
  final double scanArea;
  final double left;
  final double top;

  _ScanAreaClipper({
    required this.scanArea,
    required this.left,
    required this.top,
  });

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanArea, scanArea),
        const Radius.circular(16),
      ))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
