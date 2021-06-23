/// orgin pub package: https://pub.dev/packages/cloudbase_core
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'base.dart';
import 'sign.dart';
import 'trace.dart';
import 'exception.dart';

import 'package:dio/dio.dart';

const int _TCB_DEFAULT_TIMEOUT = 15000;
const String _VERSION = '0.0.2';
const String _DATA_VERSION = '2020-06-01';
const String _TCB_WEB_URL = 'https://tcb-api.tencentcloudapi.com/web';

/// CloudBase Request
class CloudBaseRequest {
  late Dio _dio;
  CloudBaseCore _core;

  /// CloudBaseRequest 初始化
  CloudBaseRequest(this._core) {
    int? timeout = _core.config.timeout != null
        ? _core.config.timeout
        : _TCB_DEFAULT_TIMEOUT;

    _dio = Dio(BaseOptions(
        headers: {
          'Connection': 'Keep-Alive',
          'User-Agent': 'cloudbase-flutter-sdk/0.0.2',
          'X-SDK-Version': 'cloudbase-flutter-sdk/0.0.2'
        },
        contentType: 'application/json',
        responseType: ResponseType.json,
        queryParameters: {'env': _core.config.envId},
        sendTimeout: timeout));
  }

  /// 发送请求，携带 accessToken
  Future<CloudBaseResponse> post(
      String action, Map<String, dynamic> data) async {
    data.addAll({
      'action': action,
      'env': _core.config.envId,
      'sdk_version': _VERSION,
      'dataVersion': _DATA_VERSION,
    });

    if (_core.auth != null) {
      // 获取 accesstoken
      String accessToken = await _core.auth!.getAccessToken();
      data.addAll({'access_token': accessToken});
    }

    data = await Sign.signData(_core, data);
    final Response response = await _tracePost(_TCB_WEB_URL, data);

    if (response.data['code'] == 'ACCESS_TOKEN_EXPIRED') {
      await _core.auth!.refreshAccessToken();
      return await this.post(action, data);
    }

    // 从 HTTP 响应 data 中解析数据
    return CloudBaseResponse.fromMap(response.data);
  }

  /// 发送请求，不携带 accessToken，使用于登录
  Future<CloudBaseResponse> postWithoutAuth(
      String action, Map<String, dynamic> data) async {
    data.addAll({
      'action': action,
      'env': _core.config.envId,
      'sdk_version': _VERSION,
      'dataVersion': _DATA_VERSION
    });

    data = await Sign.signData(_core, data);
    final Response response = await _tracePost(_TCB_WEB_URL, data);
    return CloudBaseResponse.fromMap({
      'code': response.data['code'],
      'data': response.data,
      'message': response.data['message'],
      'requestId': response.data['requestId']
    });
  }

  Future<Response> _tracePost(String path, data) async {
    /// 添加 trace header
    await Trace(_core).addTrace(_dio);

    /// dio post
    final Response response = await _dio.post(path, data: data);

    /// 更新 trace header
    await Trace(_core).updateTrace(response);

    return response;
  }

  /// 使用 form 表单传递文件
  postFileByFormData(
      {required String url,
      required String? filePath,
      required Map<String, dynamic> metadata,
      void onProcess(int count, int total)?}) async {
    if (filePath == null) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.EMPTY_PARAM,
          message: 'filePath cloud not be empty');
    }

    print(filePath);

    Map<String, dynamic> data = {};
    data.addAll(metadata);
    data.addAll({"file": await MultipartFile.fromFile(filePath)});
    FormData formData = FormData.fromMap(data);
    await _dio.post(url, data: formData, onSendProgress: onProcess);
  }

  /// 下载
  download(String url, String savePath,
      void onProcess(int count, int total)?) async {
    await _dio.download(url, savePath, onReceiveProgress: onProcess);
  }
}
