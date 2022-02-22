/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'dart:async';
import 'dart:convert';

import 'package:cloudbase_null_safety/cloudbase_core/base.dart';
import 'package:cloudbase_null_safety/cloudbase_core/exception.dart';
import 'package:cloudbase_null_safety/cloudbase_database/config/error_config.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/error.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/message.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/utils.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/virtual_websocket_client.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/ws_channel.dart';
import 'package:cloudbase_null_safety/cloudbase_database/realtime/ws_event.dart';

class LoginInfo {
  bool loggedIn;
  Future<LoginResult>? loggingInPromise;
  DateTime? loginStartDT;
  LoginResult? loginResult;

  LoginInfo(
      {required this.loggedIn,
      this.loggingInPromise,
      this.loginStartDT,
      this.loginResult});
}

class LoginResult {
  String envId;

  LoginResult({required this.envId});
}

class ResponseWaitSpec {
  late Function resolve;
  late Function reject;
  late bool skipOnMessage;

  ResponseWaitSpec(
      {required this.resolve,
      required this.reject,
      required this.skipOnMessage});
}

typedef Future<Map> GetAccessTokenFunc();

const MAX_RTT_OBSERVED = 3;
const DEFAULT_EXPECTED_EVENT_WAIT_TIME = 5000;
const DEFAULT_UNTRUSTED_RTT_THRESHOLD = 10000;
const DEFAULT_MAX_RECONNECT = 5;
const DEFAULT_WS_RECONNECT_INTERVAL = 10000;
const DEFAULT_PING_FAIL_TOLERANCE = 2;
const DEFAULT_PONG_MISS_TOLERANCE = 2;
const DEFAULT_LOGIN_TIMEOUT = 5000;

class RealtimeWebSocketClient {
  List<VirtualWebSocketClient?> _virtualWSClient = [];
  Map<String, VirtualWebSocketClient> _queryIdClientMap = {};
  Map<String, VirtualWebSocketClient> _watchIdClientMap = {};
  late int _maxReconnect;
  late int _reconnectInterval;
  WSChannel? _ws;
  DateTime? _lastPingSendDT;
  int _pingFailed = 0;
  int _pongMissed = 0;
  Timer? _pingTimer;
  Timer? _pongTimer;
  Map<String, LoginInfo> _logins = {};
  Future<void>? _wsInitPromise;
  List<Completer> _wsReadySubscribers = [];
  Map<String, ResponseWaitSpec> _wsResponseWait = {};
  List<int> _rttObserved = [];
  bool _reconnectState = false;
  // appConfig
  late int _realtimePingInterval;
  late int _realtimePongWaitTimeout;
  late GetAccessTokenFunc _getAccessToken;

  RealtimeWebSocketClient({
    int maxReconnect = DEFAULT_MAX_RECONNECT,
    int reconnectInterval = DEFAULT_WS_RECONNECT_INTERVAL,
    required int realtimePingInterval,
    required int realtimePongWaitTimeout,
    required GetAccessTokenFunc getAccessToken,
  }) {
    this._maxReconnect = maxReconnect;
    this._reconnectInterval = reconnectInterval;
    this._realtimePingInterval = reconnectInterval;
    this._realtimePongWaitTimeout = realtimePongWaitTimeout;
    this._getAccessToken = getAccessToken;
  }
  static RealtimeWebSocketClient? _client;

  factory RealtimeWebSocketClient.getInstance(CloudBaseCore core) {
    if (_client == null) {
      _client = RealtimeWebSocketClient(
        realtimePingInterval: 10000,
        realtimePongWaitTimeout: 5000,
        getAccessToken: () async {
          assert(core.auth != null, "not auth cloudbase");
          String accessToken = await core.auth!.getAccessToken();
          return {'envId': core.config.envId, 'accessToken': accessToken};
        },
      );
    }

    return _client!;
  }

