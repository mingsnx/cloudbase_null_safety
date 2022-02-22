/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_core/exception.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/point.dart';

class MultiPoint {
  List<Point> points;

  MultiPoint(this.points) {
    if (points.length <= 0) {
      throw CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: 'points must contain 1 point at least',
      );
    }
  }

  Map<String, dynamic> toJson() {
    var pointArr = [];
    points.forEach((point) {
      pointArr.add(point.toJson()['coordinates']);
    });

    return {'type': 'MultiPoint', 'coordinates': pointArr};
  }

  static bool validate(data) {
    if (data['type'] != 'MultiPoint' || !(data['coordinates'] is List)) {
      return false;
    }

    List multiPoint = data['coordinates'];
    for (var i = 0; i < multiPoint.length; i++) {
      var point = multiPoint[i];
      if (!(point[0] is num && point[1] is num)) {
        return false;
      }
    }

    return true;
  }

  static MultiPoint fromJson(coordinates) {
    List<Point> points = [];
    coordinates.forEach((point) {
      points.add(Point.fromJson(point));
    });

    return MultiPoint(points);
  }
}
