import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

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

/// The one place any part of the app posts a message to the staff
/// ("PS5-2: 10 minutes left", later "new booking"). NoticeOverlay draws what is on it.
class NoticeBoard extends ChangeNotifier {
  /// [playSound]: tests pass a fake so no audio plugin is needed.
  NoticeBoard({void Function(NoticeKind kind)? playSound}) : _playSound = playSound ?? _playNoticeSound;

  static const maxVisible = 3; // more than this would cover the screen

  final void Function(NoticeKind kind) _playSound;
  final _notices = <Notice>[]; // newest first
  final _hideTimers = <Notice, Timer>{};

  UnmodifiableListView<Notice> get notices => UnmodifiableListView(_notices);

  void show(NoticeKind kind, String title, {Duration? autoHide}) {
    final notice = Notice(kind: kind, title: title, autoHide: autoHide);
    _notices.insert(0, notice);
    while (_notices.length > maxVisible) {
      _remove(_notices.last); // the oldest makes room
    }
    if (autoHide != null) {
      _hideTimers[notice] = Timer(autoHide, () => dismiss(notice));
    }
    _playSound(kind);
    notifyListeners();
  }

  void dismiss(Notice notice) {
    if (_remove(notice)) notifyListeners();
  }

  bool _remove(Notice notice) {
    _hideTimers.remove(notice)?.cancel();
    return _notices.remove(notice);
  }

  @override
  void dispose() {
    for (final timer in _hideTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}

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
