import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'pharmacy_scanner_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.health_and_safety,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'QuickMed',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona cómo quieres entrar',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // --- Botón Paciente ---
              _RoleCard(
                icon: Icons.person,
                label: 'Paciente',
                subtitle: 'Necesito atención médica',
                color: const Color(0xFF4CAF50),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              const SizedBox(height: 16),

              // --- Botón Doctor ---
              _RoleCard(
                icon: Icons.medical_services,
                label: 'Doctor',
                subtitle: 'Atender pacientes',
                color: const Color(0xFF2196F3),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
                ),
              ),
              const SizedBox(height: 16),

              // --- Botón Farmacéutico (HU 15) ---
              _RoleCard(
                icon: Icons.local_pharmacy,
                label: 'Farmacéutico',
                subtitle: 'Verificar recetas',
                color: const Color(0xFFFF9800),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PharmacyScannerScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
