import 'dart:io';
import 'dart:mirrors';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:routerx/ast/astParseMain.dart';
import 'package:routerx/router_file_path_utils.dart';

import 'create_native.dart';

class Routerx {
  //需要添加事项
  static final ArgParser _argParser = ArgParser()
    ..addOption('input', help: 'REQUIRED: Path to pigeon file.')
    ..addOption('package_config', help: 'REQUIRED: package_config  no found');

  static Future<int> run(List<String> args, {Uri? packageConfig}) async {
    print(" ===============>  Routerx run");
    RouterxOptions options = Routerx.parseArgs(args);

    //获取 宿主项目 文件配置东西
    _executeConfigurePigeon(options);

    print(" ===============> 文件配置 = " + options.toString());

    if (options.routerConfigPath == null || options.routerConfigPath!.isEmpty) {
      print("未进行配置 文件");
      return 1;
    }
    // ast
    Map<String, String>? routerJson =
        astParseMain(FilePathUtils.getFilePath(options.routerConfigPath!));
    if (routerJson == null || routerJson.isEmpty) {
      return 1;
    }

    // xxx/flutter_module/
    String projectFile = FilePathUtils.getRootPath(options.input!);
    print("===============>  routerJson =  " + routerJson.toString());
    // 读取.dart_tools文件

    PackageConfig? pluginPath =
        await FilePathUtils.findPluginPath(projectFile, options);
    if (pluginPath != null) {
      print(" ===============>  findPluginPath  pluginPath " +
          pluginPath.toString());

      //区分 本地引入/远程 映入
      String remoteOrLocalPath =
          FilePathUtils.getRemoteOrLocalPath(projectFile, pluginPath);
      print(" ===============> remoteOrLocalPath  " + remoteOrLocalPath);
      /**
       * 创建文件
       * 优化
       */
      print(" ===============> 文件创建开始 ");
      Future<dynamic> androidFile = NativeFile.createAndroidPluginClass(
          options, remoteOrLocalPath, routerJson);

      Future<dynamic> iosFile = NativeFile.createOCPluginClass(
          options, remoteOrLocalPath, routerJson);

      List<dynamic> files = await Future.wait<dynamic>([androidFile, iosFile]);
      print(" ===============> 文件创建完毕  files = " + files.toString());
    } else {
      print(" ===============> pluginPath == null 未生成成功");
    }
    return 1;
  }

  static Routerx setup() {
    return Routerx();
  }

  static RouterxOptions parseArgs(List<String> args) {
    final ArgResults results = _argParser.parse(args);
    final RouterxOptions opts = RouterxOptions();
    opts.input = results['input'];
    return opts;
  }

  static void _executeConfigurePigeon(RouterxOptions options) {
    print(" ===============> _executeConfigurePigeon " +
        (currentMirrorSystem().libraries.values.length).toString());
    for (final LibraryMirror library
        in currentMirrorSystem().libraries.values) {
      for (final DeclarationMirror declaration in library.declarations.values) {
        if (declaration is MethodMirror &&
            MirrorSystem.getName(declaration.simpleName) == 'configureRouter') {
          if (declaration.parameters.length == 1 &&
              declaration.parameters[0].type == reflectClass(RouterxOptions)) {
            library.invoke(declaration.simpleName, <dynamic>[options]);
          } else {
            print('warning: invalid \'configurePigeon\' method defined.');
          }
        }
      }
    }
  }
}

abstract class Generator {
  IOSink shouldGenerate();

  void generate(StringSink sink);
}

class PackageConfig {
  String? name;
  String? rootUri;
  String? packageUri;
  String? languageVersion;

  PackageConfig(
      {this.name, this.rootUri, this.packageUri, this.languageVersion});

  static toInfo(Map<String, dynamic> parseMap) {
    return PackageConfig(
      name: parseMap["name"],
      rootUri: parseMap["rootUri"],
      packageUri: parseMap["packageUri"],
      languageVersion: parseMap["languageVersion"],
    );
  }

  @override
  String toString() {
    return 'PackageConfig{name: $name, rootUri: $rootUri, packageUri: $packageUri, languageVersion: $languageVersion}';
  }
}

class RouterxOptions {
  /**
   *  path  routerConfig  path
   */
  String? routerConfigPath;

  String? input;

  String? packageConfig;

  /**
   * android
   */
  String? androidPluginClassPath;

  String? iosPluginClassPath;

  //插件名称
  String? pluginName;

  @override
  String toString() {
    return 'RouterxOptions{routerConfigPath: $routerConfigPath, input: $input}';
  }
}
