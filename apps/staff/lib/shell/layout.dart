import 'package:flutter/widgets.dart';

/// Screen-width breakpoints, shared by all screens.
///
/// - wide  (>= 1200): PC / wide window — side nav + content + side panel
/// - medium (700–1200): tablet / narrow window — side nav + content, panels open as sheets
/// - phone (< 700): bottom navigation bar, panels open as sheets
const double kWideLayout = 1200;
const double kPhoneLayout = 700;

enum ScreenSize { phone, medium, wide }

/// Which of the three layouts the window is in right now.
ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < kPhoneLayout) return ScreenSize.phone;
  if (width < kWideLayout) return ScreenSize.medium;
  return ScreenSize.wide;
}
