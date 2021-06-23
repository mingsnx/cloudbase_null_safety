
/// orgin pub package: https://pub.dev/packages/cloudbase_core
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:dio/dio.dart';

import './base.dart';
import './store.dart';

const String _TRACE_HEADER = 'x-tcb-trace';

/// 用户统计和分析
class Trace {
  late String _traceCacheKey;
  String? _traceCacheValue;
  CloudBaseStore? _store;

  /// 缓存 Trace 实例
  static final Map<String, Trace> _cache = <String, Trace>{};

  Trace._internal(CloudBaseCore core) {
    _traceCacheKey = '${core.config.env!}_trace';
  }

  /// Trace(?)
  factory Trace(CloudBaseCore core) {
    String env = core.config.env!;

    if (_cache.containsKey(env)) {
      return _cache[env]!;
    } else {
      final trace = Trace._internal(core);
      _cache[env] = trace;
      return trace;
    }
  }

  /// add trace
  Future<void> addTrace(Dio dio) async {
    // 如果内存缓存为空, 则先从本地缓存读取
    if (_traceCacheValue == null) {
      _traceCacheValue = await _getLocalValue(_traceCacheKey);
    }

    if (_traceCacheValue != null && _traceCacheValue!.isNotEmpty) {
      dio.options.headers[_TRACE_HEADER] = _traceCacheValue;
    }
  }

  /// update trace
  Future<void> updateTrace(Response response) async {
    String? trace = response.headers.value(_TRACE_HEADER);
    if (trace == null || trace == _traceCacheValue) {
      return;
    }

    // 更新内存缓存和本地缓存的trace
    _traceCacheValue = trace;
    await _setLocalValue(_traceCacheKey, _traceCacheValue!);
  }

  Future<String> _getLocalValue(String key) async {
    if (_store == null) {
      _store = await CloudBaseStore().init();
    }

    return await _store!.get(key);
  }

  Future<void> _setLocalValue(String key, String value) async {
    if (_store == null) {
      _store = await CloudBaseStore().init();
    }

    await _store!.set(key, value);
  }
}
