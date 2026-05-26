import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'patient_home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  String? _errorMessage;

  // Temporizador de 5 minutos
  static const int _totalSeconds = 5 * 60;
  int _secondsLeft = _totalSeconds;
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    )..forward();

    _timerController.addListener(() {
      setState(() {
        _secondsLeft = (_totalSeconds * (1 - _timerController.value)).round();
      });
    });

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _errorMessage = 'El código ha expirado. Vuelve atrás y solicita uno nuevo.');
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timerController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _submit() async {
    if (_fullCode.length < 4) {
      setState(() => _errorMessage = 'Completa los 4 dígitos del código.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.verifyOTP(_fullCode);

    if (!mounted) return;

    if (error == null) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = error;
        // Limpiar los campos para que el usuario reintente
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final phone = context.read<AuthProvider>().currentUser?.phone ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final isExpired = _secondsLeft <= 0;
    final isWarning = _secondsLeft <= 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de seguridad'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.sms_outlined,
              size: 80,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Revisa tu celular',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Te enviamos un código de 4 dígitos al número $phone',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            // Hint para simulación
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Text(
                '🧪 Modo demo: el código es 1234',
                style: TextStyle(fontSize: 13, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // --- Campos de dígitos ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 64,
                  height: 72,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    enabled: !isExpired && !isLoading,
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.secondary,
                          width: 2.5,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onDigitChanged(index, value),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // --- Temporizador ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: isWarning ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  isExpired ? 'Código expirado' : 'Expira en $_formattedTime',
                  style: TextStyle(
                    fontSize: 15,
                    color: isWarning ? Colors.red : Colors.grey.shade600,
                    fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Mensaje de error ---
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade800, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 24),

            // --- Botón verificar ---
            ElevatedButton(
              onPressed: (isLoading || isExpired) ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verificar código', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
