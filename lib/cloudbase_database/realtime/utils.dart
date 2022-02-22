/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

class Console {
  static log(Object object) {
    print(object);
  }

  static warn(Object object) {
    print(object);
  }

  static error(Object object) {
    print(object);
  }
}

class Lodash {
  static set(obj, String fieldPath, value) {
    var paths = fieldPath.split('.');
    var curObj = obj;
    for (var i = 0; i < paths.length; i++) {
      var path = paths[i];
      var nextObj;

      if (i == paths.length - 1) {
        if (curObj is List) {
          curObj[int.parse(path)] = value;
        } else if (curObj is Map) {
          curObj[path] = value;
        } else {
          throw '[realtime] lodash set error';
        }
      } else {
        if (curObj is List) {
          nextObj = curObj[int.parse(path)] ?? {};
          curObj[int.parse(path)] = nextObj;
          curObj = nextObj;
        } else if (curObj is Map) {
          nextObj = curObj[path] ?? {};
          curObj[path] = nextObj;
          curObj = nextObj;
        } else {
          throw '[realtime] lodash set error';
        }
      }
    }
  }

  static unset(obj, String fieldPath) {
    var paths = fieldPath.split('.');
    var curObj = obj;
    for (var i = 0; i < paths.length; i++) {
      var path = paths[i];
      var nextObj;

      if (i == paths.length - 1) {
        if (curObj is List) {
          (curObj).removeAt(int.parse(path));
        } else if (curObj is Map) {
          curObj.remove(path);
        } else {
          throw '[realtime] lodash set error';
        }
      } else {
        if (curObj is List) {
          nextObj = curObj[int.parse(path)];
          curObj = nextObj;
        } else if (curObj is Map) {
          nextObj = curObj[path];
          curObj = nextObj;
        } else {
          throw '[realtime] lodash set error';
        }
      }
    }
  }
}
