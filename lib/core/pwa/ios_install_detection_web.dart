import 'package:web/web.dart' as web;

bool get isIOSSafariNotInstalled {
  final nav = web.window.navigator;
  final ua = nav.userAgent;
  final isIOS =
      RegExp(r'iPad|iPhone|iPod').hasMatch(ua) ||
      // iPadOS reports as a Mac with touch support since iOS 13.
      (nav.platform == 'MacIntel' && nav.maxTouchPoints > 1);
  if (!isIOS) return false;
  final standalone = web.window.matchMedia('(display-mode: standalone)').matches;
  return !standalone;
}
