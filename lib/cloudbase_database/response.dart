/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:convert';

class DbQueryResponse {
  String? code;
  String? message;

  dynamic data;
  String? requestId;
  int? total;
  int? limit;
  int? offset;

  DbQueryResponse({
    this.code,
    this.message,
    this.data,
    this.requestId,
    this.total,
    this.limit,
    this.offset,
  });

  @override
  String toString() {
    var json = {
      'code': code,
      'message': message,
      'data': data,
      'requestId': requestId,
      'total': total,
      'limit': limit,
      'offset': offset,
    };

    return jsonEncode(json, toEncodable: (value) => value.toString());
  }
}

class DbUpdateResponse {
  String? code;
  String? message;

  String? requestId;
  String? updateId;
  dynamic updated;

  DbUpdateResponse({
    this.code,
    this.requestId,
    this.message,
    this.updateId,
    this.updated,
  });

  @override
  String toString() {
    var json = {
      'code': code,
      'message': message,
      'requestId': requestId,
      'updateId': updateId,
      'updated': updated
    };

    return jsonEncode(json);
  }
}

class DbRemoveResponse {
  String? code;
  String? message;

  String? requestId;
  dynamic deleted;

  DbRemoveResponse({
    this.code,
    this.message,
    this.requestId,
    this.deleted,
  });

  @override
  String toString() {
    var json = {
      'code': code,
      'message': message,
      'requestId': requestId,
      'deleted': deleted
    };

    return jsonEncode(json);
  }
}

class DbCreateResponse {
  String? code;
  String? message;

  String? requestId;
  String? id;

  DbCreateResponse({
    this.code,
    this.message,
    this.requestId,
    this.id,
  });

  @override
  String toString() {
    var json = {
      'code': code,
      'message': message,
      'requestId': requestId,
      'id': id
    };

    return jsonEncode(json);
  }
}
