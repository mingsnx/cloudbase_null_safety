/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_core/base.dart';
import 'package:cloudbase_null_safety/cloudbase_database/query.dart';
import 'package:cloudbase_null_safety/cloudbase_database/document.dart';
import 'package:cloudbase_null_safety/cloudbase_database/response.dart';
import 'package:cloudbase_null_safety/cloudbase_database/validater.dart';

class Collection extends Query {
  Collection(
    CloudBaseCore core,
    String collName,
  ) : super(core: core, coll: collName);

  String get name {
    return super.coll;
  }

  Document doc([docId]) {
    if (docId != null) {
      Validater.isDocId(docId);
    }

    return Document(core: super.core, coll: super.coll, docId: docId);
  }

  Future<DbCreateResponse> add(dynamic data) {
    Document doc = this.doc();
    return doc.create(data);
  }
}
