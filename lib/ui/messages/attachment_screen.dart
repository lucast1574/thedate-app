import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:video_player/video_player.dart';

import '../../data/messages_repository.dart';
import '../../domain/message_models.dart';
import '../../l10n/translate.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';

Future<void> showMessageAttachment(
  BuildContext context,
  MessagesRepository api,
  GuestMessage message,
) async {
  if (message.media?.available != true) return;
  FocusManager.instance.primaryFocus?.unfocus();
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      requestFocus: false,
      builder: (_) => _AttachmentScreen(api: api, message: message),
    ),
  );
}

class _AttachmentScreen extends StatefulWidget {
  const _AttachmentScreen({required this.api, required this.message});
  final MessagesRepository api;
  final GuestMessage message;

  @override
  State<_AttachmentScreen> createState() => _AttachmentScreenState();
}

class _AttachmentScreenState extends State<_AttachmentScreen> {
  Future<Uint8List>? bytes;
  int attempt = 0;

  MessageAttachment get media => widget.message.media!;

  @override
  void initState() {
    super.initState();
    if (media.image || media.pdf) bytes = widget.api.media(widget.message.id);
  }

  void retry() => setState(() {
    attempt++;
    if (media.image || media.pdf) bytes = widget.api.media(widget.message.id);
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        key: const Key('close-attachment'),
        tooltip: tr('Cerrar adjunto'),
        icon: const AppIcon(Symbol.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        media.filename.isEmpty ? tr('Adjunto') : media.filename,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    body: SafeArea(
      top: false,
      child: bytes != null
          ? FutureBuilder<Uint8List>(
              future: bytes,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) return _AttachmentError(onRetry: retry);
                final data = snapshot.requireData;
                return media.pdf
                    ? _PdfAttachment(
                        key: ValueKey(attempt),
                        data: data,
                        onRetry: retry,
                      )
                    : InteractiveViewer(
                        child: Center(
                          child: Image.memory(
                            data,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                _AttachmentError(onRetry: retry),
                          ),
                        ),
                      );
              },
            )
          : media.audio || media.video
          ? _PlayableAttachment(
              key: ValueKey(attempt),
              api: widget.api,
              message: widget.message,
              onRetry: retry,
            )
          : const _AttachmentError(),
    ),
  );
}

class _PdfAttachment extends StatefulWidget {
  const _PdfAttachment({super.key, required this.data, required this.onRetry});
  final Uint8List data;
  final VoidCallback onRetry;

  @override
  State<_PdfAttachment> createState() => _PdfAttachmentState();
}

class _PdfAttachmentState extends State<_PdfAttachment> {
  late final controller = PdfControllerPinch(
    document: PdfDocument.openData(widget.data),
  );
  bool failed = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => failed
      ? _AttachmentError(onRetry: widget.onRetry)
      : PdfViewPinch(
          controller: controller,
          onDocumentError: (_) {
            if (mounted) setState(() => failed = true);
          },
        );
}

class _PlayableAttachment extends StatefulWidget {
  const _PlayableAttachment({
    super.key,
    required this.api,
    required this.message,
    required this.onRetry,
  });
  final MessagesRepository api;
  final GuestMessage message;
  final VoidCallback onRetry;

  @override
  State<_PlayableAttachment> createState() => _PlayableAttachmentState();
}

class _PlayableAttachmentState extends State<_PlayableAttachment> {
  VideoPlayerController? player;
  Directory? directory;
  File? file;
  late final started = start();

  Future<void> start() async {
    final data = await widget.api.media(widget.message.id);
    if (!mounted) return;
    final extension = switch (widget.message.media!.mime) {
      'audio/ogg' || 'application/ogg' => 'ogg',
      'audio/mpeg' => 'mp3',
      'audio/mp4' || 'audio/x-m4a' => 'm4a',
      'audio/aac' => 'aac',
      'audio/wav' || 'audio/x-wav' => 'wav',
      'audio/webm' || 'video/webm' => 'webm',
      'video/quicktime' => 'mov',
      'video/3gpp' => '3gp',
      _ => 'mp4',
    };
    directory = await Directory.systemTemp.createTemp('thedate-media-');
    file = File('${directory!.path}/attachment.$extension');
    await file!.writeAsBytes(data);
    if (!mounted) return;
    player = VideoPlayerController.file(file!);
    await player!.initialize();
  }

  Future<void> release() async {
    try {
      await started;
    } catch (_) {
      // The viewer has already reported the load error.
    }
    try {
      await player?.dispose();
    } finally {
      try {
        if (await file?.exists() ?? false) await file!.delete();
        await directory?.delete();
      } on FileSystemException {
        // The operating system can reclaim the app's temporary directory.
      }
    }
  }

  @override
  void dispose() {
    unawaited(release());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: started,
    builder: (context, activation) {
      if (activation.hasError) return _AttachmentError(onRetry: widget.onRetry);
      if (activation.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      final player = this.player;
      if (player == null) return _AttachmentError(onRetry: widget.onRetry);
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: player,
        builder: (context, value, _) {
          if (value.hasError) return _AttachmentError(onRetry: widget.onRetry);
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.message.media!.video)
                    AspectRatio(
                      aspectRatio: value.aspectRatio,
                      child: VideoPlayer(player),
                    ),
                  const SizedBox(height: 16),
                  VideoProgressIndicator(player, allowScrubbing: true),
                  const SizedBox(height: 12),
                  IconButton.filled(
                    tooltip: value.isPlaying
                        ? tr('Pausar reproducción')
                        : tr('Reproducir adjunto'),
                    icon: AppIcon(
                      value.isPlaying ? Symbol.pause : Symbol.play,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () => unawaited(
                      value.isPlaying ? player.pause() : player.play(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _AttachmentError extends StatelessWidget {
  const _AttachmentError({this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Notice(tr('No pudimos abrir el adjunto.'), onRetry: onRetry),
    ),
  );
}
