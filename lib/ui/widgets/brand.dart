import '../../l10n/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../app_config.dart';
import '../../state/app_model.dart';
import '../account.dart';
import 'app_icon.dart';
import '../../domain/invitation_details.dart';
import 'event_invitation_details.dart';

bool get wedding => AppConfig.product == 'wedding';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (wedding) ...[
        SvgPicture.asset(
          Theme.of(context).brightness == Brightness.dark
              ? 'assets/brand/mark-dark.svg'
              : 'assets/brand/mark.svg',
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 7),
      ],
      Flexible(
        child: Text.rich(
          TextSpan(
            text: wedding ? 'SAVE THE DATE' : 'the date',
            children: [
              if (!wedding)
                const TextSpan(
                  text: '.',
                  style: TextStyle(color: Color(0xFFE45C87)),
                ),
            ],
          ),
          maxLines: 1,
          style: TextStyle(
            fontFamily: AppConfig.headingFont,
            fontSize: wedding ? 17 : 27,
            fontWeight: wedding ? FontWeight.w600 : FontWeight.w900,
            fontVariations: [FontVariation('wght', wedding ? 600 : 900)],
            letterSpacing: wedding ? 1.8 : -1.2,
            height: 1,
          ),
        ),
      ),
    ],
  );
}

class EventPicker extends StatelessWidget {
  const EventPicker({super.key, required this.model});
  final AppModel model;
  @override
  Widget build(BuildContext context) {
    final multi = model.events.length > 1 || model.event == null;
    final event = model.event;
    final tile = Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        dense: true,
        minVerticalPadding: 8,
        contentPadding: EdgeInsets.fromLTRB(
          wedding ? 16 : 12,
          0,
          wedding ? (multi ? 14 : 20) : 32,
          0,
        ),
        leading: wedding
            ? null
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: event != null && event.photoKey.isNotEmpty
                      ? Image.network(
                          '${AppConfig.api}/events/${Uri.encodeComponent(event.id)}/photos/${Uri.encodeComponent(event.photoKey)}',
                          headers: {
                            if (model.repository.api.token != null)
                              'Authorization':
                                  'Bearer ${model.repository.api.token}',
                          },
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stack) =>
                              const _EventFallback(),
                        )
                      : const _EventFallback(),
                ),
              ),
        title: Text(
          event?.title ?? tr("Elegir evento"),
          style: TextStyle(
            fontFamily: wedding ? AppConfig.headingFont : 'DM Sans',
            fontSize: wedding ? 23 : 14,
            fontWeight: wedding ? FontWeight.w500 : FontWeight.w700,
            height: 1.15,
          ),
        ),
        subtitle: event?.startsAt == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat(
                    'd MMM y',
                    deviceLocale.languageCode,
                  ).format(eventLocalTime(event!, event.startsAt!)),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
        trailing: multi
            ? const RotatedBox(
                quarterTurns: 1,
                child: AppIcon(Symbol.chevron, size: 17),
              )
            : null,
        onTap: multi && !model.busy
            ? () => AccountScreen(model: model).selectEvent(context)
            : null,
      ),
    );
    final Widget card;
    if (wedding) {
      card = ClipRRect(borderRadius: BorderRadius.circular(5), child: tile);
    } else {
      card = Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 24,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFEF88B7),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 12),
            child: ClipPath(
              clipper: _TicketClipper(),
              child: CustomPaint(
                foregroundPainter: _TicketSeam(
                  Theme.of(context).colorScheme.primary.withValues(alpha: .35),
                ),
                child: tile,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        if (event != null) EventInvitationDetails(event: event),
      ],
    );
  }
}

class _EventFallback extends StatelessWidget {
  const _EventFallback();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: Padding(
      padding: const EdgeInsets.all(9),
      child: SvgPicture.asset(
        Theme.of(context).brightness == Brightness.dark
            ? 'assets/brand/mark-dark.svg'
            : 'assets/brand/mark.svg',
      ),
    ),
  );
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      );
    final cuts = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, size.height / 2), radius: 6))
      ..addOval(
        Rect.fromCircle(center: Offset(size.width, size.height / 2), radius: 6),
      );
    return Path.combine(PathOperation.difference, body, cuts);
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => false;
}

class _TicketSeam extends CustomPainter {
  const _TicketSeam(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = .8;
    for (double y = 4; y < size.height; y += 6) {
      canvas.drawLine(
        Offset(size.width - 19, y),
        Offset(size.width - 19, y + 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TicketSeam oldDelegate) => oldDelegate.color != color;
}

/// Theme-aware paper composition, drawn at device resolution without a bitmap.
class AccessArtwork extends StatelessWidget {
  const AccessArtwork({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox(
        height: wedding ? 186 : 150,
        child: Center(
          child: SizedBox(
            width: 300,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _AccessPaper(scheme)),
                ),
                Transform.rotate(
                  angle: wedding ? 0 : -.14,
                  child: SvgPicture.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/brand/mark-dark.svg'
                        : 'assets/brand/mark.svg',
                    width: wedding ? 52 : 62,
                    height: wedding ? 52 : 62,
                    colorFilter: wedding
                        ? ColorFilter.mode(scheme.primary, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessPaper extends CustomPainter {
  const _AccessPaper(this.scheme);
  final ColorScheme scheme;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final fill = Paint()..color = scheme.primaryContainer;
    final line = Paint()
      ..color = scheme.primary.withValues(alpha: .3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(wedding ? -.07 : -.14);
    final rect = Rect.fromCenter(center: Offset.zero, width: 226, height: 112);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(9, 8), const Radius.circular(8)),
      Paint()..color = scheme.primary.withValues(alpha: .14),
    );
    if (wedding) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        fill,
      );
      canvas.drawRect(rect.deflate(10), line);
      canvas.drawRect(
        rect.deflate(14),
        line..color = scheme.primary.withValues(alpha: .15),
      );
    } else {
      canvas.drawPath(
        _TicketClipper().getClip(rect.size).shift(rect.topLeft),
        fill,
      );
      for (double y = -42; y < 48; y += 8) {
        canvas.drawLine(Offset(78, y), Offset(78, y + 4), line);
      }
      final confetti = Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      for (final piece in [
        (
          const Offset(-126, -51),
          const Offset(-132, -62),
          const Color(0xFFE45C87),
        ),
        (
          const Offset(112, -58),
          const Offset(122, -62),
          const Color(0xFFF4B93C),
        ),
        (const Offset(-118, 59), const Offset(-128, 64), scheme.primary),
        (const Offset(132, 48), const Offset(137, 60), const Color(0xFFE45C87)),
      ]) {
        canvas.drawLine(piece.$1, piece.$2, confetti..color = piece.$3);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AccessPaper oldDelegate) => oldDelegate.scheme != scheme;
}
