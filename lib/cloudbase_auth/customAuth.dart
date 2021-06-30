/// orgin pub package: https://pub.dev/packages/cloudbase_auth
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';
import 'baseAuth.dart';
import 'interface.dart';

class CustomAuthProvider extends AuthProvider {
  CustomAuthProvider(CloudBaseCore core) : super(core);

  Future<CloudBaseAuthState> signInWithTicket(String ticket) async {
    if (ticket.isEmpty) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.EMPTY_PARAM,
          message: 'signIn ticket is null');
    }

    String refreshTokenKey = cache.refreshTokenKey;
    String? refreshToken = await cache.getStore(refreshTokenKey);
    final CloudBaseResponse? res = await CloudBaseRequest(super.core)
        .postWithoutAuth('auth.signInWithTicket',
            {'ticket': ticket, 'refresh_token': refreshToken});

    if (res == null) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.NULL_RESPONES,
          message: "unknown error, res is null");
    }

    if (res.code != null) {
      throw new CloudBaseException(code: res.code, message: res.message);
    }

    if (res.data != null && res.data['refresh_token'] != null) {
      String newRefreshToken = res.data['refresh_token'];
      await setAuthType(CloudBaseAuthType.CUSTOM);
      await setRefreshToken(newRefreshToken);
      await refreshAccessToken();

      return CloudBaseAuthState(
          authType: CloudBaseAuthType.CUSTOM, refreshToken: newRefreshToken);
    } else {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.AUTH_FAILED, message: '自定义登录失败');
    }
  }
}
