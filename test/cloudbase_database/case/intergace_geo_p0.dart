
import 'package:cloudbase_null_safety/cloudbase_database/geo.dart';

var geo = Geo();

var cases_data = {

  'name': 'interface_geo_p0集合',
  'skip': false,   //其中包含console用例，在本地跑先skip，否则注释掉或改为false
  'cases': [
    {
      'desc': 'collection_clean清理掉所有的集合数据。',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_clean',
        'collection_name': 'doc_wcc',
      },
    },

    {
      'desc': 'collection_count检查所有集合数据量',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': "collection_count",
        'collection_name': 'doc_wcc',
      },
      'eval': "response.total==0",
      'expect': (res) => res.total == 0
    },

    {
      'desc': '新增记录数据-支持空对象以及空数组',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'data': {
          'empty_object': {},
          'empty_array': [],
          '_id': "W_0Cuc6YbCHWYMcK00"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK00'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK00'
    },

    {
      'desc': '添加地理位置信息-point数据类型-验证参数是否支持正数',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_norm',
        'data': {
          'Point': geo.point(0, 0),
          'test02': geo.point(1, 90),
          'test03': geo.point(180, 1),
          '_id': "W_0Cuc6YbCHWYMcK01"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK01'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK01'
    },

    {
      'desc': '添加地理位置信息-point数据类型-验证参数是否支持负数',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_negative',
        'data': {
          'Point': geo.point(-180, -1),
          'test02': geo.point(-1, -90),
          '_id': "W_0Cuc6YbCHWYMcK02"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK02'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK02'
    },

    {
      'desc': '添加地理位置信息-point数据类型-验证参数是否支持浮点数',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_float',
        'data': {
          'test01': geo.point(-179.9, -89.9),
          'test02': geo.point(179.9, 89.9),
          'test03': geo.point(0.1, 0.1),
          'geo04': geo.point(-0.1, - 0.1),
          '_id': "W_0Cuc6YbCHWYMcK03"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK03'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK03'
    },

    {
      'desc': '添加地理位置信息-LineString数据类型传入多个point校验',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_LineString',
        'data': {
          'LineString': geo.lineString([
            geo.point(0, 0),
            geo.point(0, 10)
          ]),
          'test02': geo.lineString([
            geo.point(0, 0),
            geo.point(80, 80),
            geo.point(180, 80),
          ]),
          'geo03': geo.lineString([
            geo.point(0, 0),
            geo.point(80, 80),
            geo.point(10, 10),
            geo.point(20, 20),
          ]),
          '_id': "W_0Cuc6YbCHWYMcK04"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK04'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK04'
    },

//    {
//      'desc': '添加地理位置信息-LineString数据类型传入多个全部相同的point校验',
//      'run_count': 1,
//      'level': 0,
//      'request': {
//        'cmd': 'collection_add',
//        'collection_name': 'doc_wcc',
//        'name': 'geo_samePoint',
//        'data': {
//          'LineString': geo.lineString([
//            geo.point(0, 0),
//            geo.point(0, 0)
//          ])
//        },
//      },
//      'eval': "response.code == 'DATABASE_REQUEST_FAILED' ",
//      'expect': (res) => res.code == 'DATABASE_REQUEST_FAILED'
//    },

    {
      'desc': '添加地理位置信息-MultiPoint数据类型支持单个point校验',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_MultiPoint',
        'data': {
          'MultiPoint': geo.multiPoint([
            geo.point(0, 0)
          ]),
          '_id': "W_0Cuc6YbCHWYMcK05"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK05'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK05'
    },

    {
      'desc': '添加地理位置信息-MultiPoint数据类型支持多个point校验',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_MultiPoint2',
        'data': {
          'MultiPoint': geo.multiPoint([
            geo.point(0, 0),
            geo.point(0, 20),
          ]),
          '_id': "W_0Cuc6YbCHWYMcK06"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK06'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK06'
    },

    {
      'desc': '添加地理位置信息-MultiLineString数据类型支持单个LineString校验',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_MultiLineString',
        'data': {
          'MultiLineString': geo.multiLineString([
            geo.lineString([
              geo.point(0, 0),
              geo.point(0, 10)
            ]),
          ]),
          '_id': "W_0Cuc6YbCHWYMcK07"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK07'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK07'
    },

    {
      'desc': '添加地理位置信息-MultiLineString数据类型支持多个LineString校验',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_MultiLineString2',
        'data': {
          'MultiLineString': geo.multiLineString([
            geo.lineString([
              geo.point(0, 0),
              geo.point(0, 10)
            ]),
            geo.lineString([
              geo.point(0, 20),
              geo.point(0, 30)
            ])
          ]),
          '_id': "W_0Cuc6YbCHWYMcK08"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK08'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK08'
    },

    {
      'desc': '添加地理位置信息-Polygon数据类型传入一个闭环的LineString校验',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_Polygon',
        'data': {
          'Polygon': geo.polygon([
            geo.lineString([
              geo.point(0, 30),
              geo.point(60, 30),
              geo.point(60, 0),
              geo.point(0, 30),
            ])
          ]),
          '_id': "W_0Cuc6YbCHWYMcK09"     //插入一条数据，指定ID
        },
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK09'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK09'
    },

    {
      'desc': '添加地理位置信息-MultiPolygon数据类型传入一个Polygon',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_MultiPolygon',
        'data': {
          'MultiPolygon': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(0, 0),
                geo.point(0, -10),
                geo.point(-10, -10),
                geo.point(0, 0),
              ])
            ]),
          ]),
          '_id': "W_0Cuc6YbCHWYMcK14"     //插入一条数据，指定ID
        }
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK14'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK14'
    },

    {
      'desc': '添加地理位置信息-MultiPolygon数据类型传入多个Polygon',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_MultiPolygon2',
        'data': {
          'MultiPolygon': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(0, 0),
                geo.point(0, -10),
                geo.point(-10, -10),
                geo.point(0, 0),
              ])
            ]),
            geo.polygon([
              geo.lineString([
                geo.point(0, 0),
                geo.point(0, 10),
                geo.point(10, 10),
                geo.point(0, 0),
              ])
            ])
          ]),
          '_id': "W_0Cuc6YbCHWYMcK15"     //插入一条数据，指定ID
        }
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK15'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK15'
    },

    {
      'desc': '添加地理位置信息-一条记录包含所有GEO数据类型',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'name': 'geo_all',
        'data': {
          'test11': geo.point(0, 0),
          'test12': geo.lineString([
            geo.point(0, 0),
            geo.point(0, 10),
          ]),
          'test13': geo.polygon([
            geo.lineString([
              geo.point(0, 0),
              geo.point(10, 10),
              geo.point(10, 0),
              geo.point(0, 0),
            ])
          ]),
          'test14': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(0, 0),
                geo.point(0, -10),
                geo.point(-10, -10),
                geo.point(0, 0),
              ])
            ])
          ]),
          'test15': geo.multiLineString([
            geo.lineString([
              geo.point(0, 0),
              geo.point(0, 10)
            ])
          ]),
          'test16': geo.multiPoint([
            geo.point(0, 0),
            geo.point(0, 20),
          ]),
          '_id': "W_0Cuc6YbCHWYMcK11"     //插入一条数据，指定ID
        }
      },
      'eval': "response.id=='W_0Cuc6YbCHWYMcK11'",
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK11'
    },

