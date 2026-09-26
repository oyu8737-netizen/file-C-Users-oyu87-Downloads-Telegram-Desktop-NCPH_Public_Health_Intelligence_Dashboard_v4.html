import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Энгийн багана график (нэг цуврал): өдөр бүрийн алхам, бүртгэл гэх мэт.
///
/// - Багана бүрт хүрэхэд яг тоо нь tooltip-ээр гарна.
/// - [goal] өгвөл тасархай биш нимгэн зорилгын шугам татна.
class SimpleBarChart extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  final int? goal;
  final String Function(int value) tooltip;
  final double height;

  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.tooltip,
    this.goal,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final maxValue =
        math.max(values.fold<int>(0, math.max), goal ?? 0).clamp(1, 1 << 31);

    return SizedBox(
      height: height + 24,
      child: LayoutBuilder(builder: (context, box) {
        return Stack(
          children: [
            if (goal != null)
              Positioned(
                left: 0,
                right: 0,
                top: height - height * goal! / maxValue,
                child: Container(height: 1, color: scheme.outline),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++)
                  Expanded(
                    child: Tooltip(
                      message: tooltip(values[i]),
                      triggerMode: TooltipTriggerMode.tap,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            // Багана хооронд 2px зай.
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: math.max(
                                values[i] == 0 ? 0 : 2,
                                height * values[i] / maxValue),
                            decoration: BoxDecoration(
                              color: goal != null && values[i] >= goal!
                                  ? scheme.primary
                                  : scheme.primary.withValues(alpha: 0.45),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(labels[i],
                              style: text.labelSmall
                                  ?.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
