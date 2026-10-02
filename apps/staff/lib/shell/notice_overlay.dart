import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'notice_board.dart';

/// Draws the notices on top of the whole app, at the top of the screen
/// (the bottom is where the main buttons and the phone's nav bar are).
/// Placed once, in MaterialApp's `builder`, so it floats over every page.
class NoticeOverlay extends StatelessWidget {
  const NoticeOverlay({super.key, required this.board, required this.child});

  final NoticeBoard board;
  final Widget child; // the whole app

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        SafeArea(
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(12),
                // Only the cards catch taps; the empty space around them
                // passes taps through to the page underneath.
                child: ListenableBuilder(
                  listenable: board,
                  builder: (context, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final notice in board.notices)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 8),
                          child: _NoticeCard(notice: notice, onClose: () => board.dismiss(notice)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice, required this.onClose});

  final Notice notice;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // (card color, text color, icon color, icon). Same colors as the tiles:
    // coral = needs action, lavender = booking.
    final (background, foreground, iconColor, icon) = switch (notice.kind) {
      NoticeKind.endingSoon => (AppColors.raised, AppColors.text, AppColors.free, Icons.hourglass_bottom_rounded),
      NoticeKind.lastMinute => (AppColors.raised, AppColors.text, AppColors.waitingPayment, Icons.timer_outlined),
      NoticeKind.timeUp => (AppColors.waitingPayment, AppColors.onWaitingPayment, AppColors.onWaitingPayment, Icons.alarm_rounded),
      NoticeKind.reservation => (AppColors.reserved, AppColors.onReserved, AppColors.onReserved, Icons.event_outlined),
    };

    return Material(
      color: background,
      elevation: 8,
      shadowColor: Colors.black,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 8, 10),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                notice.title,
                style: TextStyle(color: foreground, fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
