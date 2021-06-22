import 'dart:io' show exit;

import 'package:routerx/routerx_cl.dart';

// flutter pub run routerx
// https://dart.dev/tools/dart-run 参考
// 计划:
//    1 读取主项目  .dart_tool
///   2.获取指定的plugin 并获取 rootUri 并改造
/**
 *   怎么优化 编译速度
 *      1. ast 速度加快 / 优化代码
 *      2. await future 并行处理
 *      3. 文件对比 是否变化 然后生成  // 目前没有dart 指定插入部分 暂无法优化
 *      4. 再次写入数据为空  // fixed
 *      5. 弄清楚 buildAar 如果没有依赖过会不会 重新拉取
 *      6. 脚本如何挂载 pub get 某一环节
 */
Future<void> main(List<String> args) async {
  print("--x->  main 进入");
  exit(await runCommandLine(args));
}
