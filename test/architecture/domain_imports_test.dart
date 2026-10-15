import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The dependency rule: a feature's domain layer is plain Dart and never
/// reaches out to Firestore, Flutter, Riverpod or the outer layers.
void main() {
  const forbiddenPackages = [
    'package:cloud_firestore',
    'package:flutter/',
    'package:flutter_riverpod',
  ];
  final directive = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''', multiLine: true);

  test('domain layers only depend on plain Dart and other domain code', () {
    final domainFiles = Directory('lib/features')
        .listSync()
        .whereType<Directory>()
        .map((feature) => Directory('${feature.path}/domain'))
        .where((domain) => domain.existsSync())
        .expand((domain) => domain.listSync(recursive: true))
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    expect(domainFiles, isNotEmpty);

    final violations = <String>[
      for (final file in domainFiles)
        for (final match in directive.allMatches(file.readAsStringSync()))
          if (forbiddenPackages.any(match.group(1)!.startsWith) ||
              match.group(1)!.contains('/data/') ||
              match.group(1)!.contains('/presentation/'))
            '${file.path}: ${match.group(1)}',
    ];
    expect(violations, isEmpty);
  });
}
