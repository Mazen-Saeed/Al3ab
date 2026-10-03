import 'package:al3b_staff/shell/notice_board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A container whose notices play [onSound] instead of a real sound. Closed after the test.
ProviderContainer makeBoard([void Function(NoticeKind kind)? onSound]) {
  final container = ProviderContainer(overrides: [
    noticeSoundProvider.overrideWith((ref) => onSound ?? (_) {}),
  ]);
  addTearDown(container.dispose);
  return container;
}

List<String> titles(ProviderContainer c) => c.read(noticeBoardProvider).map((n) => n.title).toList();

void main() {
  test('show puts the newest first and plays the sound for its kind', () {
    final played = <NoticeKind>[];
    final c = makeBoard(played.add);
    final board = c.read(noticeBoardProvider.notifier);

    board.show(NoticeKind.endingSoon, 'first');
    board.show(NoticeKind.timeUp, 'second');

    expect(titles(c), ['second', 'first']);
    expect(played, [NoticeKind.endingSoon, NoticeKind.timeUp]);
  });

  test('keeps at most 3 and drops the oldest', () {
    final c = makeBoard();
    final board = c.read(noticeBoardProvider.notifier);
    for (final title in ['a', 'b', 'c', 'd']) {
      board.show(NoticeKind.timeUp, title);
    }
    expect(titles(c), ['d', 'c', 'b']);
  });

  test('dismiss removes one notice', () {
    final c = makeBoard();
    final board = c.read(noticeBoardProvider.notifier);
    board.show(NoticeKind.timeUp, 'a');
    board.show(NoticeKind.timeUp, 'b');

    board.dismiss(c.read(noticeBoardProvider).first); // 'b'

    expect(titles(c), ['a']);
  });

  testWidgets('autoHide removes the notice after its time, no autoHide stays', (tester) async {
    final c = makeBoard();
    final board = c.read(noticeBoardProvider.notifier);
    board.show(NoticeKind.endingSoon, 'goes away', autoHide: const Duration(seconds: 10));
    board.show(NoticeKind.timeUp, 'stays');

    await tester.pump(const Duration(seconds: 11));

    expect(titles(c), ['stays']);
  });
}
