/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_database/realtime/virtual_websocket_client.dart';

class Snapshot {
  num id;
  List<SingleDocChange> docChanges;
  List docs;
  String? type;
  String? msgType;

  Snapshot({
    required this.id,
    required this.docChanges,
    required this.docs,
    this.type,
    this.msgType,
  });

  @override
  String toString() {
    Map snapshot = {
      'id': id,
      'docChanges': docChanges,
      'docs': docs,
      'type': type,
      'msgType': msgType
    };

    return snapshot.toString();
  }
}
