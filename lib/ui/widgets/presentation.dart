import 'package:flutter/material.dart';
import '../../app_config.dart';
import '../../domain/models.dart';
import 'app_icon.dart';
import 'brand.dart';

Color positive(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return wedding
      ? scheme.primary
      : scheme.brightness == Brightness.dark
      ? const Color(0xFF83D6BA)
      : const Color(0xFF23705B);
}

String initialsOf(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .where((v) => v.isNotEmpty && !['y', '&'].contains(v.toLowerCase()))
    .take(2)
    .map((v) => String.fromCharCode(v.runes.first))
    .join()
    .toUpperCase();

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: !wedding && text.endsWith('.')
          ? text.substring(0, text.length - 1)
          : text,
      children: [
        if (!wedding && text.endsWith('.'))
          const TextSpan(
            text: '.',
            style: TextStyle(color: Color(0xFFE45C87)),
          ),
      ],
    ),
    style: Theme.of(context).textTheme.headlineMedium,
  );
}

class StateMark extends StatelessWidget {
  const StateMark(this.label, {super.key, this.confirmed = true});
  final String label;
  final bool confirmed;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppIcon(
        confirmed ? Symbol.check : Symbol.clock,
        size: 22,
        color: confirmed
            ? positive(context)
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: confirmed
              ? positive(context)
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    ],
  );
}

class AttendanceSummary extends StatelessWidget {
  const AttendanceSummary(this.data, {super.key});
  final Snapshot data;
  @override
  Widget build(BuildContext context) {
    final declined = data.guests.where((g) => g.declined).length;
    if (wedding) {
      Widget metric(String number, String label, {bool main = false}) =>
          Expanded(
            flex: main ? 14 : 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    fontFamily: AppConfig.headingFont,
                    fontSize: main ? 38 : 25,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  width: main ? 86 : 90,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
      final responded = data.guests.where((g) => !g.pending).length;
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              metric(
                '${data.confirmedPeople}',
                'personas confirmadas',
                main: true,
              ),
              Container(
                width: 1,
                height: 45,
                color: Theme.of(context).dividerColor,
              ),
              const SizedBox(width: 15),
              metric('${data.pendingInvitations}', 'pendientes'),
              Container(
                width: 1,
                height: 45,
                color: Theme.of(context).dividerColor,
              ),
              const SizedBox(width: 15),
              metric('$declined', 'no asistirán'),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.guests.isEmpty ? 0 : responded / data.guests.length,
              minHeight: 5,
              color: AppConfig.accent,
              backgroundColor: AppConfig.soft.withValues(alpha: .5),
            ),
          ),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.confirmedPeople}',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge!.copyWith(fontSize: 40),
                ),
                const SizedBox(
                  width: 80,
                  child: Text(
                    'personas confirmadas',
                    style: TextStyle(fontSize: 12, height: 1.15),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryLine(
                  '${data.pendingInvitations} pendientes',
                  const Color(0xFFF4B93C),
                ),
                const SizedBox(height: 10),
                _SummaryLine('$declined no asistirán', const Color(0xFFE45C87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.text, this.color);
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
    ],
  );
}

class BrandRule extends StatelessWidget {
  const BrandRule({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(height: 1, color: AppConfig.accent.withValues(alpha: .65)),
      const SizedBox(height: 3),
      Container(height: 1, color: AppConfig.accent.withValues(alpha: .65)),
    ],
  );
}
