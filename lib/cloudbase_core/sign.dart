import 'base.dart';

import 'dart:convert';

/// orgin pub package: https://pub.dev/packages/cloudbase_core
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:crypto/crypto.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 移动应用安全来源
class Sign {
  /// 数据签名
  static Future<Map<String, dynamic>> signData(
      CloudBaseCore core, Map<String, dynamic> data) async {
    final appAccess = core.config.appAccess;

    String? secret = appAccess['key'];
    String? version = appAccess['version'];

    if (secret != null && version != null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appSign = packageInfo.packageName;
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      var payload = {
        'data': data,
        'timestamp': timestamp,
        'appAccessKeyId': version,
        'appSign': appSign
      };
      var sign = _createSign(payload, secret);

      var newData = Map<String, dynamic>();
      newData.addAll(data);
      newData['timestamp'] = timestamp;
      newData['appAccessKeyId'] = version;
      newData['appSign'] = appSign;
      newData['sign'] = sign;

      return newData;
    }

    return data;
  }

  static String _createSign(dynamic payload, String secret) {
    var header = {"alg": "HS256", "typ": "JWT"};
    var headerStr = _base64(utf8.encode(json.encode(header)));
    var payloadStr = _base64(utf8.encode(json.encode(payload)));

    var key = utf8.encode(secret);
    var bytes = utf8.encode("$headerStr.$payloadStr");

    var hmac = Hmac(sha256, key);
    var digest = hmac.convert(bytes);
    var sign = _base64(digest.bytes);

    return "$headerStr.$payloadStr.$sign";
  }

  static String _base64(dynamic source) {
    var encodedSource = base64Url.encode(source);

    encodedSource = encodedSource.replaceAll(RegExp(r"[=]+$"), "");
    encodedSource = encodedSource.replaceAll("+", "-");
    encodedSource = encodedSource.replaceAll("/", "_");

    return encodedSource;
  }
}
