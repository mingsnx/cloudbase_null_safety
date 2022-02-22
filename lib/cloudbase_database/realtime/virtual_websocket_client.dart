/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:async';
import 'dart:convert' as JSON;
import 'dart:math';

import 'package:cloudbase_null_safety/cloudbase_null_safety.dart';
import 'package:cloudbase_null_safety/cloudbase_database/config/error_config.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/error.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/listener.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/message.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/snapshot.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/utils.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/websocket_client.dart';

class WatchSessionInfo {
  String? queryID;
  late int currentEventId;
  late List currentDocs;
  int? expectEventId;

  WatchSessionInfo(
      {this.queryID,
      this.currentEventId = 0,
      this.currentDocs = const [],
      this.expectEventId = 0});
}

class AvailableRetries {
  int? initWatch;
  int? rebuildWatch;
  late int checkLast;

  AvailableRetries({this.initWatch, this.rebuildWatch, this.checkLast = 0});

  getRetries(String operationName) {
    switch (operationName) {
      case 'INIT_WATCH':
        return initWatch;
      case 'REBUILD_WATCH':
        return rebuildWatch;
      case 'CHECK_LAST':
        return checkLast;
      default:
        return 0;
    }
  }

  setRetries(String operationName, int retries) {
    switch (operationName) {
      case 'INIT_WATCH':
        initWatch = retries;
        break;
      case 'REBUILD_WATCH':
        rebuildWatch = retries;
        break;
      case 'CHECK_LAST':
        checkLast = retries;
        break;
    }
  }
}

class SingleDocChange {
  late int id;
  String? dataType;
  String? queueType;
  String? docId;
  Map? doc;
  Map? updatedFields;
  List? removedFields;

  SingleDocChange(Map event) {
    this.id = event['ID'] ?? -199;
    this.dataType = event['DataType'];
    this.queueType = event['QueueType'];
    this.docId = event['DocID'];

    if (event['Doc'] is String && event['Doc'] != '{}') {
      this.doc = JSON.jsonDecode(event['Doc']);
    }

    if (dataType == 'update') {
      if (event['UpdatedFields'] is String && event['UpdatedFields'] != '') {
        this.updatedFields = JSON.jsonDecode(event['UpdatedFields']);
      }
      if (event['removedFields'] is String && event['removedFields'] != '') {
        this.removedFields = JSON.jsonDecode(event['removedFields']);
      }
    }
  }

  @override
  String toString() {
    Map change = {
      'id': id,
      'dataType': dataType,
      'queueType': queueType,
      'docId': docId,
      'doc': doc,
      'updatedFields': updatedFields,
      'removedFields': removedFields
    };
    return change.toString();
  }
}

enum WATCH_STATUS {
  LOGGINGIN,
  INITING,
  REBUILDING,
  ACTIVE,
  ERRORED,
  CLOSING,
  CLOSED,
  PAUSED,
  RESUMING
}

typedef Future<LoginResult> LoginFunc({String? envId, bool? refresh});
typedef Future<Map?> SendFunc(
    {required Map msg, bool waitResponse, bool skipOnMessage, int? timeout});
typedef bool IsWSConnectedFunc();
typedef Future<void> OnceWSConnectedFunc();
typedef num GetWaitExpectedTimeoutLengthFunc();
typedef void WatchStartCallback(VirtualWebSocketClient client, String queryID);
typedef void WatchCloseCallback(VirtualWebSocketClient client, String? queryID);

const DEFAULT_WAIT_TIME_ON_UNKNOWN_ERROR = 100;
const DEFAULT_MAX_AUTO_RETRY_ON_ERROR = 2;
const DEFAULT_MAX_SEND_ACK_AUTO_RETRY_ON_ERROR = 2;
const DEFAULT_SEND_ACK_DEBOUNCE_TIMEOUT = 10 * 1000;
const DEFAULT_INIT_WATCH_TIMEOUT = 10 * 1000;
const DEFAULT_REBUILD_WATCH_TIMEOUT = 10 * 1000;

