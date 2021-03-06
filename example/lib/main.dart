import 'dart:developer' as dev;

import 'package:cloudbase_null_safety/cloudbase_database/collection.dart';
import 'package:cloudbase_null_safety/cloudbase_database/database.dart';
import 'package:cloudbase_null_safety/cloudbase_database/query.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/listener.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/snapshot.dart';
import 'package:cloudbase_null_safety/cloudbase_database/response.dart';
import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';
import 'package:cloudbase_null_safety/test_method_channel.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'case/interface_collection_p0.dart' as collection_p0;
import 'case/interface_command_p0.dart' as command_p0;
import 'case/intergace_geo_p0.dart' as geo_p0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformTest = 'Unknown';
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformTest;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformTest =
          await TestMethodChannel.platformTest ?? 'Unknown platform test';
    } on PlatformException {
      platformTest = 'Failed to get platform test.';
    } on MissingPluginException {
      platformTest = 'iOS platform test.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformTest = platformTest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// [???????????????]
              /// ~ ????????????????????????https://console.cloud.tencent.com/tcb/db/index????????????
              /// ?????? 2 ?????????`doc_wcc`???`tcb_hello_world`
              /// ?????????
              /// ?????? `????????????` ??????????????????????????????????????? (??????)
              ///
              /// ???????????? `doc_wcc` ??????????????? 6 ??? `????????????` ??????,
              /// ?????????
              /// ?????? (https://console.cloud.tencent.com/tcb/database/collection/doc_wcc)
              /// ?????? `????????????` ?????????, ?????? `????????????`, ?????????????????? 6 ?????????
              /// [
              ///   // ??????: {'????????????' : '????????????'} // (?????????????????????????????????)
              ///   {'point_index': 'Point'},
              ///   {'polygon_index': 'Polygon'},
              ///   {'lineString_index': 'LineString'},
              ///   {'multiPoint_index': 'MultiPoint'},
              ///   {'multiPolygon_index': 'MultiPolygon'},
              ///   {'multiLineString_index': 'MultiLineString'},
              /// ]
              /// ???????????????????????????????????????https://s4.ax1x.com/2022/02/22/bSPSYR.png
              TextButton(
                  onPressed: () async {
                    final CloudBaseCore core = await loginCloud();
                    await goTest(core);
                  },
                  child: Text('Run TEST')),
              Text(
                _platformTest,
                style: Theme.of(context).textTheme.headline5,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<CloudBaseCore> loginCloud() async {
    /// `????????????` ????????? https://console.cloud.tencent.com/tcb/env/login ???????????????
    CloudBaseCore core = CloudBaseCore.init({
      // ??? https://console.cloud.tencent.com/tcb/env/overview ?????? `??????ID`
      'env': '?????????????????????ID',
      'appAccess': {
        /// ?????? https://console.cloud.tencent.com/tcb/env/safety
        /// ????????????????????????, ?????????????????????????????????(????????????)???com.example.example???
        /// ???????????????????????????????????????????????????????????????????????????????????????????????????, ????????????????????????
        /// ???????????????????????? `key` ??????
        'key': '???????????????????????????key',
        'version': '1' // ?????????????????????????????????
      }
    });
    
    //core.setAuthInstance(TestAuth());
    CloudBaseAuth auth = CloudBaseAuth(core);
    CloudBaseAuthState? authState = await auth.getAuthState();
    if (authState == null) {
      authState = await auth.signInAnonymously();
    }
    return core;
  }

  Future<void> goTest(CloudBaseCore core) async {
    logIndex = 0;
    log("go");
    CloudBaseDatabase db = CloudBaseDatabase(core);

    /// collection p0??????
    await test(collection_p0.cases_data['name']!, () async {
      List cases = collection_p0.cases_data['cases'] as List;
      for (var i = 0; i < cases.length; i++) {
        await runCases(db, cases[i], collection_p0.cases_data['name']!);
      }
    });

    /// command p0??????
    await test(command_p0.cases_data['name']!, () async {
      List cases = command_p0.cases_data['cases'] as List;
      for (var i = 0; i < cases.length; i++) {
        await runCases(db, cases[i], command_p0.cases_data['name']!);
      }
    });

    /// geo command p0??????
    await test(geo_p0.cases_data['name']!, () async {
      List cases = geo_p0.cases_data['cases'] as List;
      for (var i = 0; i < cases.length; i++) {
        await runCases(db, cases[i], geo_p0.cases_data['name']!);
      }
    });

    /// server date p0??????
    await test('server_data p0??????', () async {
      var collection = db.collection('doc_wcc');
      var res = await collection
          .add({'description': 'eat an apple', 'createTime': db.serverDate()});
      testLog(res.code == null, 'server_data p0??????', res);
      var res2 = await collection.doc(res.id).get();
      testLog(res2.code == null, 'server_data p0??????', res2);
      testLog(res2.data[0]['createTime'] is DateTime, 'server_data p0??????', res2);
    });

    /// ???????????? p0??????
    await test(collection_p0.cases_data['name']!, () async {
      var collection = db.collection('tcb_hello_world');
      var data = {
        '_id': "f3db088f5e84cd1300409145374590bc", //??????ID
        'age': 18,
        'name': 'hhxxn',
      };
      var res = await collection.add(data);
      testLog(res.id == data['_id'], "?????????????????? p0?????? - add??????", res);
      // ???doc??????
      RealtimeListener rl1 = collection
          .doc('f3db088f5e84cd1300409145374590ba')
          .watch(onChange: (Snapshot snapshot) {
        testLog(
            snapshot.docs.length == 1, "???????????? p0?????? - ???doc?????? watch", snapshot);
      }, onError: (error) {
        testLog(error == null, "???????????? p0?????? - ???doc?????? onError", error);
      });
      // query??????
      RealtimeListener rl2 =
          collection.where({'age': 18}).watch(onChange: (Snapshot snapshot) {
        testLog(
            snapshot.docs.length > 0, "???????????? p0?????? - query?????? watch", snapshot);
      }, onError: (error) {
        testLog(error == null, "???????????? p0?????? - query?????? onError", error);
      });

      // query + command ??????
      RealtimeListener rl3 = collection.where({'age': db.command.gt(15)}).watch(
          onChange: (Snapshot snapshot) {
        testLog(snapshot.docs.length > 0, "???????????? p0?????? - query?????? + command watch",
            snapshot);
      }, onError: (error) {
        testLog(error == null, "???????????? p0?????? - query + command ?????? onError", error);
      });

      // ??????10s,???watch?????????
      await Future.delayed(Duration(seconds: 10), () {
        rl1.close();
        rl2.close();
        rl3.close();
      });
    });
  }

  int logIndex = 0;
  void log(String val) {
    dev.log("($logIndex) message: $val");
    logIndex++;
  }

  Future<void> test(
    dynamic teatName,
    Function invoke,
  ) async {
    dev.log("($logIndex) ??????: $teatName: ");
    await invoke();
  }

  Future<dynamic> collectionOp(
      CloudBaseDatabase db, String cmd, dynamic event) async {
    Query collection = db.collection(event['collection_name']);

    switch (cmd) {
      case 'collection_doc':
        return (collection as Collection).doc(event['record_id']).get();

      case 'collection_get':
        if (event['skip'] != null) {
          collection = collection.skip(event['skip']);
        }
        if (event['filter'] != null) {
          collection = collection.where(event['filter']);
        }
        if (event['limit'] != null) {
          collection = collection.limit(event['limit']);
        }
        if (event['order_key'] != null && event['order_type'] != null) {
          collection =
              collection.orderBy(event['order_key'], event['order_type']);
        }
        if (event['field'] != null) {
          collection = collection.field(event['field']);
        }
        return collection.get();

      case 'collection_search':
        return collection
            .where(event['filter'])
            .skip(event['skip'])
            .limit(event['limit'])
            .orderBy(event['order_key'], event['order_type'])
            .field(event['field'])
            .get();

      case 'collection_add':
        return (collection as Collection).add(event['data']);

      case 'collection_update':
        return collection.where(event['filter']).update(event['data']);

      case 'collection_remove':
        return collection.where(event['filter']).remove();

      case 'collection_count':
        return collection.where({'_id': db.command.neq('undefined')}).count();

      case 'collection_where':
        return collection.where(event['filter']).get();

      case 'collection_orderBy':
        return collection
            .orderBy(event['order_key'], event['order_type'])
            .get();

      case 'collection_limit':
        return collection.limit(event['limit']).get();

      case 'collection_skip':
        return collection.where(event['filter']).skip(event['skip']).get();

      case 'collection_field':
        return collection.field(event['field']).get();

      case 'collection_clean':
        DbQueryResponse res = await collection.get();
        List coll = res.data ?? [];
        return Future.wait(coll.map((doc) {
          return (collection as Collection).doc(doc['_id']).remove();
        }));

      default:
        return null;
    }
  }

  Future<dynamic> docOp(CloudBaseDatabase db, String cmd, dynamic event) async {
    var doc = db.collection(event['collection_name']).doc(event['doc_id']);

    switch (cmd) {
      case 'doc_get':
        return doc.get();

      case 'doc_set':
        return doc.set(event['data']);

      case 'doc_update':
        return doc.update(event['data']);

      case 'doc_remove':
        return doc.remove();

      default:
    }
  }

  Future<dynamic> commandOp(
      CloudBaseDatabase db, String cmd, dynamic event) async {
    var collection = db.collection(event['collection_name']);
    var _ = db.command;

    switch (cmd) {
      case 'command_eq':
        return collection
            .where({event['eq_key']: _.eq(event['eq_value'])}).get();

      case 'command_neq':
        return collection
            .where({event['neq_key']: _.neq(event['neq_value'])}).get();

      case 'command_lt':
        return collection
            .where({event['lt_key']: _.lt(event['lt_value'])}).get();

      case 'command_lte':
        return collection
            .where({event['lte_key']: _.lte(event['lte_value'])}).get();

      case 'command_gt':
        return collection
            .where({event['gt_key']: _.gt(event['gt_value'])}).get();

      case 'command_gte':
        return collection
            .where({event['gte_key']: _.gte(event['gte_value'])}).get();

      case 'command_in':
        return collection
            .where({event['in_key']: _.into(event['in_value'])}).get();

      case 'command_nin':
        return collection
            .where({event['nin_key']: _.nin(event['nin_value'])}).get();

      case 'command_and':
        return collection.where({
          event['and_key']:
              _.and([_.gt(event['and_value0']), _.lt(event['and_value1'])])
        }).get();

      case 'command_or':
        return collection.where({
          event['or_key']:
              _.or([_.gt(event['or_value0']), _.lt(event['or_value1'])])
        }).get();

      case 'command_set':
        return collection
            .doc(event['doc_id'])
            .update({event['set_key']: _.set(event['set_value'])});

      case 'command_remove':
        return collection
            .doc(event['doc_id'])
            .update({event['remove_key']: _.remove()});

      case 'command_inc':
        return collection
            .doc(event['doc_id'])
            .update({event['inc_key']: _.inc(event['inc_value'])});

      case 'command_mul':
        return collection
            .doc(event['doc_id'])
            .update({event['mul_key']: _.mul(event['mul_value'])});

      case 'command_push':
        return collection
            .doc(event['doc_id'])
            .update({event['push_key']: _.push(event['push_value'])});

      case 'command_pop':
        return collection
            .doc(event['doc_id'])
            .update({event['pop_key']: _.pop()});

      case 'command_shift':
        return collection
            .doc(event['doc_id'])
            .update({event['shift_key']: _.shift()});

      case 'command_unshift':
        return collection
            .doc(event['doc_id'])
            .update({event['unshift_key']: _.unshift(event['unshift_value'])});

      case 'command_geoNear':
        return collection.where({
          event['geoNear_key']: _.geoNear(
            event['geoNear_value']['geometry'],
            maxDistance: event['geoNear_value']['maxDistance'],
            minDistance: event['geoNear_value']['minDistance'],
          )
        }).get();

      case 'command_geoWithin':
        return collection.where({
          event['geoWithin_key']:
              _.geoWithin(event['geoWithin_value']['geometry'])
        }).get();

      case 'command_geoIntersects':
        return collection.where({
          event['geoIntersects_key']:
              _.geoIntersects(event['geoIntersects_value']['geometry'])
        }).get();

      default:
        return null;
    }
  }

  Future<void> runCases(db, element, testName) async {
    var event = element['request'];
    String cmd = event['cmd'];
    print(element['desc']);

    dynamic res;
    if (cmd.startsWith('collection')) {
      res = await collectionOp(db, cmd, event);
    } else if (cmd.startsWith('doc')) {
      res = await docOp(db, cmd, event);
    } else if (cmd.startsWith('command')) {
      res = await commandOp(db, cmd, event);
    }

    //log("expect: 1 -> ${res is List || res != null}");
    if (element['expect'] != null) {
      final value = element['expect'](res);
      testLog(value, element['desc'], res);
    }
  }

  void testLog(res, testName, data) {
    final result = "?????? [$testName] ${res ? 'SUCCESS' : 'FAIL'}";
    print(res ? "" : data);
    log("expect: [test result] -> $result");
  }
}