  Future<void> _initWebSocketConnection({
    bool reconnect = false,
    int availableRetries = 0,
  }) async {
    // 当前处于正在重连中的状态
    if (reconnect && this._reconnectState) {
      return; // 忽略
    }

    if (reconnect) {
      this._reconnectState = true; // 重连状态开始
    }

    if (this._wsInitPromise != null) {
      return this._wsInitPromise;
    }

    if (reconnect) {
      this.pauseClients();
    }

    this.close(CloseEventCode.ReconnectWebSocket);

    Completer completer = Completer();
    // 异步执行ws init 逻辑
    this._internalInitWebSocketConnection(
        reconnect: reconnect,
        availableRetries: availableRetries,
        completer: completer);
    this._wsInitPromise = completer.future;

    try {
      await this._wsInitPromise;
      this._wsReadySubscribers.forEach((subscriber) {
        subscriber.complete();
      });
    } catch (e) {
      this._wsReadySubscribers.forEach((subscriber) {
        subscriber.completeError(e);
      });
    } finally {
      this._wsInitPromise = null;
      this._wsReadySubscribers = [];
    }
  }

  void _internalInitWebSocketConnection({
    bool reconnect = false,
    int availableRetries = 0,
    required Completer completer,
  }) async {
    try {
      this._getAccessToken();

      String url = 'wss://tcb-ws.tencentcloudapi.com';
      this._ws = WSChannel(url);
      await this._initWebSocketEvent();

      completer.complete();

      if (reconnect) {
        this.resumeClients();
        this._reconnectState = false; // 重连状态结束
      }
    } catch (e) {
      Console.error(
          '[realtime] initWebSocketConnection connect fail, error: ${e.toString()}');

      if (availableRetries > 0) {
        bool isConnected = true;

        this._wsInitPromise = null;

        if (isConnected) {
          await Future.delayed(
              Duration(milliseconds: this._reconnectInterval.toInt()));
          if (reconnect) {
            this._reconnectState = false; // 重连异常也算重连状态结束
          }
        }

        completer.complete(this._initWebSocketConnection(
            reconnect: reconnect, availableRetries: availableRetries));
      } else {
        completer.completeError(e);

        if (reconnect) {
          this.closeAllClients(CloudBaseException(
              code: ErrCode.SDK_DATABASE_REALTIME_LISTENER_RECONNECT_WATCH_FAIL,
              message: e.toString()));
        }
      }
    }
  }