class VirtualWebSocketClient {
  late String watchId;
  String? _envId;
  String? _collectionName;
  String? _query;
  int? _limit;
  Map<String, String>? _orderBy;
  late SendFunc _send;
  late LoginFunc _login;
  late IsWSConnectedFunc _isWSConnected;
  late OnceWSConnectedFunc _onceWSConnected;
  late GetWaitExpectedTimeoutLengthFunc _getWaitExpectedTimeoutLength;
  late WatchStartCallback _onWatchStart;
  late WatchCloseCallback _onWatchClose;
  bool? _debug;

  // own
  RealtimeListener? listener;
  WATCH_STATUS? _watchStatus;
  late AvailableRetries _availableRetries;
  Timer? _ackTimer;
  Future<void>? _initWatchPromise;
  dynamic _rebuildWatchPromise;

  // obtained
  WatchSessionInfo? _sessionInfo;

  // internal
  Timer? _waitExpectedTimer;

  VirtualWebSocketClient({
    String? envId,
    String? collectionName,
    String? query,
    int? limit,
    Map<String, String>? orderBy,
    required SendFunc send,
    required LoginFunc login,
    required IsWSConnectedFunc isWSConnected,
    required OnceWSConnectedFunc onceWSConnected,
    required GetWaitExpectedTimeoutLengthFunc getWaitExpectedTimeoutLength,
    required WatchStartCallback onWatchStart,
    required WatchCloseCallback onWatchClose,
    Function? onChange,
    Function? onError,
    bool? debug,
  }) {
    this.watchId =
        'watchid_${DateTime.now().millisecondsSinceEpoch}_${Random().nextDouble()}';
    this._envId = envId;
    this._collectionName = collectionName;
    this._query = query;
    this._limit = limit;
    this._orderBy = orderBy;
    this._send = send;
    this._login = login;
    this._isWSConnected = isWSConnected;
    this._onceWSConnected = onceWSConnected;
    this._getWaitExpectedTimeoutLength = getWaitExpectedTimeoutLength;
    this._onWatchStart = onWatchStart;
    this._onWatchClose = onWatchClose;
    this._debug = debug;

    this._availableRetries = AvailableRetries(
      initWatch: DEFAULT_MAX_AUTO_RETRY_ON_ERROR,
      rebuildWatch: DEFAULT_MAX_AUTO_RETRY_ON_ERROR,
      checkLast: DEFAULT_MAX_SEND_ACK_AUTO_RETRY_ON_ERROR,
    );

    this.listener = RealtimeListener(
      close: this._closeWatch,
      onChange: onChange,
      onError: onError,
    );

    this._initWatch();
  }

  Future<LoginResult> _internalLogin({String? envId, bool? refresh}) async {
    this._watchStatus = WATCH_STATUS.LOGGINGIN;
    LoginResult loginResult = await this._login(envId: envId, refresh: refresh);
    if (this._envId == null) {
      this._envId = loginResult.envId;
    }
    return loginResult;
  }

  Future<void> _initWatch({
    bool? forceRefreshLogin,
    Completer? completer,
  }) async {
    if (this._initWatchPromise != null) {
      return this._initWatchPromise;
    }

    if (completer == null) {
      completer = Completer();
    }
    this._internalInitWatch(forceRefreshLogin, completer);
    this._initWatchPromise = completer.future;

    bool success = false;

    try {
      await this._initWatchPromise;
      success = true;
    } finally {
      this._initWatchPromise = null;
    }

    // ignore: dead_code
    Console.log('[realtime] initWatch ${success ? 'success' : 'fail'}');
  }

