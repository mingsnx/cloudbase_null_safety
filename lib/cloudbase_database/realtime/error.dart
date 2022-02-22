/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

class RealtimeErrorMessageException implements Exception {
  Map serverErrorMsg;

  RealtimeErrorMessageException({required this.serverErrorMsg});

  @override
  String toString() {
    return 'Watch Error ${serverErrorMsg.toString()} (requestid: ${serverErrorMsg['requestId']})';
  }
}

class TimeoutException implements Exception {}

class CancelledException implements Exception {
  String message;

  CancelledException({required this.message});

  @override
  String toString() {
    return message;
  }
}
