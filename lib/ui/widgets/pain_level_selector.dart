import 'package:flutter/material.dart';
import '../../data/models/triage_session_model.dart';

/// Configuración visual de cada nivel de dolor (semáforo).
class PainLevelOption {
  final PainLevel level;
  final String label;
  final String emoji;
  final Color color;
  final String description;

  const PainLevelOption({
    required this.level,
    required this.label,
    required this.emoji,
    required this.color,
    required this.description,
  });
}

const List<PainLevelOption> kPainOptions = [
  PainLevelOption(
    level: PainLevel.mild,
    label: 'Leve',
    emoji: '😊',
    color: Color(0xFF4CAF50), // Verde
    description: 'Me molesta un poco',
  ),
  PainLevelOption(
    level: PainLevel.moderate,
    label: 'Moderado',
    emoji: '😐',
    color: Color(0xFFFFC107), // Amarillo
    description: 'Duele bastante',
  ),
  PainLevelOption(
    level: PainLevel.severe,
    label: 'Fuerte',
    emoji: '😣',
    color: Color(0xFFF44336), // Rojo
    description: 'No puedo aguantar',
  ),
];

/// Selector visual de nivel de dolor con colores semafóricos y emojis.
class PainLevelSelector extends StatelessWidget {
  final PainLevel? selected;
  final ValueChanged<PainLevel> onSelected;

  const PainLevelSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: kPainOptions.map((option) {
        final isSelected = selected == option.level;

        return GestureDetector(
          onTap: () => onSelected(option.level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected
                  ? option.color
                  : option.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: option.color,
                width: isSelected ? 0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: option.color.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Text(
                  option.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : option.color,
                        ),
                      ),
                      Text(
                        option.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white.withOpacity(0.85)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.white, size: 26),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
