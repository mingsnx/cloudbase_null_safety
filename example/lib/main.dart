import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';
import 'package:cloudbase_null_safety/test_method_channel.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformTest = 'Unknown';
  String _log = "";
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformTest;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformTest =
          await TestMethodChannel.platformTest ?? 'Unknown platform test';
    } on PlatformException {
      platformTest = 'Failed to get platform test.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformTest = platformTest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () async{
                log("go");
                CloudBaseCore core = CloudBaseCore.init({
                  // 填写你的云开发envId和微信开放平台Appid
                  'env': 'xxx',  
                  'appAccess': {
                    'key': 'xxxxxx',
                    'test': 'x'
                  }
                });
                // CloudBase微信登录
                CloudBaseAuth auth = CloudBaseAuth(core);
                
                CloudBaseAuthState? state = await auth.getAuthState();
                if (state != null) {
                  log("ok");
                }
                else{
                  await auth.signInByWx(wxAppId: "wxXXXX", wxUniLink: "xxx").then((success) {
                      // 登录成功
                      log("登录成功");
                      auth.getUserInfo();
                  }).catchError((err) {
                      // 登录失败
                      log("登录失败 $err");
                  });
                }
              }, child: Text('Running on: $_platformTest\n')),
              Text(_log, style: Theme.of(context).textTheme.headline5,)
            ],
          ),
        ),
      ),
    );
  }

  void log(String val){
    setState(() {
      _log = val;
    });
  }
}
