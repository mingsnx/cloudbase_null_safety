/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_core/exception.dart';

///todo
class Validater {
  static bool isDocId(docId) {
    if (docId is String || docId is num) {
      return true;
    } else {
      throw CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: 'Only for these two types(String | num)',
      );
    }
  }

  static bool isFieldPath(String path) {
    return true;
  }

  static bool isFieldOrder(String direction) {
    return true;
  }

  static bool isGeopoint(String type, num degree) {
    if (type == 'latitude' && degree.abs() > 90) {
      throw CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: 'latitude should be a number ranges from -90 to 90',
      );
    } else if (type == 'longitude' && degree.abs() > 180) {
      throw CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: 'longitude should be a number ranges from -180 to 180',
      );
    }

    return true;
  }

  static bool isUpdateDocumentData(dynamic) {
    return true;
  }
}
