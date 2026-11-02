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
        SvgPicture.asset('assets/brand/mark.svg', width: 32, height: 32),
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
    final multi = model.events.length > 1,
        dark = Theme.of(context).brightness == Brightness.dark;
    final event = model.event;
    final tile = Material(
      color: dark
          ? Theme.of(context).colorScheme.surfaceContainerLowest
          : (wedding ? const Color(0xFFF3EEE6) : const Color(0xFFFFFAF1)),
      child: ListTile(
        dense: true,
        minVerticalPadding: 8,
        contentPadding: EdgeInsets.fromLTRB(
          wedding ? 16 : 12,
          0,
          multi ? 14 : 20,
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
          event?.title ?? 'Sin celebración activa',
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
                    'es',
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
              child: CustomPaint(foregroundPainter: _TicketSeam(), child: tile),
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
    color: AppConfig.soft,
    child: Padding(
      padding: const EdgeInsets.all(9),
      child: SvgPicture.asset('assets/brand/mark.svg'),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9BEAE)
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
  bool shouldRepaint(_TicketSeam oldDelegate) => false;
}

class AccessArtwork extends StatelessWidget {
  const AccessArtwork({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: wedding ? 270 : 195,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: wedding ? 0 : 32),
            child: Image.asset(
              'assets/brand/access-hero.png',
              fit: wedding ? BoxFit.cover : BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
        if (!wedding)
          Transform.rotate(
            angle: -.22,
            child: SvgPicture.asset(
              'assets/brand/mark.svg',
              width: 56,
              height: 56,
              excludeFromSemantics: true,
            ),
          ),
        if (wedding)
          Positioned(
            bottom: 18,
            left: 24,
            right: 24,
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/brand/mark.svg',
                  width: 38,
                  height: 38,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: 6),
                Text(
                  'SAVE THE DATE',
                  style: TextStyle(
                    fontFamily: AppConfig.headingFont,
                    letterSpacing: 3,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'INVITACIONES DE BODA',
                  style: TextStyle(fontSize: 8, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
