import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a notice is about. Decides its look and its sound.
enum NoticeKind {
  endingSoon, // 10 minutes left
  lastMinute, // 1 minute left
  timeUp, // planned time ran out
  reservation, // a booking (new, or about to start)
}

class Notice {
  Notice({required this.kind, required this.title, this.autoHide});

  final NoticeKind kind;
  final String title;
  final Duration? autoHide; // null = stays until staff close it
}

/// How a notice's sound is played. Tests replace it, so no audio plugin is needed.
final noticeSoundProvider = Provider<void Function(NoticeKind kind)>((ref) => _playNoticeSound);

/// The one place any part of the app posts a message to the staff
/// ("PS5-2: 10 minutes left", later "new booking"). NoticeOverlay draws what is on it.
/// The state is the list of notices showing, newest first.
class NoticeBoardNotifier extends Notifier<List<Notice>> {
  static const maxVisible = 3; // more than this would cover the screen

  final _hideTimers = <Notice, Timer>{};

  @override
  List<Notice> build() {
    ref.onDispose(() {
      for (final timer in _hideTimers.values) {
        timer.cancel();
      }
      _hideTimers.clear();
    });
    return const [];
  }

  void show(NoticeKind kind, String title, {Duration? autoHide}) {
    final notice = Notice(kind: kind, title: title, autoHide: autoHide);
    final next = [notice, ...state];
    while (next.length > maxVisible) {
      _hideTimers.remove(next.removeLast())?.cancel(); // the oldest makes room
    }
    if (autoHide != null) {
      _hideTimers[notice] = Timer(autoHide, () => dismiss(notice));
    }
    state = next;
    ref.read(noticeSoundProvider)(kind);
  }

  void dismiss(Notice notice) {
    _hideTimers.remove(notice)?.cancel();
    if (state.contains(notice)) {
      state = [
        for (final other in state)
          if (other != notice) other,
      ];
    }
  }
}

final noticeBoardProvider = NotifierProvider<NoticeBoardNotifier, List<Notice>>(NoticeBoardNotifier.new);

AudioPlayer? _player; // created on first use

/// Three bell sounds in assets/sounds: calmer when there is time, more insistent when there isn't.
Future<void> _playNoticeSound(NoticeKind kind) async {
  final file = switch (kind) {
    NoticeKind.endingSoon || NoticeKind.reservation => 'sounds/notice_soft.wav',
    NoticeKind.lastMinute => 'sounds/notice_warn.wav',
    NoticeKind.timeUp => 'sounds/notice_urgent.wav',
  };
  try {
    _player ??= AudioPlayer();
    await _player!.play(AssetSource(file)); // a new play() replaces a sound still playing
  } catch (e) {
    // The sound is a bonus: if it fails, the banner must still show.
    debugPrint('Could not play $file: $e');
  }
}
