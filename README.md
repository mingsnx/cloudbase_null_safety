# cloudbase_null_safety

Flutter plugin for cloudbase core. Temporary alternative to the official null-safety version, all APIs are consistent with the official.

## 官方 Pub Package

cloudbase_core:[![Pub](https://img.shields.io/pub/v/cloudbase_core)]()

cloudbase_auth:[![Pub](https://img.shields.io/pub/v/cloudbase_auth)]()

cloudbase_storage:[![Pub](https://img.shields.io/pub/v/cloudbase_storage)]()

cloudbase_function:[![Pub](https://img.shields.io/pub/v/cloudbase_function)]()

## 描述 & Description

<!-- [![Pub](https://img.shields.io/pub/v/cloudbase_core)]() -->

[腾讯云·云开发](https://www.cloudbase.net/)的 Flutter 插件，更多的云开发 Flutter 插件请见[云开发文档](https://docs.cloudbase.net/api-reference/flutter/install.html)。

此版本为官方空安全版本的临时替代包，用于升级空安全使用，所有官方API不变，直接替换使用.

[(官方)非空安全版本](https://pub.dev/packages/cloudbase_core/versions/0.0.11)

已迁移的包：

✔️ cloudbase_core

✔️ cloudbase_storage

✔️ cloudbase_auth

✔️ cloudbase_function

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
