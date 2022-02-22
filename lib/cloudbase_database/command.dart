/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_core/exception.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/lineString.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/multiLineString.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/multiPoint.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/multiPolygon.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/point.dart';
import 'package:cloudbase_null_safety/cloudbase_database/geo/polygon.dart';

import './command/logic.dart';
import './command/query.dart';
import './command/update.dart';

class Command {
  eq(val) {
    return _queryOP(QueryCommandsLiteral.EQ, val);
  }

  neq(val) {
    return _queryOP(QueryCommandsLiteral.NEQ, val);
  }

  lt(val) {
    return _queryOP(QueryCommandsLiteral.LT, val);
  }

  lte(val) {
    return _queryOP(QueryCommandsLiteral.LTE, val);
  }

  gt(val) {
    return _queryOP(QueryCommandsLiteral.GT, val);
  }

  gte(val) {
    return _queryOP(QueryCommandsLiteral.GTE, val);
  }

  into(val) {
    return _queryOP(QueryCommandsLiteral.IN, val);
  }

  nin(val) {
    return _queryOP(QueryCommandsLiteral.NIN, val);
  }

  all(val) {
    return _queryOP(QueryCommandsLiteral.ALL, val);
  }

  elemMatch(val) {
    return _queryOP(QueryCommandsLiteral.ELEM_MATCH, val);
  }

  exists(val) {
    return _queryOP(QueryCommandsLiteral.EXISTS, val);
  }

  size(val) {
    return _queryOP(QueryCommandsLiteral.SIZE, val);
  }

  mod(val) {
    return _queryOP(QueryCommandsLiteral.MOD, val);
  }

  geoNear(Point? geometry, {num? maxDistance, num? minDistance}) {
    if (geometry == null) {
      throw CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '"geometry" can not be null.',
      );
    }

    var params = {};
    params['geometry'] = geometry;

    if (maxDistance != null) {
      params['maxDistance'] = maxDistance;
    }
    if (minDistance != null) {
      params['minDistance'] = minDistance;
    }

    return this._queryOP(QueryCommandsLiteral.GEO_NEAR, params);
  }

  geoWithin(geometry) {
    if (!(geometry is MultiPolygon || geometry is Polygon)) {
      throw CloudBaseException(
        code: CloudBaseExceptionCode.INVALID_PARAM,
        message: '"geometry" must be of type Polygon or MultiPolygon.',
      );
    }

    return this._queryOP(QueryCommandsLiteral.GEO_WITHIN, {
      'geometry': geometry,
    });
  }

  geoIntersects(geometry) {
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

    return this._queryOP(QueryCommandsLiteral.GEO_INTERSECTS, {
      'geometry': geometry,
    });
  }

  and(expressions) {
    return _logicOP(LogicCommandLiteral.AND, expressions);
  }

  nor(expressions) {
    return _logicOP(LogicCommandLiteral.NOR, expressions);
  }

  or(expressions) {
    return _logicOP(LogicCommandLiteral.OR, expressions);
  }

  not(expressions) {
    return _logicOP(LogicCommandLiteral.NOT, expressions);
  }

  set(val) {
    return _updateOP(UpdateCommandsLiteral.SET, val);
  }

  remove() {
    return _updateOP(UpdateCommandsLiteral.REMOVE, []);
  }

  inc(val) {
    return _updateOP(UpdateCommandsLiteral.INC, val);
  }

  mul(val) {
    return _updateOP(UpdateCommandsLiteral.MUL, val);
  }

  push(args) {
    var values;
    if (args is Map) {
      values = {
        '\$each': args['each'],
        '\$position': args['position'],
        '\$sort': args['sort'],
        '\$slice': args['slice'],
      };
    } else {
      values = args;
    }

    return _updateOP(UpdateCommandsLiteral.PUSH, values);
  }

  pull(values) {
    return _updateOP(UpdateCommandsLiteral.PULL, values);
  }

  pullAll(values) {
    return _updateOP(UpdateCommandsLiteral.PULL_ALL, values);
  }

  pop() {
    return _updateOP(UpdateCommandsLiteral.POP, []);
  }

  shift() {
    return _updateOP(UpdateCommandsLiteral.SHIFT, []);
  }

  unshift(values) {
    values = (values is List) ? values : [values];
    return _updateOP(UpdateCommandsLiteral.UNSHIFT, values);
  }

  addToSet(values) {
    return _updateOP(UpdateCommandsLiteral.ADD_TO_SET, values);
  }

  rename(values) {
    return _updateOP(UpdateCommandsLiteral.RENAME, [values]);
  }

  bit(values) {
    return _updateOP(UpdateCommandsLiteral.BIT, [values]);
  }

  max(values) {
    return _updateOP(UpdateCommandsLiteral.MAX, [values]);
  }

  min(values) {
    return _updateOP(UpdateCommandsLiteral.MIN, [values]);
  }

  QueryCommand _queryOP(String cmd, dynamic val) {
    return QueryCommand([], ['\$$cmd', val]);
  }

  LogicCommand _logicOP(String cmd, dynamic expressions) {
    expressions = (expressions is List) ? expressions : [expressions];

    var args = [];
    args.add('\$$cmd');
    args.addAll(expressions);

    return LogicCommand([], args);
  }

  UpdateCommand _updateOP(String cmd, dynamic val) {
    return UpdateCommand([], ['\$$cmd', val]);
  }
}
