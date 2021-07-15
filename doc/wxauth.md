
# 微信登录

CloudBase 微信登录的步骤：申请和绑定微信 `Appid` ，添加 Android 和 iOS 的本地配置，在 Flutter 内调起微信登录。

下面以包名为 `com.tcloudbase.fluttersdk.demo` 的Flutter应用举例。

## 申请和绑定微信 Appid

[1] 请到 [微信开放平台](https://open.weixin.qq.com) 进行登记，登记并选择移动应用进行设置后，将该应用提交审核，审核通过后获得 `Appid`。

[2] 在 [云开发控制台](https://console.cloud.tencent.com/tcb) 绑定微信开放平台的 `Appid` ，并启动该登录方式。

<img src="./img/4.png" />

## 添加Android配置

[1] 在 `微信开放平台-管理中心-应用详情` 配置Android开发信息: 包名和应用签名。

<img src="./img/6.png" width="70%"/>

应用签名可以使用微信开放平台提供的 [签名生成工具](https://res.wx.qq.com/open/zh_CN/htmledition/res/dev/download/sdk/Gen_Signature_Android2.apk) 。

[2] 在你的包名相应目录下新建一个 `wxapi` 目录，并在该 `wxapi` 目录下新增一个 `WXEntryActivity` 类，该类继承自 `Activity` 。

<img src="./img/3.png" width="50%" />

[3] `WXEntryActivity` 类的代码如下:
```java
package com.tcloudbase.fluttersdk.demo.wxapi;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.Nullable;
public class WXEntryActivity extends Activity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
}
```

[4] 在 Android 项目的 `manifest` 文件里面加上：
```xml
<activity
    android:name=".wxapi.WXEntryActivity"
    android:theme="@android:style/Theme.Translucent.NoTitleBar"
    android:exported="true"
    android:taskAffinity="net.sourceforge.simcpux"
    android:launchMode="singleTask">
</activity>
```

## 添加iOS配置

[1] 配置应用的 `Universal Links`

[1.1] 根据[苹果文档](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)配置你应用的 `Universal Links` 。

(todo：添加更详细的描述)

[1.2] 打开 `Associated Domains` 开关，将Universal Links域名加到配置上。

<img src="./img/5.png"/>


[2] 在 `微信开放平台-管理中心-应用详情` 配置iOS开发信息: `Bundle ID` 和 `Universal Links` 。

<img src="./img/7.png" width="70%"/>

[3] 在 Xcode 中，选择你的工程设置项，选中 `TARGETS` 一栏，在 `Info` 标签栏的 `URL Types` 添加 `URL Schemes` 为你所注册的 `Appid` 。

<img src="./img/2.png"/>

[4] 在 Xcode 中，选择你的工程设置项，选中 `TARGETS` 一栏，在 `Info` 标签栏的 `LSApplicationQueriesSchemes` 添加 `weixin` 和 `weixinULAPI` 。

<img src="./img/1.png"/>

## Flutter调起微信登录
[1] 在 Flutter 项目的 `pubspec.yaml` 文件的 `dependencies` 中添加：

```yaml
dependencies:
  cloudbase_core: ^0.0.1
  cloudbase_null_safety: ^0.0.1
```

[2] 通过 dart 代码调起微信登录：
```dart
import 'package:cloudbase_core/cloudbase_core.dart';
import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';

CloudBaseCore core = CloudBaseCore.init({
    // 填写你的云开发envId和微信开放平台Appid
    'envId': 'xxx',  
    'wxAppId': 'xxxx'
});
// CloudBase微信登录
CloudBaseAuth auth = CloudBaseWxAuth(core);
bool isLogin = await auth.isLogin();
if (!isLogin) {
    await auth.login();
}

```