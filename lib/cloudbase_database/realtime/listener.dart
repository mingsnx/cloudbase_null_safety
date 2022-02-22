/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_database/realtime/snapshot.dart';

class RealtimeListener {
  Function close;
  Function? onChange;
  Function? onError; // todo 格式化

  RealtimeListener({required this.close, this.onChange, this.onError}) {
    if (this.onChange == null) {
      this.onChange = (Snapshot snapshot) {};
    }
    if (this.onError == null) {
      this.onError = (error) {};
    }
  }
}
