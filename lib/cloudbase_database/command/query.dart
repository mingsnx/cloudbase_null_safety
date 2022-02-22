/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_database/geo/lineString.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/multiLineString.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/multiPoint.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/multiPolygon.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/point.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/polygon.dart';
import 'package:cloudbase_null_safety/cloudbase_core/exception.dart';

import './logic.dart';

class QueryCommandsLiteral {
  static const AND = 'and';
  static const EQ = 'eq';
  static const NEQ = 'neq';
  static const GT = 'gt';
  static const GTE = 'gte';
  static const LT = 'lt';
  static const LTE = 'lte';
  static const IN = 'in';
  static const NIN = 'nin';
  static const ALL = 'all';
  static const ELEM_MATCH = 'elemMatch';
  static const EXISTS = 'exists';
  static const SIZE = 'size';
  static const MOD = 'mod';
  static const GEO_NEAR = 'geoNear';
  static const GEO_WITHIN = 'geoWithin';
  static const GEO_INTERSECTS = 'geoIntersects';
}

class QueryCommand extends LogicCommand {
  QueryCommand(actions, step) : super(actions, step);

  LogicCommand eq(val) {
    return this.queryOP(QueryCommandsLiteral.EQ, val);
  }

  LogicCommand neq(val) {
    return this.queryOP(QueryCommandsLiteral.NEQ, val);
  }

  LogicCommand gt(int val) {
    return this.queryOP(QueryCommandsLiteral.GT, val);
  }

  LogicCommand gte(int val) {
    return this.queryOP(QueryCommandsLiteral.GTE, val);
  }

  LogicCommand lt(int val) {
    return this.queryOP(QueryCommandsLiteral.LT, val);
  }

  LogicCommand lte(int val) {
    return this.queryOP(QueryCommandsLiteral.LTE, val);
  }

  LogicCommand into(List<dynamic> list) {
    return this.queryOP(QueryCommandsLiteral.IN, list);
  }

  LogicCommand nin(List<dynamic> list) {
    return this.queryOP(QueryCommandsLiteral.NIN, list);
  }

  LogicCommand geoNear({
    Point? geometry,
    required num maxDistance,
    required num minDistance,
  }) {
    if (geometry == null) {
      throw CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '"geometry" can not be null.',
      );
    }

    return this.queryOP(QueryCommandsLiteral.GEO_NEAR, {
      'geometry': geometry,
      'maxDistance': maxDistance,
      'minDistance': minDistance
    });
  }

  LogicCommand geoWithin(dynamic geometry) {
    if (!(geometry is MultiPolygon || geometry is Polygon)) {
      throw CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '"geometry" must be of type Polygon or MultiPolygon.',
      );
    }

    return this.queryOP(QueryCommandsLiteral.GEO_WITHIN, {
      'geometry': geometry,
    });
  }

  LogicCommand geoIntersects(dynamic geometry) {
    if (!(geometry is Point ||
        geometry is LineString ||
        geometry is Polygon ||
        geometry is MultiPoint ||
        geometry is MultiLineString ||
        geometry is MultiPolygon)) {
      throw CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message:
            '"geometry" must be of type Point, LineString, Polygon, MultiPoint, MultiLineString or MultiPolygon.',
      );
    }

    return this.queryOP(QueryCommandsLiteral.GEO_INTERSECTS, {
      'geometry': geometry,
    });
  }

  LogicCommand queryOP(String cmd, dynamic val) {
    var command = QueryCommand([], ['\$$cmd', val]);

    return this.and(command);
  }
}