  Future<void> _initWebSocketEvent() async {
    if (this._ws == null) {
      throw 'can not initWebSocketEvent, ws not exists';
    }

    Completer completer = Completer();
    bool wsOpened = false;

    var onOpen = () {
      Console.warn('[realtime] ws event: open');
      wsOpened = true;
      completer.complete();
    };

    var onError = (error) {
      this._logins = {};
      if (!wsOpened) {
        Console.error('[realtime] ws open failed with ws event: error $error');
        completer.completeError(error);
      } else {
        Console.error('[realtime] ws event: error $error');
        this._clearHeartbeat();
        this._virtualWSClient.forEach((client) {
          client?.closeWithError(CloudBaseException(
              code: ErrCode
                  .SDK_DATABASE_REALTIME_LISTENER_WEBSOCKET_CONNECTION_ERROR,
              message: error.toString()));
        });
      }
    };

    var onClose = (int code, String reason) {
      Console.warn('[realtime] ws event: close $code $reason');

      this._logins = {};
      this._clearHeartbeat();
      switch (code) {
        case CloseEventCode.ReconnectWebSocket:
          {
            // just ignore
            break;
          }
        case CloseEventCode.NoRealtimeListeners:
          {
            // quit
            break;
          }
        case CloseEventCode.HeartbeatPingError:
        case CloseEventCode.HeartbeatPongTimeoutError:
        case CloseEventCode.NormalClosure:
        case CloseEventCode.AbnormalClosure:
          {
            // Normal Closure and Abnormal Closure:
            //   expected closure, most likely dispatched by wechat client,
            //   since this is the status code dispatched in case of network failure,
            //   we should retry

            if (this._maxReconnect > 0) {
              this._initWebSocketConnection(
                  reconnect: true, availableRetries: this._maxReconnect);
            } else {
              this.closeAllClients(getWSCloseError(code, reason));
            }
            break;
          }
        case CloseEventCode.NoAuthentication:
          {
            this.closeAllClients(getWSCloseError(code, reason));
            break;
          }
        default:
          {
            // we should retry by default
            if (this._maxReconnect > 0) {
              this._initWebSocketConnection(
                  reconnect: true, availableRetries: this._maxReconnect);
            } else {
              this.closeAllClients(getWSCloseError(code, reason));
            }
          }
      }
    };

    var onMessage = (String rawMsg) {
      this._heartbeat();

      Map msg;
      try {
        msg = jsonDecode(rawMsg);
      } catch (e) {
        throw '[realtime] onMessage parse res.data error: ${e.toString()}';
      }

      String msgType = msg['msgType'];
      String requestId = msg['requestId'];
      String? watchId = msg['watchId'];

      if (msgType == 'ERROR') {
        // 找到当前监听，并将error返回
        VirtualWebSocketClient? virtualWatch = this
            ._virtualWSClient
            .firstWhere((item) => (item?.watchId == watchId));
        if (virtualWatch != null) {
          if (virtualWatch.listener!.onError != null) {
            virtualWatch.listener!.onError!(msg); // todo
          }
        }
      }

      var responseWaitSpec = this._wsResponseWait[requestId];
      if (responseWaitSpec != null) {
        try {
          if (msgType == 'ERROR') {
            responseWaitSpec
                .reject(RealtimeErrorMessageException(serverErrorMsg: msg));
          } else {
            responseWaitSpec.resolve(msg);
          }
        } catch (e) {
          Console.error(
              'ws onMessage responseWaitSpec.resolve(msg) errored: ${e.toString()}');
        } finally {
          this._wsResponseWait.remove(requestId);
        }
        if (responseWaitSpec.skipOnMessage) {
          return;
        }
      }

      if (msgType == 'PONG') {
        if (this._lastPingSendDT != null) {
          int rtt = DateTime.now().millisecondsSinceEpoch -
              this._lastPingSendDT!.millisecondsSinceEpoch;
          if (rtt > DEFAULT_UNTRUSTED_RTT_THRESHOLD) {
            Console.warn('[realtime] untrusted rtt observed: $rtt');
            return;
          }
          if (this._rttObserved.length >= MAX_RTT_OBSERVED) {
            this._rttObserved.removeRange(
                0, this._rttObserved.length - MAX_RTT_OBSERVED + 1);
            this._rttObserved.add(rtt);
          }
        }
        return;
      }

      VirtualWebSocketClient? client =
          watchId != null ? this._watchIdClientMap[watchId] : null;
      if (client != null) {
        client.onMessage(msg);
      } else {
        Console.error(
            '[realtime] no realtime listener found responsible for watchId $watchId: $msg');
        switch (msgType) {
          case 'INIT_EVENT':
          case 'NEXT_EVENT':
          case 'CHECK_EVENT':
            {
              client = this._queryIdClientMap[msg['msgData']['queryID']];
              if (client != null) {
                client.onMessage(msg);
              }
              break;
            }
          default:
            {
              this._watchIdClientMap.forEach((watchId, client) {
                client.onMessage(msg);
              });
              break;
            }
        }
      }
    };

    await this._ws?.setCallback(onOpen, onError, onClose, onMessage);

    this._heartbeat();
  }

  bool _isWSConnected() {
    return this._ws?.readyState == WS_READY_STATUS.OPEN;
  }

  Future<void> _onceWSConnected() {
    if (this._isWSConnected()) {
      return Future(() {});
    }

    if (this._wsInitPromise != null) {
      return this._wsInitPromise!;
    }

    Completer completer = Completer();
    this._wsReadySubscribers.add(completer);

    return completer.future;
  }

