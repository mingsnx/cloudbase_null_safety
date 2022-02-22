/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_database/geo/lineString.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/multiLineString.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/multiPoint.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/multiPolygon.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/point.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/polygon.dart';

class Geo {
  Point point(num longitude, num latitude) {
    return Point(longitude, latitude);
  }

  MultiPoint multiPoint(List<Point> points) {
    return new MultiPoint(points);
  }

  LineString lineString(List<Point> points) {
    return new LineString(points);
  }

  MultiLineString multiLineString(List<LineString> lines) {
    return new MultiLineString(lines);
  }

  Polygon polygon(List<LineString> lines) {
    return new Polygon(lines);
  }

  MultiPolygon multiPolygon(List<Polygon> polygons) {
    return new MultiPolygon(polygons);
  }
}
