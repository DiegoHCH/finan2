import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_bottom_sheet.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
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

const _colorSwatches = [0xFF0F9D74, 0xFFD4453F, 0xFFC8892F, 0xFF7C5CE0, 0xFF2F7FC8, 0xFFD466A6];

class EditCategoryScreen extends ConsumerStatefulWidget {
  const EditCategoryScreen({this.category, super.key});

  final Category? category;

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  late final _nameController = TextEditingController(text: widget.category?.name ?? '');
  late CategoryType _type = widget.category?.type ?? CategoryType.gasto;
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
    await ref
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
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final category = widget.category;
    if (category == null) return;
    final controller = ref.read(categoryControllerProvider.notifier);
    final usage = await controller.usage(category.id);
    if (!mounted) return;

    String? moveTo;
    if (usage.isEmpty) {
      final confirmed = await showFinan2ConfirmSheet(
        context,
        title: 'Eliminar categoría',
        message: 'Se eliminará "${category.name}". Esta acción no se puede deshacer.',
        confirmLabel: 'Eliminar',
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
          title: 'No se puede eliminar todavía',
          message:
              '"${category.name}" tiene ${usage.describe()}. Crea otra categoría '
              'de ${category.type.label.toLowerCase()} para pasarlos ahí y luego '
              'elimina esta.',
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Finan2Space.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿A dónde pasamos lo de ${category.name}?',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: Finan2Space.sm),
                Text(
                  'Tiene ${usage.describe()}. Elige la categoría que se quedará con '
                  'ellos; después "${category.name}" se elimina.',
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

    return Scaffold(
      appBar: Finan2FormTop(
        title: isEditing ? 'Editar categoría' : 'Nueva categoría',
        onSave: _save,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Finan2Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(Finan2Radius.field),
                  border: Border.all(color: colors.line, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Color(_color),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Finan2Icons.categoria(_iconSlug), size: 15, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _nameController.text.isEmpty ? 'Vista previa' : _nameController.text,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2Field(label: 'Nombre', controller: _nameController, validator: null),
            const SizedBox(height: Finan2Space.lg),
            Text('Tipo', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
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
            Text('Ícono', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final slug in icons)
                  Finan2Chip(
                    icon: Finan2Icons.categoria(slug),
                    selected: _iconSlug == slug,
                    onTap: () => setState(() => _iconSlug = slug),
                  ),
              ],
            ),
            const SizedBox(height: Finan2Space.lg),
            Text('Color', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Finan2Space.sm),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final swatch in _colorSwatches)
                  GestureDetector(
                    onTap: () => setState(() => _color = swatch),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(swatch),
                        border: _color == swatch
                            ? Border.all(color: Theme.of(context).colorScheme.surface, width: 2)
                            : null,
                        boxShadow: _color == swatch
                            ? [BoxShadow(color: colors.ink, spreadRadius: 2)]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            if (_type != CategoryType.ingreso) ...[
              const SizedBox(height: Finan2Space.lg),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Acumular de un mes a otro'),
                subtitle: const Text(
                  'Lo que sobre del presupuesto pasa al mes siguiente, y lo que te '
                  'pases se descuenta. Se reinicia cada enero.',
                ),
                value: _rollover,
                onChanged: (value) => setState(() => _rollover = value),
              ),
            ],
            if (isEditing) ...[
              const SizedBox(height: Finan2Space.xxl),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expense),
                child: const Text('Eliminar categoría'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