//    {
//      'desc': 'geoNear校验-geometry传入非Point数据类型校验',
//      'run_count': 1,
//      'level': 0,
//      'request': {
//        'cmd': 'command_geoNear',
//        'name': 'geoNear_BadLineString',
//        'collection_name': 'doc_wcc',
//        'geoNear_key': "pointtest01",
//        'geoNear_value': {
//          'geometry': geo.lineString([geo.point(-50, 0), geo.point(50, 0)]),
//        },
//      },
//      'eval': "response.code=='DATABASE_REQUEST_FAILED'",
//      'expect': (res) => res.code == 'DATABASE_REQUEST_FAILED'
//    },

    {
      'desc': 'geoNear校验-搜索字段尚未添加索引，接口返回错误',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'name': 'geoNear_noIndex',
        'collection_name': 'doc_wcc',
        'geoNear_key': "Pointtest",
        'geoNear_value': {
          'geometry': geo.point(50, 0),
        },
      },
      'eval': "response.code=='DATABASE_REQUEST_FAILED'",
      'expect': (res) => res.code == 'DATABASE_REQUEST_FAILED'
    },

    {
      'desc': 'geoNear校验-geometry传入Point数据类型且不填距离参数校验',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'collection_name': 'doc_wcc',
        'geoNear_key': "Point",
        'geoNear_value': {
          'geometry': geo.point(50, 0),
        },
      },
      'eval': "response.data.length >= 0",
      'expect': (res) => res.data.length >= 0
    },

