import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:routerx/routerx_lib.dart';

import 'ast/astVisitor.dart';
import 'ast/parsing_router.dart';

//
// 执行命令
// simple
// flutter pub run routerx --input ./lib/routerConfig/pages.dart
//
// xxxx/flutter_module/lib/routerConfig/pages.dart
Future<int> runCommandLine(List<String> args, {Uri? packageConfig}) async {
  print(' ===============> args ' + args.toString());
  RouterxOptions opts = Routerx.parseArgs(args);

  final Directory tempDir = Directory.systemTemp.createTempSync(
    'flutter_routerx.',
  );

  String importLine = '';
  if (opts.input != null) {
    final String relInputPath = _posixRelative(opts.input!, from: tempDir.path);
    importLine = 'import \'$relInputPath\';\n';
    print(' ===============> relInputPath ' + relInputPath);
  }

  /**
   * 以下操作有点牛皮
   */
  final String code = """
// @dart = 2.12
$importLine
import 'dart:io';
import 'dart:isolate';
import 'package:routerx/routerx_lib.dart';

void main(List<String> args, SendPort sendPort) async {
  sendPort.send(await Routerx.run(args));
}
""";

  final File tempFile = File(path.join(tempDir.path, '_routerx_temp_.dart'));
  await tempFile.writeAsString(code);
  final ReceivePort receivePort = ReceivePort();

  Isolate.spawnUri(
    // Using Uri.file instead of Uri.parse in order to parse backslashes as
    // path segment separator with Windows semantics.
    Uri.file(tempFile.path),
    args,
    receivePort.sendPort,
    packageConfig: packageConfig,
  );

  final Completer<int> completer = Completer<int>();
  receivePort.listen((dynamic message) {
    try {
      // ignore: avoid_as
      completer.complete(message as int);
    } catch (exception) {
      completer.completeError(exception);
    }
  });
  final int exitCode = await completer.future;
  tempDir.deleteSync(recursive: true);
  return exitCode;
}

/**
 * 解析 .dart_tool -> package_config.json
 *          -> flutter_plugin_2
 */
readPluginPath() {}

/**
 * 获取了全路径
 */
String _posixRelative(String input, {required String from}) {
  final path.Context context = path.Context(style: path.Style.posix);
  final String rawInputPath = input;
  print(" ===============> _posixRelative -> rawInputPath =  " + rawInputPath);
  final String absInputPath = File(rawInputPath).absolute.path;

  print(" ===============> _posixRelative -> absInputPath =  " + absInputPath);
  // By going through URI's we can make sure paths can go between drives in
  // Windows.
  final Uri inputUri = path.toUri(absInputPath);
  final String posixAbsInputPath = context.fromUri(inputUri);
  print(" ===============> _posixRelative -> posixAbsInputPath =  " +
      posixAbsInputPath);
  final Uri tempUri = path.toUri(from);
  final String posixTempPath = context.fromUri(tempUri);
  print(
      " ===============> _posixRelative -> posixTempPath =  " + posixTempPath);
  return context.relative(posixAbsInputPath, from: posixTempPath);
}


