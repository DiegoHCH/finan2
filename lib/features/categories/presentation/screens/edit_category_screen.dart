import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/text_case.dart';
import '../../../../core/widgets/finan2_chip.dart';
import '../../../../core/widgets/finan2_field.dart';
import '../../../../core/widgets/finan2_form_top.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../data/category_model.dart';
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

const _colorSwatches = [
  0xFF0F9D74,
  0xFFD4453F,
  0xFFC8892F,
  0xFF7C5CE0,
  0xFF2F7FC8,
  0xFFD466A6,
];

class EditCategoryScreen extends ConsumerStatefulWidget {
  const EditCategoryScreen({this.category, super.key});

  final Category? category;

  @override
  ConsumerState<EditCategoryScreen> createState() =>
      _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  late final _nameController = TextEditingController(
    text: widget.category?.name ?? '',
  );
  late CategoryType _type = widget.category?.type ?? CategoryType.gasto;
  late String _iconSlug =
      widget.category?.iconSlug ?? _iconsByType[_type]!.first;
  late int _color = widget.category?.color ?? _colorSwatches.first;

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
    await ref.read(categoryControllerProvider.notifier).save(
          Category(
            id: widget.category?.id ?? '',
            name: name,
            type: _type,
            iconSlug: _iconSlug,
            color: _color,
            createdBy: widget.category?.createdBy ??
                ref.read(authStateChangesProvider).value?.uid ??
                '',
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final category = widget.category;
    if (category == null) return;
    await ref.read(categoryControllerProvider.notifier).delete(category.id);
    if (mounted) Navigator.of(context).pop();
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
                      child: Icon(
                        Finan2Icons.categoria(_iconSlug),
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Vista previa'
                          : _nameController.text,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Finan2Space.lg),
            Finan2Field(
              label: 'Nombre',
              controller: _nameController,
              validator: null,
            ),
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
                            ? Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              )
                            : null,
                        boxShadow: _color == swatch
                            ? [
                                BoxShadow(
                                  color: colors.ink,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
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
