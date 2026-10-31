import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum Symbol {
  people,
  gift,
  user,
  check,
  chevron,
  refresh,
  logout,
  mail,
  shield,
  file,
  close,
  flower,
  calendar,
}

class AppIcon extends StatelessWidget {
  const AppIcon(this.symbol, {super.key, this.size = 22, this.color});
  final Symbol symbol;
  final double size;
  final Color? color;
  static const paths = <Symbol, String>{
    Symbol.people:
        '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2m20 0v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/><circle cx="9" cy="7" r="4"/>',
    Symbol.gift:
        '<rect x="3" y="8" width="18" height="4" rx="1"/><path d="M5 12v9h14v-9M12 8v13"/><path d="M12 8H7.5a2.5 2.5 0 1 1 2.45-3A7 7 0 0 1 12 8Zm0 0h4.5a2.5 2.5 0 1 0-2.45-3A7 7 0 0 0 12 8Z"/>',
    Symbol.user:
        '<circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/>',
    Symbol.check: '<path d="m5 12 4 4L19 6"/>',
    Symbol.chevron: '<path d="m9 5 7 7-7 7"/>',
    Symbol.refresh:
        '<path d="M20 7v5h-5M4 17v-5h5"/><path d="M6.1 6a8 8 0 0 1 13.2 3M4.7 15a8 8 0 0 0 13.2 3"/>',
    Symbol.logout:
        '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4m7 14 5-5-5-5M21 12H9"/>',
    Symbol.mail:
        '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>',
    Symbol.shield:
        '<path d="M12 22s8-4 8-11V5l-8-3-8 3v6c0 7 8 11 8 11Z"/><path d="m8 12 3 3 5-6"/>',
    Symbol.file:
        '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z"/><path d="M14 2v6h6M8 13h8m-8 4h6"/>',
    Symbol.close: '<path d="m6 6 12 12M6 18 18 6"/>',
    Symbol.flower:
        '<path d="M12 12C1-2 23-2 12 12Zm0 0C26 1 26 23 12 12Zm0 0C23 26 1 26 12 12Zm0 0C-2 23-2 1 12 12Z"/>',
    Symbol.calendar:
        '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 11h18"/>',
  };
  @override
  Widget build(BuildContext context) => SvgPicture.string(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">${paths[symbol]}</svg>',
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(
      color ??
          IconTheme.of(context).color ??
          Theme.of(context).colorScheme.onSurface,
      BlendMode.srcIn,
    ),
  );
}