  Future<LoginResult> _webLogin({
    String? envId = '',
    bool? refresh = false,
  }) async {
    if (refresh != true) {
      if (this._logins.containsKey(envId)) {
        LoginInfo? loginInfo = this._logins[envId];
        if (loginInfo != null) {
          if (loginInfo.loggedIn && loginInfo.loginResult != null) {
            return loginInfo.loginResult!;
          } else if (loginInfo.loggingInPromise != null) {
            return loginInfo.loggingInPromise!;
          }
        }
      }
    }

    Completer<LoginResult> completer = Completer();
    this._internalWebLogin(completer);

    LoginInfo? loginInfo = this._logins[envId];
    DateTime loginStartDT = DateTime.now();

    if (loginInfo != null) {
      loginInfo.loggedIn = false;
      loginInfo.loggingInPromise = completer.future;
      loginInfo.loginStartDT = loginStartDT;
    } else {
      loginInfo = LoginInfo(
          loggedIn: false,
          loggingInPromise: completer.future,
          loginStartDT: loginStartDT);
      this._logins[envId!] = loginInfo;
    }

    try {
      LoginResult loginResult = await completer.future;
      LoginInfo? curLoginInfo = this._logins[envId];
      if (curLoginInfo != null &&
          curLoginInfo == loginInfo &&
          curLoginInfo.loginStartDT?.compareTo(loginStartDT) == 0) {
        loginInfo.loggedIn = true;
        loginInfo.loggingInPromise = null;
        loginInfo.loginStartDT = null;
        loginInfo.loginResult = loginResult;
        return loginResult;
      } else if (curLoginInfo != null) {
        if (curLoginInfo.loggedIn && curLoginInfo.loginResult != null) {
          return curLoginInfo.loginResult!;
        } else if (curLoginInfo.loggingInPromise != null) {
          return curLoginInfo.loggingInPromise!;
        } else {
          throw 'ws unexpected login info';
        }
      } else {
        throw 'ws login info reset';
      }
    } catch (e) {
      loginInfo.loggedIn = false;
      loginInfo.loggingInPromise = null;
      loginInfo.loginStartDT = null;
      loginInfo.loginResult = null;
      throw e;
    }
  }

  void _internalWebLogin(Completer completer) async {
    try {
      var accessTokenRes = await this._getAccessToken();
      var msgData = {
        'envId': accessTokenRes['envId'] != null ? accessTokenRes['envId'] : '',
        'accessToken': accessTokenRes['accessToken'],
        'referrer': 'web',
        'sdkVersion': '',
        'dataVersion': Message.DATA_VERSION
      };
      var loginMsg = {
        'requestId': Message.genRequestId(),
        'msgType': 'LOGIN',
        'msgData': msgData
      };
      var loginResMsg = await this.send(
          msg: loginMsg,
          waitResponse: true,
          skipOnMessage: true,
          timeout: DEFAULT_LOGIN_TIMEOUT);

      if (loginResMsg?['msgData']?['code'] == null) {
        completer.complete(LoginResult(envId: accessTokenRes['envId']));
      } else {
        completer.completeError(CloudBaseException(
            code: loginResMsg?['msgData']['code'],
            message: loginResMsg?['msgData']['message']));
      }
    } catch (error) {
      completer.completeError(error);
    }
  }

  num _getWaitExpectedTimeoutLength() {
    if (this._rttObserved.length <= 0) {
      return DEFAULT_EXPECTED_EVENT_WAIT_TIME;
    }

    // 1.5 * RTT
    return 1.5 *
        (this._rttObserved.reduce((acc, cur) => acc + cur) /
            this._rttObserved.length);
  }

  _heartbeat([bool immediate = false]) {
    this._clearHeartbeat();
    this._pingTimer = Timer(
        Duration(
            milliseconds: immediate ? 0 : this._realtimePingInterval.toInt()),
        () async {
      try {
        if (this._ws?.readyState != WS_READY_STATUS.OPEN) {
          return;
        }

        this._lastPingSendDT = DateTime.now();
        await this._ping();
        this._pingFailed = 0;

        this._pongTimer = Timer(
            Duration(milliseconds: this._realtimePongWaitTimeout.toInt()), () {
          Console.error('pong timed out');
          if (this._pongMissed < DEFAULT_PONG_MISS_TOLERANCE) {
            this._pongMissed++;
            this._heartbeat();
          } else {
            // logical perceived connection lost, even though websocket did not receive error or close event
            this._initWebSocketConnection(reconnect: true);
          }
        });
      } catch (e) {
        if (this._pingFailed < DEFAULT_PING_FAIL_TOLERANCE) {
          this._pingFailed++;
          this._heartbeat();
        } else {
          this.close(CloseEventCode.HeartbeatPingError);
        }
      }
    });
  }

  _clearHeartbeat() {
    this._pingTimer?.cancel();
    this._pongTimer?.cancel();
  }

  _ping() async {
    var msg = {
      'requestId': Message.genRequestId(),
      'msgType': 'PING',
    };
    await this.send(msg: msg);
  }

  Future<Map?> send({
    required Map msg,
    bool waitResponse = false,
    bool skipOnMessage = false,
    int? timeout,
  }) {
    Completer<Map?> completer = Completer();
    this._send(
      msg: msg,
      waitResponse: waitResponse,
      skipOnMessage: skipOnMessage,
      timeout: timeout,
      completer: completer,
    );
    return completer.future;
  }

