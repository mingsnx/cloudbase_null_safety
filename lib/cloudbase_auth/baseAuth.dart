/// orgin pub package: https://pub.dev/packages/cloudbase_core
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:async';
import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';
import 'cache.dart';

class AuthProvider implements ICloudBaseAuth {
  static Future<void>? _refreshAccessTokenFuture;

  late AuthCache _cache;
  CloudBaseCore _core;

  AuthProvider(this._core) {
    _cache = AuthCache.init(core.config);
  }

  AuthCache get cache {
    return _cache;
  }

  CloudBaseCore get core {
    return _core;
  }

  CloudBaseConfig get config {
    return _core.config;
  }

  Future<void> setRefreshToken(String refreshToken) async {
    /// refresh token设置前，先清掉 access token
    await cache.removeStore(cache.accessTokenKey);
    await cache.removeStore(cache.accessTokenExpireKey);
    await cache.setStore(cache.refreshTokenKey, refreshToken);

    /// refresh token 30天后过期
    await cache.setStore(cache.refreshTokenExpireKey,
        DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch);
  }

  @override
  Future<void> refreshAccessToken() async {
    /// 可能会同时调用多次刷新access token，这里把它们合并成一个
    if (AuthProvider._refreshAccessTokenFuture == null) {
      /// 没有正在刷新，那么正常执行刷新逻辑
      AuthProvider._refreshAccessTokenFuture = this._refreshAccessToken();
    }

    try {
      await AuthProvider._refreshAccessTokenFuture;
    } catch (e) {
      throw e;
    } finally {
      AuthProvider._refreshAccessTokenFuture = null;
    }
  }

  Future<void> _refreshAccessToken() async {
    await cache.removeStore(cache.accessTokenKey);
    await cache.removeStore(cache.accessTokenExpireKey);
    String? refreshToken = await cache.getStore(cache.refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.NOT_LOGIN, message: '未登录CLoudBase');
    }

    Map<String, dynamic> params = {'refresh_token': refreshToken};

    /// 匿名登录时传入uuid，若refresh token过期则可根据此uuid进行延期
    CloudBaseAuthType authType = await cache.getStore(cache.loginTypeKey);
    if (authType == CloudBaseAuthType.ANONYMOUS) {
      params['anonymous_uuid'] = await cache.getStore(cache.anonymousUuidKey);
    }
    final CloudBaseResponse? res = await CloudBaseRequest(this.core)
        .postWithoutAuth('auth.getJwt', params);

    if (res == null) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.NULL_RESPONES,
          message: "unknown error, res is null");
    }

    if (res.code != null) {
      throw new CloudBaseException(code: res.code, message: res.message);
    }

    if (res.data != null) {
      if (res.data['access_token'] != null) {
        await cache.setStore(cache.accessTokenKey, res.data['access_token']);

        /// 本地时间可能没有同步
        await cache.setStore(
            cache.accessTokenExpireKey,
            res.data["access_token_expire"] +
                DateTime.now().millisecondsSinceEpoch);
      }

      /// 匿名登录refresh_token过期情况下返回refresh_token
      /// 此场景下使用新的refresh_token获取access_token
      if (res.data['refresh_token'] != null) {
        await this.setRefreshToken(res.data['refresh_token']);
        await this._refreshAccessToken();
      }
    }
  }

  Future<void> setAuthType(CloudBaseAuthType authType) async {
    await cache.setStore(cache.loginTypeKey, authType);
  }

  @override
  Future<String> getAccessToken() async {
    /// 如果正在刷新token，则等待
    if (AuthProvider._refreshAccessTokenFuture != null) {
      await AuthProvider._refreshAccessTokenFuture;
    }

    final String? accessToken = await cache.getStore(cache.accessTokenKey);
    final int? accessTokenExpired =
        await cache.getStore(cache.accessTokenExpireKey);

    if (accessToken != null &&
        accessTokenExpired != null &&
        accessTokenExpired > DateTime.now().millisecondsSinceEpoch) {
      return accessToken;
    }

    /// 如果accessToken无效，则刷新
    await refreshAccessToken();

    return await cache.getStore(cache.accessTokenKey);
  }
}
