/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_database/geo.dart';
import 'package:cloudbase_null_safety/cloudbase_database/regexp.dart';
import 'package:cloudbase_null_safety/cloudbase_database/serverdate.dart';
import 'package:cloudbase_null_safety/cloudbase_core/base.dart';
import './command.dart';
import './collection.dart';

class CloudBaseDatabase {
  late CloudBaseCore _core;
  late Command _command;
  late Geo _geo;

  Command get command {
    return _command;
  }

  Geo get geo {
    return _geo;
  }

  CloudBaseDatabase(CloudBaseCore core) {
    _core = core;
    _command = Command();
    _geo = Geo();
  }

  Collection collection(String name) {
    return Collection(_core, name);
  }

  RegExp regExp(String regexp, [String? options]) {
    return RegExp(regexp, options);
  }

  ServerDate serverDate([num? offset]) {
    return ServerDate(offset);
  }
}
