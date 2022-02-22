/// orgin pub package: https://pub.dev/packages/cloudbase_core
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _CLOUDBASE_KEY = 'cloudbase_store';

/// 使用 Map 存储 key-value
/// 然后 JSON 格式化 Map 使用 shared_preferences 存储到本地
class CloudBaseStore {
  SharedPreferences? _prefs;

  /// 初始化 CloudBaseStore
  Future<CloudBaseStore> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    return this;
  }

  // 可以考虑版本控制
  _getStoreKey() {
    return _CLOUDBASE_KEY;
  }

  Future<Map> _getStoreMap() async {
    String? storeValue = _prefs?.get(_getStoreKey()) as String?;
    if (storeValue != null) {
      return jsonDecode(storeValue);
    }
    return {};
  }

  Future<bool> _setStoreMap(Map storeMap) async {
    String value = jsonEncode(storeMap);
    return await _prefs?.setString(_getStoreKey(), value) ?? false;
  }

  /// get value by key
  Future<dynamic> get(String key) async {
    Map store = await _getStoreMap();
    return store[key];
  }

  /// set value
  Future<bool> set(String key, dynamic value) async {
    Map store = await _getStoreMap();
    store[key] = value;
    return _setStoreMap(store);
  }

  /// remove value
  Future<bool> remove(String key) async {
    Map store = await _getStoreMap();
    store.remove(key);
    return _setStoreMap(store);
  }

  /// clear store
  Future<bool> clear() async {
    Map store = await _getStoreMap();
    store.clear();
    return _setStoreMap(store);
  }
}