  void _internalInitWatch(bool? forceRefreshLogin, Completer completer) async {
    try {
      if (this._watchStatus == WATCH_STATUS.PAUSED) {
        Console.log('[realtime] initWatch cancelled on pause');
        return completer.complete();
      }

      LoginResult loginResult = await this._internalLogin(
        envId: this._envId,
        refresh: forceRefreshLogin,
      );

      if (this._watchStatus == WATCH_STATUS.PAUSED) {
        Console.log('[realtime] initWatch cancelled on pause');
        return completer.complete();
      }

      this._watchStatus = WATCH_STATUS.INITING;

      var initWatchMsg = {
        'watchId': this.watchId,
        'requestId': Message.genRequestId(),
        'msgType': 'INIT_WATCH',
        'msgData': {
          'envId': loginResult.envId,
          'collName': this._collectionName,
          'query': this._query,
          'limit': this._limit,
          'orderBy': this._orderBy
        },
        'exMsgData': {'databaseMidTran': true, 'dataVersion': '2019-06-01'}
      };

      var initEventMsg = await this._send(
        msg: initWatchMsg,
        waitResponse: true,
        skipOnMessage: true,
        timeout: DEFAULT_INIT_WATCH_TIMEOUT,
      );
      if (initEventMsg == null) {
        // mingsnx added
        return;
      }

      String queryID = initEventMsg['msgData']['queryID'];
      List events = initEventMsg['msgData']['events'];
      int currEvent = initEventMsg['msgData']['currEvent'];

      this._sessionInfo = WatchSessionInfo(
        queryID: queryID,
        currentEventId: currEvent - 1,
        currentDocs: [],
      );

      // FIX: in initEvent message, all events have id 0, which is inconsistent with currEvent
      if (events.length > 0) {
        events.forEach((e) {
          e['ID'] = currEvent;
        });

        await this._handleServerEvents(initEventMsg);
      } else {
        this._sessionInfo!.currentEventId = currEvent;
        var snapshot =
            Snapshot(id: currEvent, docChanges: [], docs: [], type: 'init');
        this.listener?.onChange?.call(snapshot);
        this._scheduleSendACK();
      }

      this._onWatchStart(this, this._sessionInfo!.queryID!);
      this._watchStatus = WATCH_STATUS.ACTIVE;
      this._availableRetries.initWatch = DEFAULT_MAX_AUTO_RETRY_ON_ERROR;
      completer.complete();
    } catch (e) {
      this._handleWatchEstablishmentError(
        e: e,
        operationName: 'INIT_WATCH',
        completer: completer,
      );
    }
  }

  Future<void> _rebuildWatch({
    bool forceRefreshLogin = true,
    Completer? completer,
  }) async {
    if (this._rebuildWatchPromise != null) {
      return this._rebuildWatchPromise;
    }

    if (completer == null) {
      completer = Completer();
    }
    this._internalRebuildWatch(forceRefreshLogin, completer);
    this._rebuildWatchPromise = completer.future;

    bool success = false;

    try {
      await this._rebuildWatchPromise;
      success = true;
    } finally {
      this._rebuildWatchPromise = null;
    }

    Console.log('[realtime] rebuildWatch ${success ? 'success' : 'fail'}');
  }

  void _internalRebuildWatch(
    bool forceRefreshLogin,
    Completer completer,
  ) async {
    try {
      if (this._watchStatus == WATCH_STATUS.PAUSED) {
        Console.log('[realtime] initWatch cancelled on pause');
        return completer.complete();
      }

      LoginResult loginResult = await this._internalLogin(
        envId: this._envId,
        refresh: forceRefreshLogin,
      );

      if (this._sessionInfo == null) {
        throw 'can not rebuildWatch without a successful initWatch (lack of sessionInfo)';
      }

      if (this._watchStatus == WATCH_STATUS.PAUSED) {
        Console.log('[realtime] rebuildWatch cancelled on pause');
        return completer.complete();
      }

      this._watchStatus = WATCH_STATUS.REBUILDING;

      var rebuildWatchMsg = {
        'watchId': this.watchId,
        'requestId': Message.genRequestId(),
        'msgType': 'REBUILD_WATCH',
        'msgData': {
          'envId': loginResult.envId,
          'collName': this._collectionName,
          'queryID': this._sessionInfo!.queryID,
          'eventID': this._sessionInfo!.currentEventId
        }
      };

      var nextEventMsg = await this._send(
        msg: rebuildWatchMsg,
        waitResponse: true,
        skipOnMessage: false,
        timeout: DEFAULT_REBUILD_WATCH_TIMEOUT,
      );
      if (nextEventMsg == null) {
        // mingsnx added
        return;
      }

      await this._handleServerEvents(nextEventMsg);

      this._watchStatus = WATCH_STATUS.ACTIVE;
      this._availableRetries.rebuildWatch = DEFAULT_MAX_AUTO_RETRY_ON_ERROR;
      completer.complete();
    } catch (e) {
      this._handleWatchEstablishmentError(
        e: e,
        operationName: 'REBUILD_WATCH',
        completer: completer,
      );
    }
  }

