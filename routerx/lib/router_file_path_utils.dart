import 'dart:convert';
import 'dart:io';

import 'package:routerx/routerx_lib.dart';

class FilePathUtils {
  /***
   *  本地引入的 / 远程引入文件
   */
  static String getRemoteOrLocalPath(String root, PackageConfig packageConfig) {
    if (packageConfig.rootUri!.contains("file://")) {
      String pluginRootPath =
          packageConfig.rootUri!.replaceFirst("file://", "");
      return pluginRootPath;
    } else {
      // 本地路径基础是依据.dart_tool -> flutter_build ->
      List<String> pathList = root.split("/");
      // 如果 path ../../ 就是根节点
      int matchCount = way(packageConfig.rootUri!, "../");
      print(" ===============> getRemoteOrLocalPath  matchCount = " +
          matchCount.toString() +
          "  packageConfig.rootUri = " +
          packageConfig.rootUri! +
          "    pathList.length  = " +
          pathList.length.toString());

      String insertPluginProjectPath = "";
      int forTotal = (pathList.length + (-matchCount + 1) - 1);
      if (matchCount >= 2) {
        //与项目同一目录  -2 是因为路径后面 也有一个/
        for (int i = 0; i < (pathList.length + (-matchCount + 1) - 1); i++) {
          insertPluginProjectPath =
              insertPluginProjectPath + (pathList[i] + "/");
          print(
              " ===============> getRemoteOrLocalPath   insertPluginProjectPath =  " +
                  insertPluginProjectPath +
                  "  forTotal = " +
                  forTotal.toString());
        }
      }
      return insertPluginProjectPath + packageConfig.name! + "/";
    }
  }

  /**
   * 方法二：使用replace方法将字符串替换为空，然后求长度
   */
  static int way(String st, String m) {
    int count = (st.length - st.replaceAll(m, "").length) ~/ m.length;
    return count;
  }

  /**
   * 获取.dart_tools 插件路径
   */
  static Future<PackageConfig?> findPluginPath(
      String projectFile, RouterxOptions options) async {
    String json =
        await getRouterPluginPath(projectFile, options.packageConfig!);
    final jsonResult = jsonDecode(json);
    print(" ===============>  projectFile " + projectFile);
    var packagesList = jsonResult["packages"];
    PackageConfig? config;
    for (Map<String, dynamic> item in packagesList) {
      PackageConfig configItem = PackageConfig.toInfo(item);
      if (configItem.name == options.pluginName) {
        return configItem;
      }
    }
    return config;
  }

  /**
   * 1. 获取插件
   */
  static Future<String> getRouterPluginPath(
      String rootPath, String targetFilePath) async {
    File pathFile = File(rootPath + targetFilePath);
    print(" ===============>  getRouterPluginPath " + pathFile.path);
    return pathFile.readAsString();
  }

  static String getRootPath(String input) {
    return getFilePath(input).replaceFirst(RegExp(r'' + input), "");
  }

  static String getFilePath(String input) {
    final String rawInputPath = input;
    final String absInputPath = File(rawInputPath).absolute.path;
    return absInputPath;
  }
}
