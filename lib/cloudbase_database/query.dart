/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:convert';
import 'dart:math';

import 'package:cloudbase_null_safety/cloudbase_database/realtime/listener.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/snapshot.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/websocket_client.dart';
import 'package:cloudbase_null_safety/cloudbase_database/response.dart';
import 'package:cloudbase_null_safety/cloudbase_database/validater.dart';
import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';
import './serializer.dart';

class QueryOrder {
  String field;
  String direction;

  QueryOrder({required this.field, required this.direction}) {
    assert(direction == 'asc' || direction == 'desc');
  }

  Map<String, dynamic> toJson() {
    return {'field': field, 'direction': direction};
  }
}

class QueryOption {
  /// 查询数量
  int? limit;

  /// 偏移量
  int? offset;

  /// 指定显示或者不显示哪些字段
  dynamic projection;

  QueryOption({this.limit, this.offset, this.projection});
}

class Query {
  /// 上下文
  late CloudBaseCore _core;

  /// Collection Name
  late String _coll;

  /// 过滤条件
  dynamic _fieldFilters;

  /// 排序条件
  List<QueryOrder>? _fieldOrders;

  /// 查询条件
  QueryOption? _queryOptions;

  /// 请求句柄
  late CloudBaseRequest _request;

  CloudBaseCore get core {
    return _core;
  }

  String get coll {
    return _coll;
  }

  Query({
    required CloudBaseCore core,
    required String coll,
    dynamic fieldFilters,
    List<QueryOrder>? fieldOrders,
    QueryOption? queryOptions,
  }) {
    _core = core;
    _coll = coll;
    _fieldFilters = fieldFilters;
    _fieldOrders = fieldOrders != null ? fieldOrders : [];
    _queryOptions = queryOptions != null ? queryOptions : QueryOption();
    _request = CloudBaseRequest(_core);
  }

  Future<CloudBaseResponse> _queryRequest(
      String action, Map<String, dynamic> params) {
    params.addAll({
      'collectionName': this._coll,
      'queryType': 'WHERE',
      'databaseMidTran': true
    });

    return _request.post(action, params);
  }

  Future<DbQueryResponse> get() async {
    Map<String, dynamic> params = {};

    if (this._fieldFilters != null) {
      params['query'] = this._fieldFilters;
    }

    if (this._fieldOrders!.length > 0) {
      params['order'] = List.from(this._fieldOrders!);
    }

    if (this._queryOptions!.limit != null) {
      params['limit'] = (this._queryOptions!.limit ?? 0) < 1000
          ? this._queryOptions!.limit
          : 1000;
    } else {
      this._queryOptions!.limit = 100;
    }

    if (this._queryOptions!.offset != null) {
      params['offset'] = this._queryOptions!.offset;
    }

    if (this._queryOptions!.projection != null) {
      params['projection'] = this._queryOptions!.projection;
    }

    CloudBaseResponse res = await _queryRequest(
      'database.queryDocument',
      params,
    );
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

  Future<DbQueryResponse> count() async {
    Map<String, dynamic> params = {'query': this._fieldFilters};

    CloudBaseResponse res =
        await _queryRequest('database.countDocument', params);
    if (res.code != null) {
      return DbQueryResponse(
        code: res.code,
        message: res.message,
        requestId: res.requestId,
      );
    }

    return DbQueryResponse(
      requestId: res.requestId,
      total: res.data['total'],
    );
  }

  Future<DbUpdateResponse> update(Map<String, dynamic>? data) async {
    if (data == null) {
      return DbUpdateResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '参数必需是非空对象',
      );
    }

    if (data.containsKey('_id')) {
      return DbUpdateResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '不能更新_id的值',
      );
    }

    Map<String, dynamic> params = {
      'query': this._fieldFilters,
      'muti': true,
      'merge': true,
      'upsert': false,
      'data': Serializer.encode(data),
      'interfaceCallSource': 'BATCH_UPDATE_DOC',
    };

    CloudBaseResponse res =
        await _queryRequest('database.updateDocument', params);
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
    if (_queryOptions!.offset != null ||
        _queryOptions!.limit != null ||
        _queryOptions!.projection != null) {
      return DbRemoveResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message:
            '`offset`, `limit` and `projection` are not supported in remove() operation',
      );
    }

    if (_fieldOrders!.length > 0) {
      return DbRemoveResponse(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '`orderBy` is not supported in remove() operation',
      );
    }

    Map<String, dynamic> params = {'query': this._fieldFilters, 'multi': true};

    CloudBaseResponse res = await _queryRequest(
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

  Query where(dynamic query) {
    query = Serializer.encode(query);

    return Query(
      core: _core,
      coll: _coll,
      fieldFilters: query,
      fieldOrders: _fieldOrders,
      queryOptions: _queryOptions,
    );
  }

  Query orderBy(String fieldPath, String directionStr) {
    Validater.isFieldPath(fieldPath);
    Validater.isFieldOrder(directionStr);

    var newOrder = QueryOrder(field: fieldPath, direction: directionStr);
    List<QueryOrder> newOrders = List.from(_fieldOrders!);
    newOrders.add(newOrder);

    return Query(
      core: _core,
      coll: _coll,
      fieldFilters: _fieldFilters,
      fieldOrders: newOrders,
      queryOptions: _queryOptions,
    );
  }

  Query limit(int limit) {
    var newOptions = QueryOption(
      limit: limit,
      offset: _queryOptions!.offset,
      projection: _queryOptions!.projection,
    );

    return Query(
      core: _core,
      coll: _coll,
      fieldFilters: _fieldFilters,
      fieldOrders: _fieldOrders,
      queryOptions: newOptions,
    );
  }

  Query skip(int offset) {
    var newOptions = QueryOption(
      limit: _queryOptions!.limit,
      offset: offset,
      projection: _queryOptions!.projection,
    );

    return Query(
      core: _core,
      coll: _coll,
      fieldFilters: _fieldFilters,
      fieldOrders: _fieldOrders,
      queryOptions: newOptions,
    );
  }

  Query field(Map<String, bool> projection) {
    Map<String, int> newProjection = {};
    projection.forEach((key, value) {
      newProjection[key] = value ? 1 : 0;
    });

    var newOptions = QueryOption(
      limit: _queryOptions!.limit,
      offset: _queryOptions!.offset,
      projection: newProjection,
    );

    return Query(
      core: _core,
      coll: _coll,
      fieldFilters: _fieldFilters,
      fieldOrders: _fieldOrders,
      queryOptions: newOptions,
    );
  }

  RealtimeListener watch({
    void onChange(Snapshot snapshot)?,
    void onError(error)?,
  }) {
    Map<String, String> orderBy = {};
    this._fieldOrders!.forEach((order) {
      orderBy[order.field] = order.direction;
    });

    return RealtimeWebSocketClient.getInstance(this._core).watch(
      envId: this._core.config.envId,
      collectionName: this._coll,
      query: jsonEncode(this._fieldFilters),
      limit: min(this._queryOptions!.limit ?? 0, 1000),
      orderBy: orderBy,
      onChange: onChange,
      onError: onError,
    );
  }
}
