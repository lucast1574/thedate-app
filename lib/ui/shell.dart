import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/brand.dart';
import 'widgets/presentation.dart';
import 'package:intl/intl.dart';
import '../state/app_model.dart';
import 'guests.dart';
import 'event_record.dart';
import 'gifts.dart';
import 'account.dart';
import 'widgets/bottom_tabs.dart';
import 'widgets/invitation_start.dart';
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
    timer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!widget.model.viewingRecord && widget.model.event != null) {
        widget.model.refresh();
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.model.refresh();
      widget.model.syncNotifications();
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
    widget.model.cancelNotificationNavigation();
    setState(() => tab = n);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final destination = model.takeNotificationTab();
    if (destination != null) tab = destination;
    return PopScope(
      canPop: tab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && tab != 0) select(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const BrandWordmark(),
          toolbarHeight: 62,
          actions: [
            if (!wedding && tab == 2)
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: SvgPicture.asset(
                  'assets/brand/mark.svg',
                  width: 40,
                  height: 40,
                  excludeFromSemantics: true,
                ),
              ),
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
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    children: [
                      if (model.error != null)
                        Notice(
                          model.error!,
                          onRetry: model.busy ? null : model.refresh,
                        ),
                      if (tab != 2 && model.events.isNotEmpty) ...[
                        EventPicker(model: model),
                        if (wedding) ...[
                          const SizedBox(height: 12),
                          const BrandRule(),
                        ],
                        const SizedBox(height: 16),
                      ],
                      if (tab == 2)
                        AccountScreen(model: model)
                      else if (model.event == null && model.busy)
                        const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (model.event == null &&
                          model.error == null &&
                          model.events.isEmpty)
                        InvitationStart(
                          key: ValueKey('empty-$tab'),
                          gifts: tab == 1,
                        )
                      else if (model.event == null && model.events.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Elige un evento para consultar su información.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      else if (model.viewingRecord && model.data != null)
                        EventRecord(
                          repository: model.repository,
                          data: model.data!,
                          event: model.event!,
                          gifts: tab == 1,
                        )
                      else if (model.data == null && model.error == null)
                        const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (model.data != null)
                        tab == 0
                            ? GuestsScreen(
                                key: ValueKey(model.event!.id),
                                data: model.data!,
                              )
                            : GiftsScreen(
                                token: model.repository.api.token,
                                key: ValueKey(model.event!.id),
                                data: model.data!,
                              ),
                      if (tab != 2 && model.updatedAt != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Actualizado a las ${DateFormat('HH:mm').format(model.updatedAt!)}',
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
        bottomNavigationBar: BottomTabs(selected: tab, onSelected: select),
      ),
    );
  }
}
