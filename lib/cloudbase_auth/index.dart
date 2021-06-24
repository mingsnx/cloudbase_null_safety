/// orgin pub package: https://pub.dev/packages/cloudbase_core
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:async';
import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';

import 'baseAuth.dart';
import 'wxAuth.dart';
import 'anonymousAuth.dart';
import 'customAuth.dart';
import 'interface.dart';

import 'package:cloudbase_null_safety/cloudbase_core/auth.dart';

class CloudBaseAuth extends AuthProvider {
  WxAuthProvider? _wxAuthProvider;
  CustomAuthProvider? _customAuthProvider;
  AnonymousAuthProvider? _anonymousAuthProvider;

  CloudBaseAuth._internal(CloudBaseCore core) : super(core) {
    super.core.setAuthInstance(this);
  }

  /// 缓存 auth 实例
  static final Map<String, CloudBaseAuth> _cache = <String, CloudBaseAuth>{};

  factory CloudBaseAuth(CloudBaseCore core) {
    assert(core.config.env != null);
    String envId = core.config.env!;

    return _cache.putIfAbsent(envId, () {
      return CloudBaseAuth._internal(core);
    });
  }

  /// 微信登录
  Future<CloudBaseAuthState> signInByWx(
      {required String wxAppId, required String wxUniLink}) async {
    if (_wxAuthProvider == null) {
      _wxAuthProvider = WxAuthProvider(super.core);
    }

    CloudBaseAuthState authState =
        await _wxAuthProvider!.signInByWx(wxAppId, wxUniLink);

    return authState;
  }

  /// 自定义登录
  Future<CloudBaseAuthState> signInWithTicket(String ticket) async {
    if (_customAuthProvider == null) {
      _customAuthProvider = CustomAuthProvider(super.core);
    }

    CloudBaseAuthState authState =
        await _customAuthProvider!.signInWithTicket(ticket);

    return authState;
  }

  /// 匿名登录
  Future<CloudBaseAuthState> signInAnonymously() async {
    if (_anonymousAuthProvider == null) {
      _anonymousAuthProvider = AnonymousAuthProvider(super.core);
    }

    CloudBaseAuthState authState =
        await _anonymousAuthProvider!.signInAnonymously();

    return authState;
  }

  /// 登出
  Future<void> signOut() async {
    final state = await this.getAuthState();

    if (state == null) {
      /// 本地没有合法的登录态, 不需要执行登出操作
      return;
    }

    if (state.authType == CloudBaseAuthType.ANONYMOUS) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.SIGN_OUT_FAILED, message: '匿名用户不支持登出操作');
    }

    final CloudBaseResponse? res = await CloudBaseRequest(super.core)
        .post('auth.logout', {'refresh_token': state.refreshToken});

    if (res == null) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.NULL_RESPONES,
          message: "unknown error, res is null");
    }

    if (res.code != null) {
      throw CloudBaseException(code: res.code, message: res.message);
    }

    await cache.removeAllStore();
  }

  /// 获取登录状态
  Future<CloudBaseAuthState?> getAuthState() async {
    String? refreshToken = await cache.getStore(cache.refreshTokenKey);
    int? refreshTokenExpire = await cache.getStore(cache.refreshTokenExpireKey);
    if (refreshToken != null &&
        refreshToken.isNotEmpty &&
        refreshTokenExpire != null &&
        refreshTokenExpire > DateTime.now().millisecondsSinceEpoch) {
      return CloudBaseAuthState(
          authType: await cache.getStore(cache.loginTypeKey),
          refreshToken: refreshToken,
          accessToken: await cache.getStore(cache.accessTokenKey));
    }

    return null;
  }

  /// 是否存在已经过期的登录态
  /// 在getAuthStateh获得null以后，可以通过这个接口进一步区分 "没有登录态" 和 "登录态已过期"
  Future<bool> hasExpiredAuthState() async {
    String? refreshToken = await cache.getStore(cache.refreshTokenKey);
    int? refreshTokenExpire = await cache.getStore(cache.refreshTokenExpireKey);

    if (refreshToken != null &&
        refreshToken.isNotEmpty &&
        refreshTokenExpire != null &&
        refreshTokenExpire < DateTime.now().millisecondsSinceEpoch) {
      return true;
    }

    return false;
  }

  /// 获取用户信息
  Future<CloudBaseUserInfo> getUserInfo() async {
    final CloudBaseResponse? res =
        await CloudBaseRequest(super.core).post('auth.getUserInfo', {});

    if (res == null) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.NULL_RESPONES,
          message: "unknown error, res is null");
    }

    if (res.code != null) {
      throw CloudBaseException(code: res.code, message: res.message);
    }

    return CloudBaseUserInfo(res.data);
  }
}
