/// orgin pub package: https://pub.dev/packages/cloudbase_storage
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:convert';

/// CloudBase Storage Response
class CloudBaseStorageRes<T> {
  /// requestId
  String requestId;

  /// data
  T data;

  /// CloudBaseStorageRes({...})
  CloudBaseStorageRes({required this.requestId, required this.data});

  @override
  String toString() {
    return jsonEncode({'requestId': this.requestId, 'data': data});
  }
}

/// upload response
class UploadRes {
  /// fileId
  late String fileId;

  /// UploadRes({...})
  UploadRes({required this.fileId});

  /// UploadRes.fromMap({...})
  UploadRes.fromMap(Map<String, dynamic> map) {
    this.fileId = map['fileId'];
  }
}

/// Upload Meta data
class UploadMetadata {
  /// url
  late String url;

  /// token
  late String token;

  /// authorization
  late String authorization;

  /// fileId
  late String fileId;

  /// cosFileId
  late String cosFileId;

  /// UploadMetadata({...})
  UploadMetadata(
      {required this.url,
      required this.token,
      required this.authorization,
      required this.fileId,
      required this.cosFileId});

  /// UploadMetadata.fromMap({...})
  UploadMetadata.fromMap(Map<String, dynamic> map) {
    this.url = map['url'];
    this.token = map['token'];
    this.authorization = map['authorization'];
    this.fileId = map['fileId'];
    this.cosFileId = map['cosFileId'];
  }

  @override
  String toString() {
    return jsonEncode({
      'url': url,
      'token': token,
      'authorization': authorization,
      'fileId': fileId,
      'cosFileId': cosFileId
    });
  }

  /// to json
  toJson() {
    return jsonEncode({
      'url': url,
      'token': token,
      'authorization': authorization,
      'fileId': fileId,
      'cosFileId': cosFileId
    });
  }
}

/// DownloadMetadata
class DownloadMetadata {
  /// fileId
  late String fileId;

  /// downloadUrl
  String? downloadUrl;

  /// DownloadMetadata.fromMap
  DownloadMetadata.fromMap(Map map) {
    fileId = map['fileid'];
    downloadUrl = map['download_url'];
  }

  @override
  String toString() {
    return jsonEncode({'fileId': fileId, 'downloadUrl': downloadUrl});
  }

  /// to json
  toJson() {
    return jsonEncode({'fileId': fileId, 'downloadUrl': downloadUrl});
  }
}

class DeleteMetadata {
  late String fileId;
  // code 为 'SUCCESS' 表示删除成功
  String? code;

  DeleteMetadata.fromMap(Map map) {
    fileId = map['fileid'];
    code = map['code'];
  }

  @override
  String toString() {
    return jsonEncode({'fileId': fileId, 'code': code});
  }

  toJson() {
    return jsonEncode({'fileId': fileId, 'code': code});
  }
}
