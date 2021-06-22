/**
 * 粗糙版本
 */
class ParsingRouter {
  Map<String, String> files = Map();

  Map<String, String> parsingDeclarationList(Map map) {
    const String DECLARATIONLIST = "declarationList";

    List<Map<dynamic, dynamic>> declarationList = map[DECLARATIONLIST];

    Map<dynamic, dynamic> classDec = declarationList[0];

    List<Map<dynamic, dynamic>> fieldDecs = classDec[DECLARATIONLIST];

    for (Map<dynamic, dynamic> item in fieldDecs) {
      List<Map<dynamic, dynamic>> variableDesc =
          item[DECLARATIONLIST][DECLARATIONLIST];
      Map<dynamic, dynamic> identifierDesc = variableDesc[0]["identifier"];
      Map<dynamic, dynamic> expressionDesc = variableDesc[0]["expression"];
      String key = identifierDesc["name"];
      String value = expressionDesc["value"];
      // print("key = $key ----- value  = $value");
      files[key] = value;
    }

    return files;
  }
}