//    {
//      'desc': 'geoNear校验-传入距离参数为非数字类型',
//      'run_count': 1,
//      'level': 0,
//      'request': {
//        'cmd': 'command_geoNear',
//        'name': 'geoNear_strDistance',
//        'collection_name': 'doc_wcc',
//        'geoNear_key': "Point",
//        'geoNear_value': {
//          'geometry': geo.point(0, 0),
//          'maxDistance': "100",
//          'minDistance': "1000"
//        },
//      },
//      'eval': "response.code=='DATABASE_REQUEST_FAILED'",
//      'expect': (res) => res.code == 'DATABASE_REQUEST_FAILED'
//    },

    {
      'desc': 'geoNear校验-传入距离参数为负数',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'name': 'geoNear_negativeDistance',
        'collection_name': 'doc_wcc',
        'geoNear_key': "Point",
        'geoNear_value': {
          'geometry': geo.point(0, 0),
          'maxDistance': -12119,
          'minDistance': -10119
        },
      },
      'eval': "response.code=='DATABASE_REQUEST_FAILED'",
      'expect': (res) => res.code == 'DATABASE_REQUEST_FAILED'
    },

    {
      'desc': 'geoNear校验-传入距离参数为浮点数',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'name': 'geoNear_floatDistance',
        'collection_name': 'doc_wcc',
        'geoNear_key': "Point",
        'geoNear_value': {
          'geometry': geo.point(0, 0),
          'maxDistance': 12119.6,
          'minDistance': 10119.5
        },
      },
      'eval': "response.data.length >= 0",
      'expect': (res) => res.data.length >= 0
    },

    // 搜索字段为Point,包括两条记录
    // '"Point": geo.point(0, 0),ID':W_0Cuc6YbCHWYMcK01
    // '"Point": geo.point(-180, -1),ID':W_0Cuc6YbCHWYMcK02
    {
      'desc': 'geoNear校验-搜索出字段(GEO数据类型为Point)在距离范围内的记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'name': 'geoNear_Point',
        'collection_name': 'doc_wcc',
        'geoNear_key': "Point",
        'geoNear_value': {
          'geometry': geo.point(0, 0.1),
          'maxDistance': 12119,
          'minDistance': 0
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK01'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK01'
    },

    //搜索字段为'LineString,包括1条记录ID':W_0Cuc6YbCHWYMcK04
    //  'LineString': geo.lineString([
    //                    geo.point(0,0),
    //                    geo.point(0,10)
    //                ]),
    {
      'desc': 'geoNear校验-搜索出字段(GEO数据类型为LineString)在距离范围内的记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'name': 'geoNear_LineString',
        'collection_name': 'doc_wcc',
        'geoNear_key': "LineString",
        'geoNear_value': {
          'geometry': geo.point(0.1, 0),
          'maxDistance': 12119,
          'minDistance': 0
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK04'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK04'
    },

    //搜索MultiPoint字段，存在两条记录有MultiPoint字段
    //'"MultiPoint": geo.multiPoint([geo.point(0,0),geo.point(0,20)]), ID':W_0Cuc6YbCHWYMcK06
    //'"MultiPoint": geo.multiPoint([geo.point(0,0)]) ID':W_0Cuc6YbCHWYMcK05
    {
      'desc': 'geoNear校验-搜索出字段(GEO数据类型为MultiPoint)在距离范围内的记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'name': 'geoNear_MultiPoint',
        'collection_name': 'doc_wcc',
        'geoNear_key': "MultiPoint",
        'geoNear_value': {
          'geometry': geo.point(0, 20.1),
          'maxDistance': 12119,
          'minDistance': 0
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'
    },

    {
      'desc': 'geoNear校验-搜索出字段(GEO数据类型为MultiLineString)在距离范围内的记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'name': 'geoNear_MultiLineString',
        'collection_name': 'doc_wcc',
        'geoNear_key': "MultiLineString",
        'geoNear_value': {
          'geometry': geo.point(0.1, 25),
          'maxDistance': 12119,
          'minDistance': 0
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK08'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK08'
    },

    {
      'desc': 'geoNear校验-搜索出字段(GEO数据类型为Polygon)在距离范围内的记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'name': 'geoNear_Polygon',
        'collection_name': 'doc_wcc',
        'geoNear_key': "Polygon",
        'geoNear_value': {
          'geometry': geo.point(60.1, 15),
          'maxDistance': 12119,
          'minDistance': 0
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK09'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK09'
    },

    {
      'desc': 'geoNear校验-搜索出字段(GEO数据类型为MultiPolygon)在距离范围内的记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoNear',
        'name': 'geoNear_MultiPolygon',
        'collection_name': 'doc_wcc',
        'geoNear_key': 'MultiPolygon',
        'geoNear_value': {
          'geometry': geo.point(5, 10.1),
          'maxDistance': 12119,
          'minDistance': 0
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK15'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK15'
    },

    {
      'desc': 'geoWithin校验-搜索字段尚未添加索引，接口返回错误',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoWithin',
        'name': 'geoWithin_noIndex',
        'collection_name': 'doc_wcc',
        'geoWithin_key': "Pointtest",
        'geoWithin_value': {
          'geometry': geo.polygon([
            geo.lineString([
              geo.point(-180, 10),
              geo.point(0, 90),
            ]),
          ])

        },
      },
      'eval': "response.code=='DATABASE_REQUEST_FAILED'",
      'expect': (res) => res.code == 'DATABASE_REQUEST_FAILED'
    },

    {
      'desc': 'geoWithin校验-geometry为Polygon校验',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoWithin',
        'name': 'geoWithin_Point',
        'collection_name': 'doc_wcc',
        'geoWithin_key': "Point",
        'geoWithin_value': {
          'geometry': geo.polygon([
            geo.lineString([
              geo.point(-180, 10),
              geo.point(0, 90),
              geo.point(180, 0),
              geo.point(0, -90),
              geo.point(-180, 10),
            ]),
          ]),
        },
      },
      'eval': "response.data.length >= 0",
      'expect': (res) => res.data.length >= 0
    },

    {
      'desc': 'geoWithin校验-geometry为MultiPolygon校验',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoWithin',
        'name': 'geoWithin_MultiPolygon',
        'collection_name': 'doc_wcc',
        'geoWithin_key': "Point",
        'geoWithin_value': {
          'geometry': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(-180, 10),
                geo.point(0, 90),
                geo.point(180, 0),
                geo.point(0, -90),
                geo.point(-180, 10),
              ]),
            ]),
          ]),
        },
      },
      'eval': "response.data.length >= 0",
      'expect': (res) => res.data.length >= 0
    },

    //搜索MultiPoint字段，存在两条记录有MultiPoint字段
    //'"MultiPoint": geo.multiPoint([geo.point(0,0),geo.point(0,20)]), ID':W_0Cuc6YbCHWYMcK06
    //'"MultiPoint": geo.multiPoint([geo.point(0,0)]) ID':W_0Cuc6YbCHWYMcK05

    {
      'desc': 'geoWithin校验-geometry为MultiPolygon，待查询字段的GEO数据类型为MultiPoint',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoWithin',
        'name': 'geoWithin_MultiPolygon2',
        'collection_name': 'doc_wcc',
        'geoWithin_key': "MultiPoint",
        'geoWithin_value': {
          'geometry': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(-10, 10),
                geo.point(10, 10),
                geo.point(10, 0),
                geo.point(-10, 0),
                geo.point(-10, 10),
              ]),
            ]),
          ]),
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK05'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK05'
    },

    {
      'desc': 'geoWithin校验-geometry为MultiPolygon，待查询字段的GEO数据类型为MultiLineString',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoWithin',
        'name': 'geoWithin_MultiLineString',
        'collection_name': 'doc_wcc',
        'geoWithin_key': "MultiLineString",
        'geoWithin_value': {
          'geometry': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(-10, 15),
                geo.point(10, 15),
                geo.point(10, 0),
                geo.point(-10, 0),
                geo.point(-10, 15),
              ]),
            ]),
          ]),
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK07'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK07'
    },

    {
      'desc': 'geoWithin校验-geometry为MultiPolygon，待查询字段的GEO数据类型为MultiPolygon',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoWithin',
        'collection_name': 'doc_wcc',
        'geoWithin_key': 'MultiPolygon',
        'geoWithin_value': {
          'geometry': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(5, -15),
                geo.point(-30, -15),
                geo.point(-30, 10),
                geo.point(5, 10),
                geo.point(5, -15),
              ]),
            ]),
          ]),
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK14'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK14'
    },

    {
      'desc': 'geoIntersects校验-验证搜索字段尚未添加索引，也能正常搜索字段',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_noIndex',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': "test02",
        'geoIntersects_value': {
          'geometry': geo.multiPoint([
            geo.point(10, 10),
            geo.point(-1, -90)
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK02'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK02'
    },

    //搜索MultiPoint字段，存在两条记录有MultiPoint字段
    //'"MultiPoint": geo.multiPoint([geo.point(0,0),geo.point(0,20)]), ID':W_0Cuc6YbCHWYMcK06
    //'"MultiPoint": geo.multiPoint([geo.point(0,0)]) ID':W_0Cuc6YbCHWYMcK05
    {
      'desc': 'geoIntersects校验-geometry为MultiPoint ，待查询字段（GEO类型为MultiPoint）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_MultiPoint',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': "MultiPoint",
        'geoIntersects_value': {
          'geometry': geo.multiPoint([
            geo.point(10, 10),
            geo.point(0, 20)
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'
    },
    {
      'desc': 'geoIntersects校验-geometry为MultiLineString，待查询字段（GEO类型为MultiPoint）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_MultiPoint2',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': "MultiPoint",
        'geoIntersects_value': {
          'geometry': geo.multiLineString([
            geo.lineString([
              geo.point(0, 5),
              geo.point(0, 40)
            ]),
            geo.lineString([
              geo.point(-10, 30),
              geo.point(10, 30)
            ]),
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'
    },
    {
      'desc': 'geoIntersects校验-geometry为MultiPolygon，待查询字段（GEO类型为MultiPoint）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_MultiPolygon',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': "MultiPoint",
        'geoIntersects_value': {
          'geometry': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(10, 30),
                geo.point(30, 10),
                geo.point(10, 10),
                geo.point(-10, 10),
                geo.point(10, 30),
              ]),
            ])
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'
    },

    {
      'desc': 'geoIntersects校验-geometry为LineString，待查询字段（GEO类型为MultiPoint）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_LineString',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': "MultiPoint",
        'geoIntersects_value': {
          'geometry': geo.lineString([
            geo.point(0, 10),
            geo.point(0, 30),
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'
    },

    {
      'desc': 'geoIntersects校验-geometry为LineString，待查询字段（GEO类型为MultiPoint）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_Polygon',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': "MultiPoint",
        'geoIntersects_value': {
          'geometry': geo.polygon([
            geo.lineString([
              geo.point(-10, 10),
              geo.point(10, 10),
              geo.point(10, 30),
              geo.point(-10, 30),
              geo.point(-10, 10),
            ])
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK06'
    },

    {
      'desc': 'geoIntersects校验-geometry为MultiPoint，待查询字段（GEO类型为MultiPolygon）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_MultiPoint3',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': 'MultiPolygon',
        'geoIntersects_value': {
          'geometry': geo.multiPoint([
            geo.point(10, 10),
            geo.point(80, 80),
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK15'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK15'
    },
    {
      'desc': 'geoIntersects校验-geometry为MultiPolygon，待查询字段（GEO类型为MultiPolygon）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_MultiPolygon2',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': 'MultiPolygon',
        'geoIntersects_value': {
          'geometry': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(5, 0),
                geo.point(80, 80),
                geo.point(80, 0),
                geo.point(5, 0),
              ])
            ])
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK15'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK15'
    },
    {
      'desc': 'geoIntersects校验-geometry为MultiLineString，待查询字段（GEO类型为MultiPolygon）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_MultiLineString',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': 'MultiPolygon',
        'geoIntersects_value': {
          'geometry': geo.multiLineString([
            geo.lineString([
              geo.point(5, 0),
              geo.point(80, 80),
            ])
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK15'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK15'
    },

    {
      'desc': 'geoIntersects校验-geometry为MultiPoint，待查询字段（GEO类型为MultiLineString）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_MultiLineString2',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': "MultiLineString",
        'geoIntersects_value': {
          'geometry': geo.multiPoint([
            geo.point(0, 25),
            geo.point(80, 80),
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK08'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK08'
    },
    {
      'desc': 'geoIntersects校验-geometry为MultiLineString，待查询字段（GEO类型为MultiLineString）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'name': 'geoIntersects_MultiLineString3',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': "MultiLineString",
        'geoIntersects_value': {
          'geometry': geo.multiLineString([
            geo.lineString([
              geo.point(-10, 25),
              geo.point(10, 25),
            ])
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK08'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK08'
    },
    {
      'desc': 'geoIntersects校验-geometry为MultiPolygon，待查询字段（GEO类型为MultiLineString）与之相交叉',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_geoIntersects',
        'collection_name': 'doc_wcc',
        'geoIntersects_key': "MultiLineString",
        'geoIntersects_value': {
          'geometry': geo.multiPolygon([
            geo.polygon([
              geo.lineString([
                geo.point(-10, 25),
                geo.point(10, 25),
                geo.point(10, 45),
                geo.point(-10, 25),
              ])
            ])
          ])
        },
      },
      'eval': "response.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK08'",
      'expect': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK08'
    },
  ]
};