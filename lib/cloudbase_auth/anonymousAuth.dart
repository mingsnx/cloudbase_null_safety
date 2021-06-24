/// orgin pub package: https://pub.dev/packages/cloudbase_auth
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';

import 'baseAuth.dart';
import 'interface.dart';

class AnonymousAuthProvider extends AuthProvider {
  AnonymousAuthProvider(CloudBaseCore core) : super(core);

  Future<CloudBaseAuthState> signInAnonymously() async {
    /// 如果本地存有uuid则匿名登录时传给server
    String uuid = await cache.getStore(cache.anonymousUuidKey);
    String refreshToken = await cache.getStore(cache.refreshTokenKey);
    final CloudBaseAuthType? loginType =
        await cache.getStore(cache.loginTypeKey);
    final CloudBaseResponse? res = await CloudBaseRequest(super.core)
        .postWithoutAuth('auth.signInAnonymously', {
      'anonymous_uuid': uuid,
      'refresh_token': refreshToken,
      'currLoginType': loginType?.index
    });

    if (res == null) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.NULL_RESPONES,
          message: "unknown error, res is null");
    }

    if (res.code != null) {
      throw new CloudBaseException(code: res.code, message: res.message);
    }

    if (res.data != null &&
        res.data['refresh_token'] != null &&
        res.data['uuid'] != null) {
      String newUuid = res.data['uuid'];
      String newRefreshToken = res.data['refresh_token'];
      await _setAnonymousUUID(newUuid);
      await setRefreshToken(newRefreshToken);
      await refreshAccessToken();

      return CloudBaseAuthState(
          authType: CloudBaseAuthType.ANONYMOUS, refreshToken: newRefreshToken);
    } else {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.AUTH_FAILED, message: '匿名登录失败');
    }
  }

  /// 匿名账号数据迁移到正式账号
  Future<CloudBaseAuthState> linkAndRetrieveDataWithTicket(
      String ticket) async {
    String uuid = await cache.getStore(cache.anonymousUuidKey);
    String refreshToken = await cache.getStore(cache.refreshTokenKey);
    final CloudBaseResponse? res = await CloudBaseRequest(super.core)
        .postWithoutAuth('auth.linkAndRetrieveDataWithTicket', {
      'anonymous_uuid': uuid,
      'refresh_token': refreshToken,
      'ticket': ticket
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
      /// 转正后清除本地保存的匿名uuid
      await _clearAnonymousUUID();
      String newRefreshToken = res.data['refresh_token'];
      await setRefreshToken(newRefreshToken);
      await refreshAccessToken();

      return CloudBaseAuthState(refreshToken: newRefreshToken);
    } else {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.AUTH_FAILED, message: '匿名转化失败');
    }
  }

  /// 设置匿名uuid
  Future<void> _setAnonymousUUID(String uuid) async {
    await cache.removeStore(cache.anonymousUuidKey);
    await cache.setStore(cache.anonymousUuidKey, uuid);
    await setAuthType(CloudBaseAuthType.ANONYMOUS);
  }

  /// 清空匿名uuid
  Future<void> _clearAnonymousUUID() async {
    await cache.removeStore(cache.anonymousUuidKey);
  }
}
