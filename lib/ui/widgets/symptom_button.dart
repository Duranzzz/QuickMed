import 'package:flutter/material.dart';
import '../../data/models/symptom_model.dart';

/// Botón grande de síntoma con ícono y etiqueta de una sola palabra.
/// Diseñado para ser accesible con el dedo en pantallas pequeñas.
class SymptomButton extends StatelessWidget {
  final Symptom symptom;
  final bool isSelected;
  final VoidCallback onTap;

  const SymptomButton({
    super.key,
    required this.symptom,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              symptom.icon,
              size: 36,
              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Text(
              symptom.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
