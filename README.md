# flutter_plugin_ble_printer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## 汉印打印机 HM-A300
https://cn.hprt.com/XiaZai/


### 打印模板

注意以下2点：
1. 回车符，必须为 Windows 格式 CRLF (`\r\n`)，查看方式为AS 底部 正下方 utf-8 旁边的 LF 或 CR 或 CRLF
2. 最后一行指令后，加一个空行，防止打印模板后，接着打印图片，因为没有空行，造成无法打印图片（分开实现图片指令和模板的最后一条指令）


### 跨端访问文件

1. 在 iOS 中加载 Flutter 资源文件

https://flutter.cn/docs/development/ui/assets-and-images#loading-flutter-assets-in-ios

2. 在 Android 中加载 Flutter 资源文件

https://flutter.cn/docs/development/ui/assets-and-images#loading-flutter-assets-in-android


#### iOS 添加 第三方framework

`flutter_plugin_ble_printer.podspec`
```
#  第三方framework

  s.vendored_frameworks = 'MyFramework/**/*.xcframework'

  ```