import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// The form header matching the mockup's `.form-top`: "Cancelar" / title /
/// "Guardar", instead of a default AppBar.
class Finan2FormTop extends StatefulWidget implements PreferredSizeWidget {
  const Finan2FormTop({
    required this.title,
    required this.onSave,
    this.onCancel,
    this.closeIcon = false,
    super.key,
  });

  final String title;
  final Future<void> Function() onSave;
  final VoidCallback? onCancel;

  /// The redesign's `.ftop`: a ✕ instead of the word «Cancelar».
  final bool closeIcon;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  State<Finan2FormTop> createState() => _Finan2FormTopState();
}

class _Finan2FormTopState extends State<Finan2FormTop> {
  bool _saving = false;

  Future<void> _handleSave() async {
    // Guards against the save firing twice from a single tap (e.g. a fast
    // double-tap, or web occasionally delivering duplicate pointer events),
    // which was creating duplicate records.
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSave();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final brand = Theme.of(context).colorScheme.primary;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Finan2Space.xl, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _saving ? null : (widget.onCancel ?? () => Navigator.of(context).pop()),
                child: widget.closeIcon
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Tooltip(
                          message: MaterialLocalizations.of(context).closeButtonTooltip,
                          child: Icon(Icons.close, size: 22, color: colors.inkSoft),
                        ),
                      )
                    : Text(
                        context.l10n.commonCancel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.inkFaint,
                        ),
                      ),
              ),
            ),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: widget.closeIcon ? 15 : 14,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            Expanded(
              child: GestureDetector(
                key: const Key('finan2FormTopSave'),
                behavior: HitTestBehavior.opaque,
                onTap: _saving ? null : _handleSave,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _saving
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(brand),
                          ),
                        )
                      : Text(
                          context.l10n.commonSave,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: widget.closeIcon ? 14.5 : 13,
                            fontWeight: FontWeight.w800,
                            color: brand,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
