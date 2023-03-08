import 'package:code_builder/code_builder.dart';

/// The same as `Allocator.simplePrefixing` but will also not prefix
/// `openapi_base`.
class CustomAllocator implements Allocator {
  CustomAllocator({List<String> doNotPrefix = const <String>[]})
      : _extraImports = doNotPrefix,
        _doNotPrefix = doNotPrefix + _doNotPrefixDefault;

  static const _doNotPrefixDefault = [
    'dart:core',
    'package:openapi_base/openapi_base.dart',
    // https://github.com/google/json_serializable.dart/issues/1115
    'package:json_annotation/json_annotation.dart',
    'package:freezed_annotation/freezed_annotation.dart',
  ];

  final List<String> _doNotPrefix;
  final List<String> _extraImports;

  final _imports = <String, int>{};
  var _keys = 1;

  @override
  String allocate(Reference reference) {
    final symbol = reference.symbol;
    final url = reference.url;
    if (symbol == null) {
      throw ArgumentError.notNull('reference.symbol');
    }
    if (url == null || _doNotPrefix.contains(url)) {
      return symbol;
    }
    return '_i${_imports.putIfAbsent(url, _nextKey)}.$symbol';
  }

  int _nextKey() => _keys++;

  @override
  Iterable<Directive> get imports {
    return _imports.keys
        .map(
          (u) => Directive.import(u, as: '_i${_imports[u]}'),
        )
        .followedBy((_doNotPrefixDefault.where((element) => element.startsWith('package:')).toList() + _extraImports).map((e) => Directive.import(e)));
  }
}
