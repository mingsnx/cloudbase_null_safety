/// orgin pub package: https://pub.dev/packages/cloudbase_auth
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';

import 'baseAuth.dart';
import 'interface.dart';

import 'package:flutter/services.dart';

class WxAuthProvider extends AuthProvider {
  static const MethodChannel _channel = const MethodChannel('cloudbase_auth');

  WxAuthProvider(CloudBaseCore core) : super(core);

  Future<CloudBaseAuthState> signInByWx(
      String? wxAppId, String? wxUniLink) async {
    if (wxAppId == null || wxUniLink == null) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.EMPTY_PARAM,
          message: "wxAppid or wxUniLink is null");
    }

    String code = await _getWxCode(wxAppId, wxUniLink);
    final CloudBaseResponse? res = await CloudBaseRequest(super.core)
        .postWithoutAuth('auth.getJwt', {
      'appid': wxAppId,
      'loginType': 'WECHAT-OPEN',
      'code': code,
      'syncUserInfo': true
    });

    if (res == null) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.NULL_RESPONES,
          message: "unknown error, res is null");
    }

    if (res.code != null) {
      throw new CloudBaseException(code: res.code, message: res.message);
    }

    if (res.data != null && res.data['refresh_token'] != null) {
      String refreshToken = res.data['refresh_token'];
      await setRefreshToken(refreshToken);
      await setAuthType(CloudBaseAuthType.WX);

      if (res.data['access_token'] != null &&
          res.data['access_token_expire'] != null) {
        await cache.setStore(cache.accessTokenKey, res.data['access_token']);
        await cache.setStore(
            cache.accessTokenExpireKey,
            res.data["access_token_expire"] +
                DateTime.now().millisecondsSinceEpoch);
      } else {
        await refreshAccessToken();
      }

      return CloudBaseAuthState(
          authType: CloudBaseAuthType.WX, refreshToken: refreshToken);
    } else {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.AUTH_FAILED, message: '微信登录失败');
    }
  }

  Future<String> _getWxCode(String wxAppId, String wxUniLink) async {
    // 1.wx app register
    var params = {'wxAppId': wxAppId, 'wxUniLink': wxUniLink};
    await _channel.invokeMethod('wxauth.register', params).catchError((e) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.AUTH_FAILED, message: e.toString());
    });

    // 2.wx app login
    final String code =
        await _channel.invokeMethod('wxauth.login').catchError((e) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.AUTH_FAILED, message: e.message);
    });

    return code;
  }
}
