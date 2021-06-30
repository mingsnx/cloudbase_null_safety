/// orgin cloudbase_function pub package: https://pub.dev/packages/cloudbase_function
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:convert';

import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';

class CloudBaseFunction {
  final String _action = 'functions.invokeFunction';
  CloudBaseCore _core;

  CloudBaseFunction(this._core);

  Future<CloudBaseResponse> callFunction(String name,
      [Map<String, dynamic>? params]) async {
    if (name.isEmpty) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.EMPTY_PARAM,
          message: 'function name must not be empty');
    }

    Map<String, dynamic> callParams = {'function_name': name};

    if (params != null) {
      callParams['request_data'] = jsonEncode(params);
    }

    CloudBaseRequest cloudbaseRequest = CloudBaseRequest(_core);
    final CloudBaseResponse? res =
        await cloudbaseRequest.post(_action, callParams);

    if (res == null) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.NULL_RESPONES,
          message: "unknown error, res is null");
    }

    // 存在 code，说明返回值存在异常
    if (res.code != null) {
      throw new CloudBaseException(code: res.code, message: res.message);
    }

    // 尝试解析响应值
    String responseData = res.data['response_data'];

    try {
      dynamic data = jsonDecode(responseData);
      res.data = data;
      return res;
    } catch (e) {
      // 解析失败，返回原值
      return res;
    }
  }
}
