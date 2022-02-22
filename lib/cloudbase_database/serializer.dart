/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'command/logic.dart';
import 'command/update.dart';
import 'geo/lineString.dart';
import 'geo/multiLineString.dart';
import 'geo/multiPoint.dart';
import 'geo/multiPolygon.dart';
import 'geo/point.dart';
import 'geo/polygon.dart';

class Serializer {
  static dynamic encode(dynamic data) {
    if (data is LogicCommand) {
      return data.toJson();
    }

    if (data is UpdateCommand) {
      return data.toJson();
    }

    if (data is Map) {
      var map = {};

      data.forEach((key, value) {
        map[key] = encode(value);
      });

      return map;
    }

    if (data is List) {
      var list = [];

      data.forEach((value) {
        list.add(encode(value));
      });

      return list;
    }

    if (data is DateTime) {
      return {'\$date': data.microsecondsSinceEpoch};
    }

    return data;
  }

  static dynamic decode(dynamic data) {
    return _formatListField(data);
  }

  static dynamic _formatListField(List documents) {
    var docs = [];

    documents.forEach((item) {
      String type = _whichType(item);

      switch (type) {
        case 'Map':
          docs.add(_formatMapField(item));
          break;
        case 'List':
          docs.add(_formatListField(item));
          break;
        case 'GeoPoint':
        case 'GeoLineString':
        case 'GeoPolygon':
        case 'GeoMultiPoint':
        case 'GeoMultiLineString':
        case 'GeoMultiPolygon':
          docs.add(_formatGeoField(type, item));
          break;
        case 'ServerDate':
          docs.add(DateTime.fromMicrosecondsSinceEpoch(item['\$date'] * 1000));
          break;

        default:
          docs.add(item);
          break;
      }
    });

    return docs;
  }

  static dynamic _formatMapField(Map documents) {
    var docs = {};

    documents.forEach((key, value) {
      String type = _whichType(value);

      switch (type) {
        case 'Map':
          docs[key] = _formatMapField(value);
          break;
        case 'List':
          docs[key] = _formatListField(value);
          break;
        case 'GeoPoint':
        case 'GeoLineString':
        case 'GeoPolygon':
        case 'GeoMultiPoint':
        case 'GeoMultiLineString':
        case 'GeoMultiPolygon':
          docs[key] = _formatGeoField(type, value);
          break;
        case 'ServerDate':
          docs[key] =
              (DateTime.fromMicrosecondsSinceEpoch(value['\$date'] * 1000));
          break;
        default:
          docs[key] = value;
          break;
      }
    });

    return docs;
  }

  static dynamic _formatGeoField(type, document) {
    switch (type) {
      case 'GeoPoint':
        return Point.fromJson(document['coordinates']);
      case 'GeoLineString':
        return LineString.fromJson(document['coordinates']);
      case 'GeoPolygon':
        return Polygon.fromJson(document['coordinates']);
      case 'GeoMultiPoint':
        return MultiPoint.fromJson(document['coordinates']);
      case 'GeoMultiLineString':
        return MultiLineString.fromJson(document['coordinates']);
      case 'GeoMultiPolygon':
        return MultiPolygon.fromJson(document['coordinates']);
      default:
        return document;
    }
  }

  static String _whichType(data) {
    if (data == null) {
      return 'NULL';
    }

    if (data is String) {
      return 'String';
    }

    if (data is num) {
      return 'Number';
    }

    if (data is List) {
      return 'List';
    }

    if (data is Map) {
      if (data.containsKey('\$timestamp')) {
        return 'Timestamp';
      }

      if (data.containsKey('\$date')) {
        return 'ServerDate';
      }

      if (Point.validate(data)) {
        return 'GeoPoint';
      }

      if (LineString.validate(data)) {
        return 'GeoLineString';
      }

      if (Polygon.validate(data)) {
        return 'GeoPolygon';
      }

      if (MultiPoint.validate(data)) {
        return 'GeoMultiPoint';
      }

      if (MultiLineString.validate(data)) {
        return 'GeoMultiLineString';
      }

      if (MultiPolygon.validate(data)) {
        return 'GeoMultiPolygon';
      }

      return 'Map';
    }

    return data.runtimeType.toString();
  }
}
