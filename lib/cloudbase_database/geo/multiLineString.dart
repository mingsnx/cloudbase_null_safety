/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_core/exception.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/lineString.dart';

class MultiLineString {
  List<LineString> lines;

  MultiLineString(this.lines) {
    if (lines.length == 0) {
      throw new CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: 'MultiLineString must contain 1 linestring at least',
      );
    }
  }

  Map toJson() {
    var lineArr = [];
    lines.forEach((line) {
      lineArr.add(line.toJson()['coordinates']);
    });

    return {'type': 'MultiLineString', 'coordinates': lineArr};
  }

  static bool validate(data) {
    if (data['type'] != 'MultiLineString' || !(data['coordinates'] is List)) {
      return false;
    }

    List multiLine = data['coordinates'];
    for (var i = 0; i < multiLine.length; i++) {
      if (!(multiLine[i] is List)) {
        return false;
      }
      List line = multiLine[i];

      for (var j = 0; j < line.length; j++) {
        var point = line[j];
        if (!(point[0] is num && point[1] is num)) {
          return false;
        }
      }
    }

    return true;
  }

  static MultiLineString fromJson(coordinates) {
    List<LineString> lines = [];
    coordinates.forEach((line) {
      lines.add(LineString.fromJson(line));
    });

    return MultiLineString(lines);
  }
}
