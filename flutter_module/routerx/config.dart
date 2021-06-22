//输出配置
import 'package:routerx/routerx_lib.dart';

void configureRouter(RouterxOptions options) {
  print(" ===============> configureRouter  进入");
  options.routerConfigPath = './lib/routerConfig/pages.dart';
  options.packageConfig = '.dart_tool/package_config.json';

  //router plugin  各个native 插件路径
  options.androidPluginClassPath =
      "android/src/main/kotlin/com/tlp/integrated_routing/RouterConfig.kt";
  options.iosPluginClassPath = "ios/Classes/RouterConfig.swift";

  //插件名称
  options.pluginName = "integrated_routing";


}
