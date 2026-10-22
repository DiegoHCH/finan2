import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/finan2_tone.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../../core/widgets/finan2_section_label.dart';
import '../../../../core/widgets/finan2_set_row.dart';
import '../../../../core/widgets/finan2_sheet.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../data/category_model.dart';
import '../../data/category_usage.dart';
import '../viewmodels/category_providers.dart';

const _iconsByType = <CategoryType, List<String>>{
  CategoryType.ingreso: ['salario', 'freelance'],
  CategoryType.factura: ['arriendo', 'servicios', 'celular', 'streaming'],
  CategoryType.gasto: [
    'mercado',
    'transporte',
    'vehiculo',
    'ocio',
    'restaurante',
    'salud',
    'educacion',
    'regalo',
    'hogar_aseo',
  ],
  CategoryType.ahorro: ['viaje', 'emergencia', 'meta', 'casa'],
};

const _colorSwatches = Finan2Palette.categorySwatches;

class EditCategoryScreen extends ConsumerStatefulWidget {
  const EditCategoryScreen({this.category, this.initialType = CategoryType.gasto, super.key});

  final Category? category;

  /// A new category's kind - the one Categorías was showing.
  final CategoryType initialType;

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  late final _nameController = TextEditingController(text: widget.category?.name ?? '');
  late CategoryType _type = widget.category?.type ?? widget.initialType;
  late String _iconSlug = widget.category?.iconSlug ?? _iconsByType[_type]!.first;
  late int _color = widget.category?.color ?? _colorSwatches.first;
  late bool _rollover = widget.category?.rollover ?? false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onTypeChanged(CategoryType type) {
    setState(() {
      _type = type;
      if (!_iconsByType[type]!.contains(_iconSlug)) {
        _iconSlug = _iconsByType[type]!.first;
      }
    });
  }

  Future<void> _save() async {
    final name = toTitleCase(_nameController.text);
    if (name.isEmpty) return;
    final id = await ref
        .read(categoryControllerProvider.notifier)
        .save(
          Category(
            id: widget.category?.id ?? '',
            name: name,
            type: _type,
            iconSlug: _iconSlug,
            color: _color,
            // Income isn't budgeted, so there's nothing to carry.
            rollover: _type != CategoryType.ingreso && _rollover,
            createdBy:
                widget.category?.createdBy ?? ref.read(authStateChangesProvider).value?.uid ?? '',
          ),
        );
    // With its ID, so Anotar and Fijos can select the one just created.
    if (mounted) Navigator.of(context).pop(id);
  }

  Future<void> _delete() async {
    final category = widget.category;
    if (category == null) return;
    final controller = ref.read(categoryControllerProvider.notifier);
    final usage = await controller.usage(category.id);
    if (!mounted) return;
    final l10n = context.l10n;

    String? moveTo;
    if (usage.isEmpty) {
      final confirmed = await showFinan2ConfirmSheet(
        context,
        title: l10n.categoriesDeleteTitle,
        message: l10n.categoriesDeleteMessage(category.name),
        confirmLabel: l10n.commonDelete,
        destructive: true,
      );
      if (!confirmed) return;
    } else {
      // Anything left pointing at a deleted category would show up blank,
      // so it has to go somewhere first.
      final options = (ref.read(categoriesProvider).value ?? const <Category>[])
          .where((c) => c.type == category.type && c.id != category.id)
          .toList();
      if (options.isEmpty) {
        await showFinan2InfoSheet(
          context,
          title: l10n.categoriesCannotDeleteYetTitle,
          message: l10n.categoriesCannotDeleteYetMessage(
            category.name,
            usage.describe(),
            category.type.label.toLowerCase(),
          ),
        );
        return;
      }
      final target = await _pickReplacement(category, usage, options);
      if (target == null) return;
      moveTo = target.id;
    }

    await controller.delete(category.id, moveTo: moveTo);
    if (!mounted) return;
    final result = ref.read(categoryControllerProvider);
    if (result.hasError) {
      await showFinan2ErrorSheet(context, message: friendlyErrorMessage(result.error!));
      return;
    }
    Navigator.of(context).pop();
  }

  Future<Category?> _pickReplacement(
    Category category,
    CategoryUsage usage,
    List<Category> options,
  ) {
    return showModalBottomSheet<Category>(
      context: context,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).extension<Finan2Colors>()!;
        final l10n = sheetContext.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Finan2Space.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.categoriesReassignTitle(category.name),
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: Finan2Space.sm),
                Text(
                  l10n.categoriesReassignMessage(usage.describe(), category.name),
                  style: TextStyle(fontSize: 13, color: colors.inkSoft, height: 1.45),
                ),
                const SizedBox(height: Finan2Space.lg),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final option in options)
                      Finan2Chip(
                        icon: Finan2Icons.categoria(option.iconSlug),
                        label: option.name,
                        selected: false,
                        onTap: () => Navigator.of(sheetContext).pop(option),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final isEditing = widget.category != null;
    final icons = _iconsByType[_type]!;
    final tone = Finan2Tone.of(context, Color(_color));
    final l10n = context.l10n;

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? l10n.categoriesEditTitle : l10n.categoriesNewTitle,
        onSave: _save,
        closeIcon: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Finan2Space.lg,
          Finan2Space.sm,
          Finan2Space.lg,
          Finan2Space.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // How it will look, while color and icon are chosen.
            Row(
              key: const Key('categoryPreview'),
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: tone.tint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Finan2Icons.categoria(_iconSlug), size: 26, color: tone.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // Follows the name as it's typed.
                  child: ListenableBuilder(
                    listenable: _nameController,
                    builder: (context, _) {
                      final name = _nameController.text.trim();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? l10n.categoriesPreview : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: name.isEmpty ? colors.inkFaint : colors.ink,
                            ),
                          ),
                          Text(_type.label, style: TextStyle(fontSize: 12, color: colors.inkFaint)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2Field(label: l10n.commonName, controller: _nameController, validator: null),
            const SizedBox(height: Finan2Space.lg),
            Finan2SectionLabel(l10n.categoriesTypeLabel),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final type in CategoryType.values)
                  Finan2Chip(
                    label: type.label,
                    selected: _type == type,
                    onTap: () => _onTypeChanged(type),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2SectionLabel(l10n.categoriesColor),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final swatch in _colorSwatches)
                  _Swatch(
                    color: Finan2Tone.of(context, Color(swatch)).color,
                    selected: _color == swatch,
                    onTap: () => setState(() => _color = swatch),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2SectionLabel(l10n.categoriesIcon),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final slug in icons)
                  Finan2Chip(
                    icon: Finan2Icons.categoria(slug),
                    tone: tone,
                    selected: _iconSlug == slug,
                    onTap: () => setState(() => _iconSlug = slug),
                  ),
              ],
            ),
            if (_type != CategoryType.ingreso) ...[
              const SizedBox(height: Finan2Space.lg),
              Finan2Sheet(
                children: [
                  Finan2SetRow(
                    label: l10n.categoriesRolloverTitle,
                    detail: l10n.categoriesRolloverSubtitle,
                    trailing: Switch(
                      value: _rollover,
                      onChanged: (value) => setState(() => _rollover = value),
                    ),
                  ),
                ],
              ),
            ],
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.xl),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: Text(l10n.categoriesDeleteTitle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A `.colors` dot; the chosen one is ringed in ink.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? colors.ink : Colors.transparent, width: 2),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}