  void _handleWatchEstablishmentError({
    e,
    required String operationName,
    required Completer completer,
  }) async {
    bool isInitWatch = operationName == 'INIT_WATCH';

    var abortWatch = () {
      this.closeWithError(
        CloudBaseException(
          code: isInitWatch
              ? ErrCode.SDK_DATABASE_REALTIME_LISTENER_INIT_WATCH_FAIL
              : ErrCode.SDK_DATABASE_REALTIME_LISTENER_REBUILD_WATCH_FAIL,
          message: e.toString(),
        ),
      );
      completer.completeError(e);
    };

    var retry = ([bool refreshLogin = true]) async {
      if (this._useRetryTicket(operationName)) {
        if (isInitWatch) {
          this._initWatchPromise = null;
          await this._initWatch(
            forceRefreshLogin: refreshLogin,
            completer: completer,
          );
          completer.complete();
        } else {
          this._rebuildWatchPromise = null;
          await this._rebuildWatch(
            forceRefreshLogin: refreshLogin,
            completer: completer,
          );
          completer.complete();
        }
      } else {
        abortWatch();
      }
    };

    this._handleCommonError(
      e,
      onSignError: () {
        retry(true);
      },
      onTimeoutError: () {
        retry(false);
      },
      onNotRetryableError: abortWatch,
      onCancelledError: completer.completeError,
      onUnknownError: () async {
        try {
          var onWSDisconnected = () async {
            this.pause();
            await this._onceWSConnected();
            retry(true);
          };

          if (this._isWSConnected() != true) {
            await onWSDisconnected();
          } else {
            await Future.delayed(
                Duration(milliseconds: DEFAULT_WAIT_TIME_ON_UNKNOWN_ERROR));
            if (this._watchStatus == WATCH_STATUS.PAUSED) {
              completer.completeError(CancelledException(
                  message:
                      '$operationName cancelled due to pause after unknownError'));
            } else if (this._isWSConnected() != true) {
              await onWSDisconnected();
            } else {
              retry(false);
            }
          }
        } catch (e) {
          // unexpected error while handling error, in order to provide maximum effort on SEAMINGLESS FAULT TOLERANCE, just retry
          retry(true);
        }
      },
    );
  }

  Future<void> _closeWatch() async {
    String? queryId =
        this._sessionInfo != null ? this._sessionInfo!.queryID : '';

    if (this._watchStatus != WATCH_STATUS.ACTIVE) {
      this._watchStatus = WATCH_STATUS.CLOSED;
      this._onWatchClose(this, queryId);
      return;
    }

    try {
      this._watchStatus = WATCH_STATUS.CLOSING;

      var closeWatchMsg = {
        'watchId': this.watchId,
        'requestId': Message.genRequestId(),
        'msgType': 'CLOSE_WATCH',
      };

      await this._send(msg: closeWatchMsg);

      this._sessionInfo = null;
      this._watchStatus = WATCH_STATUS.CLOSED;
    } catch (e) {
      this.closeWithError(CloudBaseException(
          code: ErrCode.SDK_DATABASE_REALTIME_LISTENER_CLOSE_WATCH_FAIL,
          message: e.toString()));
    } finally {
      this._onWatchClose(this, queryId);
    }
  }

  void _scheduleSendACK() {
    this._clearACKSchedule();

    this._ackTimer =
        Timer(Duration(milliseconds: DEFAULT_SEND_ACK_DEBOUNCE_TIMEOUT), () {
      if (this._waitExpectedTimer != null) {
        this._scheduleSendACK();
      } else {
        this._sendACK();
      }
    });
  }

