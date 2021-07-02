/// orgin pub package: https://pub.dev/packages/cloudbase_storage
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_core/base.dart';
import 'package:cloudbase_null_safety/cloudbase_core/exception.dart';
import 'package:cloudbase_null_safety/cloudbase_core/request.dart';

import './response.dart';

/// 腾讯云对象存储
class CloudBaseStorage {
  late CloudBaseRequest _request;

  /// 腾讯云对象存储
  CloudBaseStorage(CloudBaseCore core) {
    _request = CloudBaseRequest(core);
  }

  /// 上传文件
  uploadFile(
      {required String cloudPath,
      required String filePath,
      void onProcess(int count, int total)?}) async {
    _checkParams(cloudPath, 'cloudPath is required');
    _checkParams(filePath, 'filePath is required');

    CloudBaseStorageRes<UploadMetadata> metadataRes =
        await getUploadMetadata(cloudPath);
    UploadMetadata metadata = metadataRes.data;

    Map<String, String> data = {
      'key': cloudPath,
      'signature': metadata.authorization,
      'x-cos-meta-fileid': metadata.cosFileId,
      'x-cos-security-token': metadata.token
    };

    // 上传文件，正常的情况响应为空
    await _request.postFileByFormData(
        url: metadata.url,
        metadata: data,
        filePath: filePath,
        onProcess: onProcess);

    CloudBaseStorageRes<UploadRes> res = CloudBaseStorageRes(
        requestId: metadataRes.requestId,
        data: UploadRes.fromMap({'fileId': metadata.fileId}));
    return res;
  }

  /// 下载文件
  Future<void> downloadFile(
      {required String fileId,
      required String savePath,
      void onProcess(int count, int total)?}) async {
    _checkParams("fileId", "fileId required");

    List<String> fileIds = [fileId];
    CloudBaseStorageRes<List<DownloadMetadata>> res =
        await getFileDownloadURL(fileIds);
    String? url = res.data[0].downloadUrl;
    if (url == null) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.FILE_NOT_EXIST,
          message: 'File Not Exist');
    }
    await _request.download(url, savePath, onProcess);
  }

  /// 删除文件
  deleteFiles(List<String> fileIdList) async {
    if (fileIdList.isEmpty) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.INVALID_PARAM,
          message: "fileIdList must not be empty");
    }

    fileIdList.forEach((fileId) {
      _checkParams(fileId, 'fileIdList must not have empty string');
    });

    Map<String, dynamic> data = {'fileid_list': fileIdList};
    CloudBaseResponse res =
        await _request.post('storage.batchDeleteFile', data);

    // 存在 code，返回值异常
    if (res.code != null) {
      throw new CloudBaseException(code: res.code, message: res.message);
    }

    // 格式化处理返回数据
    List<dynamic> dataList = res.data['delete_list'];
    List<DeleteMetadata> list = [];
    dataList.forEach((item) {
      DeleteMetadata metadata = DeleteMetadata.fromMap(item);
      list.add(metadata);
    });

    CloudBaseStorageRes<List<DeleteMetadata>> deleteRes =
        CloudBaseStorageRes(requestId: res.requestId!, data: list);
    return deleteRes;
  }

  /// 获取文件下载链接
  getFileDownloadURL(List<String> fileIdList) async {
    if (fileIdList.isEmpty) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.INVALID_PARAM,
          message: "fileIdList must not be empty");
    }

    List<Map<String, dynamic>> files = [];

    fileIdList.forEach((fileId) {
      files.add({'fileid': fileId, 'max_age': 1800});
    });

    Map<String, dynamic> data = {"file_list": files};

    CloudBaseResponse res =
        await _request.post("storage.batchGetDownloadUrl", data);

    // 存在 code，说明返回值存在异常
    if (res.code != null) {
      throw new CloudBaseException(code: res.code, message: res.message);
    }

    List<dynamic> dataList = res.data['download_list'];
    List<DownloadMetadata> list = [];
    dataList.forEach((item) {
      DownloadMetadata metadata = DownloadMetadata.fromMap(item);
      list.add(metadata);
    });

    CloudBaseStorageRes<List<DownloadMetadata>> getUrlRes =
        CloudBaseStorageRes(requestId: res.requestId!, data: list);
    return getUrlRes;
  }

  /// 获取上传文件自定义属性
  getUploadMetadata(String cloudPath) async {
    _checkParams(cloudPath, 'cloudPath is required');

    String action = 'storage.getUploadMetadata';

    CloudBaseResponse res = await _request.post(action, {'path': cloudPath});

    // 存在 code，说明返回值存在异常
    if (res.code != null) {
      throw new CloudBaseException(code: res.code, message: res.message);
    }

    UploadMetadata metadata = UploadMetadata.fromMap(res.data);
    CloudBaseStorageRes<UploadMetadata> storageRes =
        CloudBaseStorageRes(requestId: res.requestId!, data: metadata);

    return storageRes;
  }

  _checkParams(String? param, String msg) {
    if (param == null || param.isEmpty) {
      throw new CloudBaseException(
          code: CloudBaseExceptionCode.EMPTY_PARAM, message: msg);
    }
  }
}
