import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../app_config.dart';
import '../state/app_model.dart';
import 'guests.dart';
import 'gifts.dart';
import 'account.dart';
import 'widgets/app_icon.dart';
import 'widgets/common.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.model});
  final AppModel model;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int tab = 0;
  Timer? timer;
  final scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => widget.model.refresh(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.model.refresh();
      startTimer();
    } else {
      timer?.cancel();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    scroll.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void select(int n) {
    setState(() => tab = n);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/brand/mark.svg',
              width: 30,
              height: 30,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppConfig.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: model.busy ? null : model.refresh,
            icon: const AppIcon(Symbol.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (model.busy) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: model.refresh,
                child: ListView(
                  controller: scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    if (model.error != null)
                      Notice(
                        model.error!,
                        onRetry: model.busy ? null : model.refresh,
                      ),
                    if (tab != 2 && model.event != null) ...[
                      Text(
                        model.event!.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (model.event!.startsAt != null)
                        Text(
                          DateFormat(
                            "d 'de' MMMM 'de' y",
                            'es',
                          ).format(model.event!.startsAt!),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 16),
                    ],
                    if (tab == 2)
                      AccountScreen(model: model)
                    else if (model.event == null)
                      const EmptyState(
                        title: 'Todo empieza con vuestra invitación',
                        body:
                            'Aquí aparecerán las confirmaciones y los regalos de tu evento activo. Usa la misma cuenta con la que lo organizaste.',
                        icon: Symbol.calendar,
                      )
                    else if (model.data == null && model.error == null)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (model.data != null)
                      tab == 0
                          ? GuestsScreen(data: model.data!)
                          : GiftsScreen(data: model.data!),
                    if (tab != 2 && model.updatedAt != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Actualizado a las ${DateFormat('HH:mm').format(model.updatedAt!)} · Desliza para actualizar',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: select,
        destinations: const [
          NavigationDestination(
            icon: AppIcon(Symbol.people),
            label: 'Confirmaciones',
          ),
          NavigationDestination(icon: AppIcon(Symbol.gift), label: 'Regalos'),
          NavigationDestination(icon: AppIcon(Symbol.user), label: 'Cuenta'),
        ],
      ),
    );
  }
}
