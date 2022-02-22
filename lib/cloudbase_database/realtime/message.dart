/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:math';

class Message {
  static String genRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextDouble()}';
  }

  static const DATA_VERSION = '2019-06-01';
}
