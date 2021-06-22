import 'dart:io';
import 'routerx_lib.dart';

/**
 * 生成对应的native 的 方法
 */
class NativeFile {
  //  ===============>  android  start  ===============>
  static Future<dynamic> createAndroidPluginClass(RouterxOptions options,
      String pluginRootPath, Map<String, String> map) async {
    String classFile = pluginRootPath + options.androidPluginClassPath!;
    print(" ===============>  createAndroidPluginClass 全路径 classFile = " +
        classFile);
    File file = File(classFile);
    bool isExists = await file.exists();
    print(" ===============>  createAndroidPluginClass 文件是否存在  isExists = " +
        isExists.toString());

    List<String> preInsertAttribute = constructionAttributes(map);
    int count = 0;
    if (isExists) {
      List<String> contents = await file.readAsLines();
      print(" ===============> 读取存在文件 内容  \n \n start  preInsertAttribute = " +
          preInsertAttribute.toString() +
          "\n   contents " +
          contents.toString() +
          "\n \n");

      preInsertAttribute.forEach((preStr) {
        contents.forEach((fileStr) {
          if (fileStr.contains("public") && preStr.trim() == fileStr.trim()) {
            count++;
            print(" ===============>  fileStr = " + fileStr);
          }
        });
      });
      print(" ===============> contents   =" + contents.toString());
      if (count == preInsertAttribute.length) {
        print(" ===============> 文件 没有改动,不做任何操作");
        return Future.value();
      } else if (preInsertAttribute.length > count) {
        // 目前没有局部插入
        print(" ===============> 文件 需要改动,做添加操作");
        // file.writeAsString(contents)
      } else {
        print(" ===============>  全部更新操作");
      }
      print(" ===============> 读取存在文件 内容 end");
      await file.delete();
    }

    // 生成属性
    String attributes = transformKotlin(preInsertAttribute);
    return file.writeAsString("""
class  RouterConfig {       
      $attributes
    }
    """, flush: true);
  }

//属性
  static List<String> constructionAttributes(Map<String, String> values) {
    List<String> lineList = [];

    values.forEach((key, value) {
      lineList.add(getAttributesItem(key, value));
    });

    return lineList;
  }

  // transform -> kotlin 转换
  static String transformKotlin(List<String> items) {
    String content = "";
    items.forEach((element) {
      content = content + element + " \n";
    });
    print(" ===============>  " + content);
    return content;
  }

  // 格式
  static String getAttributesItem(String key, String value) {
    return "public var  $key = \"$value\"";
  }

  //  ===============>  android  end   ===============>

  //  ===============>  ios  ===============>

  static Future<File> createOCPluginClass(RouterxOptions options,
      String pluginRootPath, Map<String, String> map) async {
    String classFile = pluginRootPath + options.iosPluginClassPath!;
    print(
        " ===============>  createOCPluginClass 全路径 classFile = " + classFile);
    File file = File(classFile);
    bool isExists = await file.exists();
    print(" ===============>  createOCPluginClass 文件是否存在  isExists = " +
        isExists.toString());
    if (isExists) {
      await file.delete();
    }

    // 生成属性
    String attributes = constructionAttributesForIos(map);
    return file.writeAsString("""
    import Foundation  \n
    @objc class  RouterConfig: NSObject {
        $attributes
    }
    """, flush: true);
  }

  //属性
  static String constructionAttributesForIos(Map<String, String> values) {
    String content = "";

    values.forEach((key, value) {
      content = content + "@objc public static let  $key = \"$value \" \n";
    });

    print(" ===============>  " + content);
    return content;
  }

//  ===============>  ios  ===============>
}
