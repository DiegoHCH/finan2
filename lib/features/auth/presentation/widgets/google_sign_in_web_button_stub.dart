import 'package:flutter/widgets.dart';

/// Non-web platforms use the native Google Sign-In sheet instead (see
/// login_screen.dart) - this is never actually shown there.
class GoogleSignInWebButton extends StatelessWidget {
  const GoogleSignInWebButton({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