  void _send({
    required Map msg,
    required bool waitResponse,
    required bool skipOnMessage,
    int? timeout,
    required Completer<Map?> completer,
  }) async {
    Timer? timer;
    bool hasResolved = false;
    bool hasRejected = false;

    var resolve = ([Map? value]) {
      hasResolved = true;
      if (timer != null) {
        timer.cancel();
      }
      completer.complete(value);
    };

    var reject = (error) {
      hasRejected = true;
      if (timer != null) {
        timer.cancel();
      }
      completer.completeError(error);
    };

    if (timeout != null) {
      timer = Timer(Duration(milliseconds: timeout.toInt()), () async {
        if (!hasResolved || !hasRejected) {
          // wait another immediate timeout to allow the success/fail callback to be invoked if ws has already got the result,
          // this is because the timer is registered before ws.send
          await Future.delayed(Duration(milliseconds: 3000));
          if (!hasResolved || !hasRejected) {
            reject('wsclient.send timeout');
          }
        }
      });
    }

    try {
      if (this._wsInitPromise != null) {
        await this._wsInitPromise;
      }

      if (this._ws == null) {
        throw 'invalid state: ws connection not exists, can not send message';
      }

      if (this._ws!.readyState != WS_READY_STATUS.OPEN) {
        throw 'ws readyState invalid: ${this._ws!.readyState}, can not send message';
      }

      if (waitResponse) {
        String requestId = msg['requestId'];
        this._wsResponseWait[requestId] = ResponseWaitSpec(
            resolve: resolve, reject: reject, skipOnMessage: skipOnMessage);
      }

      try {
        this._ws!.send(msg);
        if (!waitResponse) {
          resolve();
        }
      } catch (error) {
        reject(error);
        if (waitResponse) {
          String requestId = msg['requestId'];
          this._wsResponseWait.remove(requestId);
        }
      }
    } catch (e) {
      reject(e);
    }
  }

  void close(num code) {
    this._clearHeartbeat();

    if (this._ws != null) {
      this._ws!.close(code.toInt(), CloseEventCodeInfo[code]?.name);
      this._ws = null;
    }
  }

  void closeAllClients(error) {
    this._virtualWSClient.forEach((client) {
      client?.closeWithError(error);
    });
  }

  void pauseClients([List<VirtualWebSocketClient>? clients]) {
    var _clients = clients == null ? this._virtualWSClient : clients;
    _clients.forEach((client) {
      client?.pause();
    });
  }

  void resumeClients([List<VirtualWebSocketClient>? clients]) {
    var _clients = clients == null ? this._virtualWSClient : clients;
    _clients.forEach((client) {
      client?.resume();
    });
  }

  void _onWatchStart(VirtualWebSocketClient client, String queryID) {
    this._queryIdClientMap[queryID] = client;
  }

  void _onWatchClose(VirtualWebSocketClient client, String? queryID) {
    if (queryID != null) {
      this._queryIdClientMap.remove(queryID);
    }
    this._watchIdClientMap.remove(client.watchId);
    this._virtualWSClient.remove(client);

    if (this._virtualWSClient.length > 0) {
      this.close(CloseEventCode.NoRealtimeListeners);
    }
  }

  watch({
    String? envId,
    String? collectionName,
    String? query,
    int? limit,
    Map<String, String>? orderBy,
    Function? onChange,
    Function? onError,
  }) {
    if (this._ws == null && this._wsInitPromise == null) {
      this._initWebSocketConnection(reconnect: false);
    }

    var virtualClient = VirtualWebSocketClient(
      envId: envId,
      collectionName: collectionName,
      query: query,
      limit: limit,
      orderBy: orderBy,
      send: this.send,
      login: this._webLogin,
      isWSConnected: this._isWSConnected,
      onceWSConnected: this._onceWSConnected,
      getWaitExpectedTimeoutLength: this._getWaitExpectedTimeoutLength,
      onWatchStart: this._onWatchStart,
      onWatchClose: this._onWatchClose,
      debug: true,
      onChange: onChange,
      onError: onError,
    );
    this._virtualWSClient.add(virtualClient);
    this._watchIdClientMap[virtualClient.watchId] = virtualClient;
    return virtualClient.listener;
  }
}
