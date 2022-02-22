<p align="center">
  <a href="https://flutter.dev/">
    <img src="https://www.vectorlogo.zone/logos/flutterio/flutterio-ar21.svg" alt="flutter" style="vertical-align:top; margin:4px;">
  </a>
  <a href="https://dart.dev/">
    <img src="https://www.vectorlogo.zone/logos/dartlang/dartlang-ar21.svg" alt="dart" style="vertical-align:top; margin:4px;">
  </a>
</p>
<br/>

# cloudbase_null_safety | 腾讯云 Flutter CloudBase

> Latest Version
> 
> [![Pub](https://shields.io/badge/pub-v1.1.2-ff69b4)](https://pub.flutter-io.cn/packages/cloudbase_null_safety)
> 
Flutter plugin for cloudbase core. Temporary alternative to the official null-safety version, all APIs are consistent with the official.

```diff
+ 1.1.0 version resolve the native platform [wxAuth] exception
+ 1.1.1 version resolve [!] No podspec found for cloudbase_null_safety in .symlinks/plugins/cloudbase_null_safety/ios
```

## 官方 Pub Package
|PackageName|Pub Url|
| :------------ |:---------------:|
| cloudbase_core | [![Pub](https://img.shields.io/pub/v/cloudbase_core)]() |
| cloudbase_auth | [![Pub](https://img.shields.io/pub/v/cloudbase_auth)]() |
| cloudbase_storage | [![Pub](https://img.shields.io/pub/v/cloudbase_storage)]() |
| cloudbase_function | [![Pub](https://img.shields.io/pub/v/cloudbase_function)]() |
| cloudbase_database | [![Pub](https://img.shields.io/pub/v/cloudbase_database)]() |

## 描述 & Description

<!-- [![Pub](https://img.shields.io/pub/v/cloudbase_core)]() -->

[腾讯云·云开发](https://www.cloudbase.net/)的 Flutter 插件，更多的云开发 Flutter 插件请见[云开发文档](https://docs.cloudbase.net/api-reference/flutter/install.html)。

此版本为官方空安全版本的临时替代包，用于升级空安全使用，所有官方API不变，直接替换使用.

[(官方)非空安全版本](https://pub.dev/packages/cloudbase_core/)

已迁移的包：
- [x] cloudbase_core
- [x] cloudbase_storage
- [x] cloudbase_auth
- [x] cloudbase_function
- [x] cloudbase_database

## 安装

在 flutter 项目的 `pubspec.yaml` 文件的 `dependencies` 中添加

```yaml
dependencies:
  cloudbase_null_safety: Latest
```

## 简单示例

```dart
import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';

// 初始化 CloudBase
CloudBaseCore core = CloudBaseCore.init({
    // 填写你的云开发 env
    'env': 'your-env-id'
});
```

## 详细文档

[云开发·初始化](https://docs.cloudbase.net/api-reference/flutter/initialization.html)
