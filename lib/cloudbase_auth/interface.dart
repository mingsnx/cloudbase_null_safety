/// orgin pub package: https://pub.dev/packages/cloudbase_auth
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_core/auth.dart';

class CloudBaseAuthState {
  CloudBaseAuthType? authType;
  String? accessToken;
  String? refreshToken;

  CloudBaseAuthState({this.authType, this.accessToken, this.refreshToken});
}

class CloudBaseUserInfo {
  /// 用户在云开发的唯一ID
  late String uuid;

  /// 用户使用的云开发环境
  late String env;

  /// 用户登录类型
  late String loginType;

  /// 微信(开放平台或公众平台)应用appid
  String? appid;

  /// 当前用户在微信(开放平台或公众平台)应用的openid
  String? openid;

  /// 当前用户在微信(开放平台或公众平台)应用的unionid
  String? unionid;

  /// 用户昵称
  String? nickName;

  /// 用户性别，male(男)或female(女)
  String? gender;

  /// 用户所在国家
  String? country;

  /// 用户所在省份
  String? province;

  /// 用户所在城市
  String? city;

  /// 用户头像链接
  String? avatarUrl;

  CloudBaseUserInfo(map) {
    uuid = map['uid'];
    env = map['envName'];
    loginType = map['loginType'];
    appid = map['appid'];
    openid = map['openid'] ?? map['wxOpenId'];
    unionid = map['wxUnionId'];
    nickName = map['nickName'];
    gender = map['gender'];
    country = map['country'];
    province = map['province'];
    city = map['city'];
    avatarUrl = map['avatarUrl'];
  }

  @override
  String toString() {
    return '[云开发唯一ID: $uuid] [用户使用的云开发环境: $env] [用户登录类型: $loginType] [微信应用appid: $appid] [当前用户在微信应用的openid: $openid] [用户昵称: $nickName] [用户性别: $gender] [用户所在国家: $country] [用户所在省份: $province] [用户所在城市: $city] [用户头像链接: $avatarUrl]';
  }
}