  void _clearACKSchedule() {
    if (this._ackTimer != null) {
      this._ackTimer!.cancel();
      this._ackTimer = null;
    }
  }

  Future<void> _sendACK() async {
    try {
      if (this._watchStatus != WATCH_STATUS.ACTIVE) {
        this._scheduleSendACK();
        return;
      }

      if (this._sessionInfo == null) {
        Console.warn(
            '[realtime listener] can not send ack without a successful initWatch (lack of sessionInfo)');
        return;
      }

      var ackMsg = {
        'watchId': this.watchId,
        'requestId': Message.genRequestId(),
        'msgType': 'CHECK_LAST',
        'msgData': {
          'queryID': this._sessionInfo!.queryID,
          'eventID': this._sessionInfo!.currentEventId
        }
      };

      await this._send(msg: ackMsg);

      this._scheduleSendACK();
    } catch (e) {
      if (e is RealtimeErrorMessageException) {
        var msg = e.serverErrorMsg;
        switch (msg['msgData']['code']) {
          // signature error -> retry with refreshed signature
          case 'CHECK_LOGIN_FAILED':
          case 'SIGN_EXPIRED_ERROR':
          case 'SIGN_INVALID_ERROR':
          case 'SIGN_PARAM_INVALID':
            {
              this._rebuildWatch();
              return;
            }
          // other -> throw
          case 'QUERYID_INVALID_ERROR':
          case 'SYS_ERR':
          case 'INVALIID_ENV':
          case 'COLLECTION_PERMISSION_DENIED':
            {
              this.closeWithError(CloudBaseException(
                  code: ErrCode.SDK_DATABASE_REALTIME_LISTENER_CHECK_LAST_FAIL,
                  message: msg['msgData']['code']));
              return;
            }
          default:
            {
              break;
            }
        }
      }

      // maybe retryable
      if (this._availableRetries.checkLast > 0) {
        this._availableRetries.checkLast--;
        this._scheduleSendACK();
      } else {
        this.closeWithError(
          CloudBaseException(
            code: ErrCode.SDK_DATABASE_REALTIME_LISTENER_CHECK_LAST_FAIL,
            message: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _handleCommonError(
    e, {
    onSignError,
    onTimeoutError,
    onCancelledError,
    onNotRetryableError,
    onUnknownError,
  }) async {
    if (e is RealtimeErrorMessageException) {
      Map msg = e.serverErrorMsg;
      switch (msg['msgData']['code']) {
        // signature error -> retry with refreshed signature
        case 'CHECK_LOGIN_FAILED':
        case 'SIGN_EXPIRED_ERROR':
        case 'SIGN_INVALID_ERROR':
        case 'SIGN_PARAM_INVALID':
          {
            onSignError(e);
            return;
          }
        // not-retryable error -> throw
        case 'QUERYID_INVALID_ERROR':
        case 'SYS_ERR':
        case 'INVALIID_ENV':
        case 'COLLECTION_PERMISSION_DENIED':
          {
            onNotRetryableError(e);
            return;
          }
        default:
          {
            onNotRetryableError(e);
            return;
          }
      }
    } else if (e is TimeoutException) {
      onTimeoutError(e);
      return;
    } else if (e is CancelledException) {
      onCancelledError(e);
      return;
    }

    onUnknownError(e);
  }

  bool _useRetryTicket(String operationName) {
    int? retryTimes = this._availableRetries.getRetries(operationName);

    if (retryTimes != null && retryTimes > 0) {
      this._availableRetries.setRetries(operationName, retryTimes--);

      Console.log(
          '[realtime] $operationName use a retry ticket, now only $retryTimes retry left');

      return true;
    }

    return false;
  }

  Future<void> _handleServerEvents(Map msg) async {
    try {
      this._scheduleSendACK();
      await this._internalHandleServerEvents(msg);
      this._postHandleServerEventsValidityCheck(msg);
    } catch (e) {
      Console.error(
          '[realtime listener] internal non-fatal error: handle server events failed with error: ${e.toString()}');

      throw e;
    }
  }

  Future<void> _internalHandleServerEvents(Map msg) async {
    String requestId = msg['requestId'];
    String msgType = msg['msgType'];
    List events = msg['msgData']['events'];

    if (events.length <= 0 || this._sessionInfo == null) {
      return;
    }

    WatchSessionInfo sessionInfo = this._sessionInfo!;
    List<SingleDocChange> allChangeEvents = [];
    try {
      events.forEach((event) {
        allChangeEvents.add(SingleDocChange(event));
      });
    } catch (e) {
      throw CloudBaseException(
        code:
            ErrCode.SDK_DATABASE_REALTIME_LISTENER_RECEIVE_INVALID_SERVER_DATA,
        message: e.toString(),
      );
    }

    List docs = List.from(this._sessionInfo!.currentDocs);
    bool initEncountered = false;
    for (var i = 0, len = allChangeEvents.length; i < len; i++) {
      SingleDocChange change = allChangeEvents[i];

      if (sessionInfo.currentEventId >= change.id) {
        if (allChangeEvents[i - 1] == null ||
            change.id > allChangeEvents[i - 1].id) {
          // duplicate event, dropable
          Console.warn(
              '[realtime] duplicate event received, cur ${sessionInfo.currentEventId} but got ${change.id}');
        } else {
          // allChangeEvents should be in ascending order according to eventId, this should never happens, must report a non-fatal error
          Console.error(
              '[realtime listener] server non-fatal error: events out of order (the latter event\'s id is smaller than that of the former) (requestId $requestId)');
        }
        continue;
      } else if (sessionInfo.currentEventId == (change.id - 1)) {
        // correct sequence
        // first handle dataType then queueType:
        // 1. dataType: we ONLY populate change.doc if neccessary
        // 2. queueType: we build the data snapshot

        switch (change.dataType) {
          case 'update':
            {
              if (change.doc == null) {
                switch (change.queueType) {
                  case 'update':
                  case 'dequeue':
                    {
                      var localDoc = docs.firstWhere(
                        (doc) => doc['_id'] == change.docId,
                        orElse: () => null,
                      );
                      if (localDoc != null) {
                        var doc = JSON.jsonDecode(JSON.jsonEncode(localDoc));

                        if (change.updatedFields != null) {
                          change.updatedFields!.forEach((fieldPath, value) {
                            Lodash.set(doc, fieldPath, value);
                          });
                        }

                        if (change.removedFields != null) {
                          change.removedFields!.forEach((fieldPath) {
                            Lodash.unset(doc, fieldPath);
                          });
                        }

                        change.doc = doc;
                      } else {
                        Console.error(
                            '[realtime listener] internal non-fatal server error: unexpected update dataType event where no doc is associated.');
                      }
                      break;
                    }
                  case 'enqueue':
                    {
                      // doc is provided by server, this should never occur
                      CloudBaseException exception = CloudBaseException(
                          code: ErrCode
                              .SDK_DATABASE_REALTIME_LISTENER_UNEXPECTED_FATAL_ERROR,
                          message:
                              'HandleServerEvents: full doc is not provided with dataType="update" and queueType="enqueue" (requestId $requestId)');
                      this.closeWithError(exception);
                      throw exception;
                    }
                  default:
                    {
                      break;
                    }
                }
              }
              break;
            }
          case 'replace':
            {
              // validation
              if (change.doc == null) {
                // doc is provided by server, this should never occur
                CloudBaseException exception = CloudBaseException(
                    code: ErrCode
                        .SDK_DATABASE_REALTIME_LISTENER_UNEXPECTED_FATAL_ERROR,
                    message:
                        'HandleServerEvents: full doc is not provided with dataType="replace" (requestId $requestId)');
                this.closeWithError(exception);
                throw exception;
              }
              break;
            }
          case 'remove':
            {
              var doc = docs.firstWhere((doc) => doc['_id'] == change.docId,
                  orElse: () => null);
              if (doc != null) {
                change.doc = doc;
              } else {
                Console.error(
                    '[realtime listener] internal non-fatal server error: unexpected remove event where no doc is associated.');
              }
              break;
            }
          case 'limit':
            {
              if (change.doc == null) {
                switch (change.queueType) {
                  case 'dequeue':
                    {
                      var doc = docs.firstWhere(
                          (doc) => doc['_id'] == change.docId,
                          orElse: () => null);
                      if (doc != null) {
                        change.doc = doc;
                      } else {
                        Console.error(
                            '[realtime listener] internal non-fatal server error: unexpected limit dataType event where no doc is associated.');
                      }
                      break;
                    }
                  case 'enqueue':
                    {
                      // doc is provided by server, this should never occur
                      CloudBaseException exception = CloudBaseException(
                          code: ErrCode
                              .SDK_DATABASE_REALTIME_LISTENER_UNEXPECTED_FATAL_ERROR,
                          message:
                              'HandleServerEvents: full doc is not provided with dataType="limit" and queueType="enqueue" (requestId $requestId)');
                      this.closeWithError(exception);
                      throw exception;
                    }
                  default:
                    {
                      break;
                    }
                }
              }
              break;
            }
        }

        switch (change.queueType) {
          case 'init':
            {
              if (!initEncountered) {
                initEncountered = true;
                docs = [change.doc];
              } else {
                docs.add(change.doc);
              }
              break;
            }
          case 'enqueue':
            {
              docs.add(change.doc);
              break;
            }
          case 'dequeue':
            {
              int index = docs.indexWhere((doc) => doc['_id'] == change.docId);
              if (index > -1) {
                docs.removeAt(index);
              } else {
                Console.error(
                    '[realtime listener] internal non-fatal server error: unexpected dequeue event where no doc is associated.');
              }
              break;
            }
          case 'update':
            {
              int index = docs.indexWhere((doc) => doc['_id'] == change.docId);
              if (index > -1) {
                docs[index] = change.doc;
              } else {
                Console.error(
                    '[realtime listener] internal non-fatal server error: unexpected queueType update event where no doc is associated.');
              }
              break;
            }
        }

        if (i == len - 1 ||
            (allChangeEvents[i + 1] != null &&
                allChangeEvents[i + 1].id != change.id)) {
          // a shallow slice creates a shallow snapshot
          List docsSnapshot = List.from(docs);

          // we slice first cause' if there're allChangeEvents that are of the same id after this change, we don't want to involve it for it is unexpected invalid order
          List<SingleDocChange> docChanges = allChangeEvents.sublist(0, i + 1);
          docChanges.retainWhere((doc) => doc.id == change.id);

          // all changes of this event has been handle, we could dispatch the event now
          this._sessionInfo!.currentEventId = change.id;
          this._sessionInfo!.currentDocs = docs;

          Snapshot snapshot = Snapshot(
            id: change.id,
            docChanges: docChanges,
            docs: docsSnapshot,
            msgType: msgType,
          );
          this.listener?.onChange?.call(snapshot);
        }
      } else {
        // out-of-order event
        Console.warn(
            '[realtime listener] event received is out of order, cur ${this._sessionInfo!.currentEventId} but got ${change.id}');
        // rebuild watch
        await this._rebuildWatch();
        return;
      }
    }
  }

  void _postHandleServerEventsValidityCheck(Map msg) {
    if (this._sessionInfo == null) {
      Console.error(
          '[realtime listener] internal non-fatal error: sessionInfo lost after server event handling, this should never occur');
      return;
    }

    if (this._sessionInfo!.expectEventId != null &&
        this._sessionInfo!.currentEventId >=
            this._sessionInfo!.expectEventId!) {
      this._clearWaitExpectedEvent();
    }

    if (this._sessionInfo!.currentEventId < msg['msgData']['currEvent']) {
      Console.warn(
          '[realtime listener] internal non-fatal error: client eventId does not match with server event id after server event handling');
      return;
    }
  }

  void _clearWaitExpectedEvent() {
    if (this._waitExpectedTimer != null) {
      this._waitExpectedTimer!.cancel();
      this._waitExpectedTimer = null;
    }
  }

  void onMessage(msg) {
    // watchStatus sanity check
    switch (this._watchStatus) {
      case WATCH_STATUS.PAUSED:
        {
          // ignore all but error message
          if (msg['msgType'] != 'ERROR') {
            return;
          }
          break;
        }
      case WATCH_STATUS.LOGGINGIN:
      case WATCH_STATUS.INITING:
      case WATCH_STATUS.REBUILDING:
        {
          Console.warn(
              '[realtime listener] internal non-fatal error: unexpected message received while ${this._watchStatus}');
          return;
        }
      case WATCH_STATUS.CLOSED:
        {
          Console.warn(
              '[realtime listener] internal non-fatal error: unexpected message received when the watch has closed');
          return;
        }
      case WATCH_STATUS.ERRORED:
        {
          Console.warn(
              '[realtime listener] internal non-fatal error: unexpected message received when the watch has ended with error');
          return;
        }
      default:
        break;
    }

    if (this._sessionInfo == null) {
      Console.warn(
          '[realtime listener] internal non-fatal error: sessionInfo not found while message is received.');
      return;
    }

    this._scheduleSendACK();

    switch (msg['msgType']) {
      case 'NEXT_EVENT':
        {
//        Console.warn('nextevent ${msg['msgData']['currEvent']} ignored, msg: $msg}');
          this._handleServerEvents(msg);
          break;
        }
      case 'CHECK_EVENT':
        {
          if (this._sessionInfo!.currentEventId < msg['msgData']['currEvent']) {
            // client eventID < server eventID:
            // there might be one or more pending events not yet received but sent by the server
            this._sessionInfo!.expectEventId = msg['msgData']['currEvent'];
            this._clearWaitExpectedEvent();
            this._waitExpectedTimer = Timer(
                Duration(
                    milliseconds: this._getWaitExpectedTimeoutLength().toInt()),
                () {
              // must rebuild watch
              this._rebuildWatch();
            });

            Console.log(
                '[realtime] waitExpectedTimeoutLength ${this._getWaitExpectedTimeoutLength()}');
          }
          break;
        }
      case 'ERROR':
        {
          // receive server error
          this.closeWithError(CloudBaseException(
              code: ErrCode.SDK_DATABASE_REALTIME_LISTENER_SERVER_ERROR_MSG,
              message:
                  '${msg['msgData']['code']} - ${msg['msgData']['message']}'));
          break;
        }
      default:
        {
          Console.warn(
              '[realtime listener] virtual client receive unexpected msg: $msg');
          break;
        }
    }
  }

  void closeWithError(error) {
    this._watchStatus = WATCH_STATUS.ERRORED;
    this._clearACKSchedule();
    this.listener?.onError?.call(error);
    String queryID =
        this._sessionInfo?.queryID != null ? this._sessionInfo!.queryID! : '';
    this._onWatchClose(this, queryID);

    Console.log(
        '[realtime] client closed (${this._collectionName} ${this._query}) (watchId ${this.watchId})');
  }

  void pause() {
    this._watchStatus = WATCH_STATUS.PAUSED;

    Console.log(
        '[realtime] client paused (${this._collectionName} ${this._query}) (watchId ${this.watchId})');
  }

  Future<void> resume() async {
    this._watchStatus = WATCH_STATUS.RESUMING;

    Console.log(
        '[realtime] client resuming with ${this._sessionInfo != null ? 'REBUILD_WATCH' : 'INIT_WATCH'} (${this._collectionName} ${this._query}) (${this.watchId})');

    try {
      if (this._sessionInfo != null) {
        await this._rebuildWatch();
      } else {
        await this._initWatch();
      }
    } catch (e) {
      Console.error(
          '[realtime] client resume failed (${this._collectionName} ${this._query}) (${this.watchId}), error: ${e.toString()}');
    }
  }
}
