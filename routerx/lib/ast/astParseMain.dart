import 'dart:convert';
import 'dart:core';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:routerx/ast/parsing_router.dart';

import 'astVisitor.dart';

Map<String, String>? astParseMain(String path) {
  var compilationUnit =
      parseFile(path: path, featureSet: FeatureSet.fromEnableFlags([]));
  var compilation = compilationUnit.unit;

  var map = compilation.accept(AstVisitor());
  print("====== ast解析 =========> ");
  print( jsonEncode(map));
  print("====== ast解析 =========> ");

  ParsingRouter parsing = ParsingRouter();

  if (map != null) {
    Map<String, String> fileMap = parsing.parsingDeclarationList(map);
    // String json = jsonEncode(fileMap);
    return fileMap;
  } else {
    print(" router config ast  parse  error ");
    return null;
  }
}
