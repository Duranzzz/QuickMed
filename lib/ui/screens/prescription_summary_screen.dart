import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cross_file/cross_file.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/prescription_model.dart';
import 'doctor_dashboard_screen.dart';

/// Pantalla resumen de la receta emitida con QR real, distribución
/// vía WhatsApp/SMS (HU 12 + HU 13) y descarga offline (HU 14).
class PrescriptionSummaryScreen extends StatefulWidget {
  final Prescription prescription;

  const PrescriptionSummaryScreen({super.key, required this.prescription});

  @override
  State<PrescriptionSummaryScreen> createState() =>
      _PrescriptionSummaryScreenState();
}

class _PrescriptionSummaryScreenState extends State<PrescriptionSummaryScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _saved = false;

  /// Captura el contenido del RepaintBoundary como imagen PNG.
  Future<Uint8List?> _captureImage() async {
    try {
      final boundary = _cardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error al capturar imagen: $e');
      return null;
    }
  }

  /// Guarda la imagen capturada en un archivo temporal y lo retorna.
  Future<File?> _saveImageToTemp(Uint8List bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/receta_${widget.prescription.qrHash.substring(0, 8)}.png',
      );
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error al guardar imagen: $e');
      return null;
    }
  }

  /// Comparte la receta como imagen con texto descriptivo.
  Future<void> _shareGeneral() async {
    setState(() => _sharing = true);
    try {
      final bytes = await _captureImage();
      if (bytes == null) {
        _showError('No se pudo capturar la receta');
        return;
      }

      final file = await _saveImageToTemp(bytes);
      if (file == null) {
        _showError('No se pudo guardar la imagen');
        return;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: _shareText(),
        subject: 'Receta Médica - QuickMed',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  /// Comparte la receta directamente por WhatsApp.
  Future<void> _shareWhatsApp() async {
    setState(() => _sharing = true);
    try {
      final bytes = await _captureImage();
      if (bytes == null) {
        _showError('No se pudo capturar la receta');
        return;
      }

      final file = await _saveImageToTemp(bytes);
      if (file == null) {
        _showError('No se pudo guardar la imagen');
        return;
      }

      // share_plus con XFile abre el selector; el usuario elige WhatsApp
      await Share.shareXFiles(
        [XFile(file.path)],
        text: _shareText(),
        subject: 'Receta Médica - QuickMed',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  /// Comparte el enlace de la receta por SMS.
  Future<void> _shareSMS() async {
    setState(() => _sharing = true);
    try {
      final bytes = await _captureImage();
      if (bytes == null) {
        _showError('No se pudo capturar la receta');
        return;
      }

      final file = await _saveImageToTemp(bytes);
      if (file == null) {
        _showError('No se pudo guardar la imagen');
        return;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: _shareText(),
        subject: 'Receta Médica - QuickMed',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  String _shareText() {
    final rx = widget.prescription;
    final meds = rx.medications
        .map((m) => '• ${m.name} — ${m.dose}, ${m.frequency}, ${m.duration}')
        .join('\n');
    return 'Receta Médica — QuickMed\n'
        'Paciente: ${rx.patientId}\n'
        'Fecha: ${rx.date.day}/${rx.date.month}/${rx.date.year}\n\n'
        'Medicamentos:\n$meds\n\n'
        'Verificar receta: ${rx.qrUrl}';
  }

  /// Descarga la receta como imagen a la galería del teléfono (HU 14).
  Future<void> _downloadToGallery() async {
    setState(() => _sharing = true);
    try {
      final bytes = await _captureImage();
      if (bytes == null) {
        _showError('No se pudo capturar la receta');
        return;
      }

      // Verificar permisos de acceso a galería
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // Guardar en la galería del teléfono
      final file = await _saveImageToTemp(bytes);
      if (file == null) {
        _showError('No se pudo preparar la imagen');
        return;
      }
      await Gal.putImage(file.path, album: 'QuickMed');

      if (mounted) {
        setState(() => _saved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Receta guardada en tu galería.\n'
                      'Puedes mostrarla en la farmacia sin internet.'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      _showError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rx = widget.prescription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receta Emitida'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Área capturable como imagen ──
              RepaintBoundary(
                key: _cardKey,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Ícono de éxito
                      const Icon(Icons.check_circle,
                          size: 72, color: Color(0xFF4CAF50)),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Receta emitida exitosamente!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paciente: ${rx.patientId}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fecha: ${rx.date.day}/${rx.date.month}/${rx.date.year}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 24),

                      // QR real (HU 12)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data: rx.toQrData(),
                              version: QrVersions.auto,
                              size: 200,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(0xFF1976D2),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Código: ${rx.qrHash}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'El farmacéutico escaneará este QR\npara verificar la receta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 24),

                      // Lista de medicamentos
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Medicamentos recetados:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...rx.medications.map((m) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE3F2FD),
                                child: Icon(Icons.medication,
                                    color: Color(0xFF1976D2)),
                              ),
                              title: Text(m.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${m.dose} · ${m.frequency} · ${m.duration}'),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Descargar a mi celular (HU 14) ──
              ElevatedButton.icon(
                onPressed: (_sharing || _saved) ? null : _downloadToGallery,
                icon: Icon(
                  _saved ? Icons.check_circle : Icons.download_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                label: Text(
                  _saved
                      ? '¡Guardada en galería!'
                      : 'Descargar a mi celular',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saved
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
              if (_saved)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Puedes mostrar esta imagen en la farmacia\nincluso sin conexión a internet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.green.shade700),
                  ),
                ),

              const SizedBox(height: 24),

              // ── Botones de distribución (HU 13) ──
              const Text(
                'Enviar receta al paciente:',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // WhatsApp
              ElevatedButton.icon(
                onPressed: _sharing ? null : _shareWhatsApp,
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text('Enviar por WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // SMS
              OutlinedButton.icon(
                onPressed: _sharing ? null : _shareSMS,
                icon: const Icon(Icons.sms),
                label: const Text('Enviar por SMS'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Compartir general
              OutlinedButton.icon(
                onPressed: _sharing ? null : _shareGeneral,
                icon: const Icon(Icons.share),
                label: const Text('Compartir de otra forma'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (_sharing) ...[
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],

              const SizedBox(height: 24),

              // Botón volver al panel médico
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const DoctorDashboardScreen()),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Volver al Panel'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
