import 'dart:io';

import 'package:open_api_forked/v3.dart';
import 'package:openapi_code_builder/openapi_code_builder.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: ${Platform.executable} <file>');
    exit(1);
  }
  final fileName = args[0];
  final file = File(fileName);
  final source = await file.readAsString();
  final api = OpenApiCodeBuilderUtils.loadApiFromYaml(source);
  final baseName = path.basenameWithoutExtension(fileName).pascalCase;
  final extraImports =
      ((api.info!.extensions['x-dart-extra-imports'] as ListArchive?) ??
              ListArchive())
          .toList()
          .map((dynamic item) => item.toString())
          .toList();

  final library = OpenApiLibraryGenerator(
    api,
    baseName: baseName,
    partFileName: '${path.basenameWithoutExtension(fileName)}.g.dart',
    useNullSafetySyntax: true,
    ignoreSecuritySchemes: true,
    extraImports: extraImports,
  ).generate();
  final libraryOutput = OpenApiCodeBuilderUtils.formatLibrary(
    library,
    orderDirectives: true,
    useNullSafetySyntax: true,
    doNotPrefix: extraImports,
  );
  print(libraryOutput);
}
