import 'package:al3b_staff/shell/notice_board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('show puts the newest first and plays the sound for its kind', () {
    final played = <NoticeKind>[];
    final board = NoticeBoard(playSound: played.add);

    board.show(NoticeKind.endingSoon, 'first');
    board.show(NoticeKind.timeUp, 'second');

    expect(board.notices.map((n) => n.title).toList(), ['second', 'first']);
    expect(played, [NoticeKind.endingSoon, NoticeKind.timeUp]);
    board.dispose();
  });

  test('keeps at most 3 and drops the oldest', () {
    final board = NoticeBoard(playSound: (_) {});
    for (final title in ['a', 'b', 'c', 'd']) {
      board.show(NoticeKind.timeUp, title);
    }
    expect(board.notices.map((n) => n.title).toList(), ['d', 'c', 'b']);
    board.dispose();
  });

  test('dismiss removes one notice and notifies', () {
    final board = NoticeBoard(playSound: (_) {});
    board.show(NoticeKind.timeUp, 'a');
    board.show(NoticeKind.timeUp, 'b');
    var notified = 0;
    board.addListener(() => notified++);

    board.dismiss(board.notices.first); // 'b'

    expect(board.notices.map((n) => n.title).toList(), ['a']);
    expect(notified, 1);
    board.dispose();
  });

  testWidgets('autoHide removes the notice after its time, no autoHide stays', (tester) async {
    final board = NoticeBoard(playSound: (_) {});
    board.show(NoticeKind.endingSoon, 'goes away', autoHide: const Duration(seconds: 10));
    board.show(NoticeKind.timeUp, 'stays');

    await tester.pump(const Duration(seconds: 11));

    expect(board.notices.map((n) => n.title).toList(), ['stays']);
    board.dispose();
  });
}
