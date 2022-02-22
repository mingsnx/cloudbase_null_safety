import 'dart:convert';

import 'package:cloudbase_null_safety/cloudbase_core/base.dart';
import 'package:cloudbase_null_safety/cloudbase_core/exception.dart';
import 'package:cloudbase_null_safety/cloudbase_core/request.dart';
import 'package:cloudbase_null_safety/cloudbase_database/command/update.dart';

/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_database/realtime/listener.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/snapshot.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/websocket_client.dart';
import 'package:cloudbase_null_safety/cloudbase_database/response.dart';
import 'package:cloudbase_null_safety/cloudbase_database/serializer.dart';

class Document {
  /// 上下文
  late CloudBaseCore _core;

  /// 文档 ID
  dynamic _id;

  /// Collection Name
  late String _coll;

  /// 指定显示或者不显示哪些字段
  Map<String, dynamic>? _projection;

  /// 请求句柄
  late CloudBaseRequest _request;

  Document({
    required CloudBaseCore core,
    required String coll,
    required dynamic docId,
    Map<String, dynamic>? projection,
  }) {
    _core = core;
    _coll = coll;
    _id = docId;
    _projection = projection;
    _request = CloudBaseRequest(_core);
  }

  Future<CloudBaseResponse> _docRequest(
      String action, Map<String, dynamic> params) {
    params.addAll({
      'collectionName': this._coll,
      'queryType': 'DOC',
      'databaseMidTran': true
    });

    return _request.post(action, params);
  }

  bool _checkOperatorMixed(dynamic data) {
    bool hasOperator = false;

    if (data is Map) {
      data.forEach((key, value) {
        if (value is UpdateCommand) {
          hasOperator = true;
        } else if (value is Map && _checkOperatorMixed(data)) {
          hasOperator = true;
        }
      });
    }

    return hasOperator;
  }

  /// 创建文档
  Future<DbCreateResponse> create(dynamic data) async {
    data = Serializer.encode(data);

    Map<String, dynamic> params = {
      'data': data,
    };

    if (this._id != null) {
      params['_id'] = this._id;
    }

    CloudBaseResponse res = await _docRequest('database.addDocument', params);
    if (res.code != null) {
      return DbCreateResponse(
        code: res.code,
        message: res.message,
        requestId: res.requestId,
      );
    }

    return DbCreateResponse(requestId: res.requestId, id: res.data['_id']);
  }

  /// 创建或添加数据
  Future<DbUpdateResponse> set(dynamic data) async {
    if (_id == null) {
      return DbUpdateResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: 'docId不能为空',
      );
    }

    if (data == null) {
      return DbUpdateResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '参数必需是非空对象',
      );
    }

    if (data['_id'] != null) {
      return DbUpdateResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '不能更新_id的值',
      );
    }

    var hasOperator = _checkOperatorMixed(data);
    if (hasOperator) {
      return DbUpdateResponse(
        code: CloudBaseExceptionCode.DATABASE_REQUEST_FAILED,
        message: 'update operator complicit',
      );
    }

    data = Serializer.encode(data);

    Map<String, dynamic> query = {'_id': this._id};
    Map<String, dynamic> params = {
      'query': query,
      'data': data,
      'multi': false,
      'merge': false,
      'upsert': true,
      'interfaceCallSource': 'SINGLE_SET_DOC',
    };

    CloudBaseResponse res = await _docRequest(
      'database.updateDocument',
      params,
    );
    if (res.code != null) {
      return DbUpdateResponse(
        code: res.code,
        message: res.message,
        requestId: res.requestId,
      );
    }

    return DbUpdateResponse(
      requestId: res.requestId,
      updateId: res.data['upserted_id'],
      updated: res.data['updated'],
    );
  }

  /// 更新数据
  Future<DbUpdateResponse> update(dynamic data) async {
    if (_id == null) {
      return DbUpdateResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: 'docId不能为空',
      );
    }

    if (data == null) {
      return DbUpdateResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '参数必需是非空对象',
      );
    }

    if (data['_id'] != null) {
      return DbUpdateResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '不能更新_id的值',
      );
    }

    data = Serializer.encode(data);

    Map<String, dynamic> query = {'_id': this._id};
    Map<String, dynamic> params = {
      'query': query,
      'data': data,
      'multi': false,
      'merge': true,
      'upsert': false,
      'interfaceCallSource': 'SINGLE_UPDATE_DOC',
    };

    CloudBaseResponse res = await _docRequest(
      'database.updateDocument',
      params,
    );
    if (res.code != null) {
      return DbUpdateResponse(
        code: res.code,
        message: res.message,
        requestId: res.requestId,
      );
    }

    return DbUpdateResponse(
      requestId: res.requestId,
      updateId: res.data['upserted_id'],
      updated: res.data['updated'],
    );
  }

  Future<DbRemoveResponse> remove() async {
    if (_id == null) {
      return DbRemoveResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: 'docId不能为空',
      );
    }

    Map<String, dynamic> query = {'_id': this._id};
    Map<String, dynamic> params = {'query': query, 'multi': false};

    CloudBaseResponse res = await _docRequest(
      'database.deleteDocument',
      params,
    );
    if (res.code != null) {
      return DbRemoveResponse(
        code: res.code,
        message: res.message,
        requestId: res.requestId,
      );
    }

    return DbRemoveResponse(
      requestId: res.requestId,
      deleted: res.data['deleted'],
    );
  }

  Future<DbQueryResponse> get() async {
    if (_id == null) {
      return DbQueryResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: 'docId不能为空',
      );
    }

    Map<String, dynamic> query = {'_id': this._id};
    Map<String, dynamic> params = {
      'query': query,
      'multi': false,
      'projection': _projection,
    };

    CloudBaseResponse res = await _docRequest('database.queryDocument', params);
    if (res.code != null) {
      return DbQueryResponse(
        code: res.code,
        message: res.message,
        requestId: res.requestId,
      );
    }

    return DbQueryResponse(
      requestId: res.requestId,
      data: Serializer.decode(res.data['list']),
      limit: res.data['limit'],
      offset: res.data['offset'],
    );
  }

  Document field(Map<String, bool> projection) {
    Map<String, int> newProjection = {};
    projection.forEach((key, value) {
      newProjection[key] = value ? 1 : 0;
    });

    return Document(
      core: _core,
      coll: _coll,
      docId: _id,
      projection: newProjection,
    );
  }

  RealtimeListener watch({
    required void onChange(Snapshot snapshot),
    required void onError(error),
  }) {
    return RealtimeWebSocketClient.getInstance(this._core).watch(
      envId: this._core.config.envId,
      collectionName: this._coll,
      query: jsonEncode({'_id': this._id}),
      onChange: onChange,
      onError: onError,
    );
  }
}
