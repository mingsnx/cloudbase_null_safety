/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import 'package:cloudbase_null_safety/cloudbase_core/exception.dart';
import 'package:cloudbase_null_safety/cloudbase_database/config/error_config.dart';

class CloseEventInfo {
  num code;
  String name;
  String description;

  CloseEventInfo({
    required this.code,
    required this.name,
    required this.description,
  });
}

Map<num, CloseEventInfo> CloseEventCodeInfo = {
  1000: CloseEventInfo(
      code: 1000,
      name: 'Normal Closure',
      description:
          'Normal closure; the connection successfully completed whatever purpose for which it was created.'),
  1001: CloseEventInfo(
      code: 1001,
      name: 'Going Away',
      description:
          'The endpoint is going away, either because of a server failure or because the browser is navigating away from the page that opened the connection.'),
  1002: CloseEventInfo(
      code: 1002,
      name: 'Protocol Error',
      description:
          'The endpoint is terminating the connection due to a protocol error.'),
  1003: CloseEventInfo(
      code: 1003,
      name: 'Unsupported Data',
      description:
          'The connection is being terminated because the endpoint received data of a type it cannot accept (for example, a text-only endpoint received binary data).'),
  1005: CloseEventInfo(
      code: 1005,
      name: 'No Status Received',
      description:
          'Indicates that no status code was provided even though one was expected.'),
  1006: CloseEventInfo(
      code: 1006,
      name: 'Abnormal Closure',
      description:
          'Used to indicate that a connection was closed abnormally (that is, with no close frame being sent) when a status code is expected.'),
  1007: CloseEventInfo(
      code: 1007,
      name: 'Invalid frame payload data',
      description:
          'The endpoint is terminating the connection because a message was received that contained inconsistent data (e.g., non-UTF-8 data within a text message).'),
  1008: CloseEventInfo(
      code: 1008,
      name: 'Policy Violation',
      description:
          'The endpoint is terminating the connection because it received a message that violates its policy. This is a generic status code, used when codes 1003 and 1009 are not suitable.'),
  1009: CloseEventInfo(
      code: 1009,
      name: 'Message too big',
      description:
          'The endpoint is terminating the connection because a data frame was received that is too large.'),
  1010: CloseEventInfo(
      code: 1010,
      name: 'Missing Extension',
      description:
          "The client is terminating the connection because it expected the server to negotiate one or more extension, but the server didn't."),
  1011: CloseEventInfo(
      code: 1011,
      name: 'Internal Error',
      description:
          'The server is terminating the connection because it encountered an unexpected condition that prevented it from fulfilling the request.'),
  1012: CloseEventInfo(
      code: 1012,
      name: 'Service Restart',
      description:
          'The server is terminating the connection because it is restarting.'),
  1013: CloseEventInfo(
      code: 1013,
      name: 'Try Again Later',
      description:
          'The server is terminating the connection due to a temporary condition, e.g. it is overloaded and is casting off some of its clients.'),
  1014: CloseEventInfo(
      code: 1014,
      name: 'Bad Gateway',
      description:
          'The server was acting as a gateway or proxy and received an invalid response from the upstream server. This is similar to 502 HTTP Status Code.'),
  1015: CloseEventInfo(
      code: 1015,
      name: 'TLS Handshake',
      description:
          "Indicates that the connection was closed due to a failure to perform a TLS handshake (e.g., the server certificate can't be verified)."),
  // custom
  3000: CloseEventInfo(
      code: 3000,
      name: 'Reconnect WebSocket',
      description:
          'The client is terminating the connection because it wants to reconnect'),
  3001: CloseEventInfo(
      code: 3001,
      name: 'No Realtime Listeners',
      description:
          'The client is terminating the connection because no more realtime listeners exist'),
  3002: CloseEventInfo(
      code: 3002,
      name: 'Heartbeat Ping Error',
      description:
          'The client is terminating the connection due to its failure in sending heartbeat messages'),
  3003: CloseEventInfo(
      code: 3003,
      name: 'Heartbeat Pong Timeout Error',
      description:
          'The client is terminating the connection because no heartbeat response is received from the server'),
  3050: CloseEventInfo(
      code: 3050,
      name: 'Server Close',
      description:
          'The client is terminating the connection because no heartbeat response is received from the server')
};

class CloseEventCode {
  // spec
  static const int NormalClosure = 1000;
  static const int GoingAway = 1001;
  static const int ProtocolError = 1002;
  static const int UnsupportedData = 1003;
  static const int NoStatusReceived = 1005;
  static const int AbnormalClosure = 1006;
  static const int InvalidFramePayloadData = 1007;
  static const int PolicyViolation = 1008;
  static const int MessageTooBig = 1009;
  static const int MissingExtension = 1010;
  static const int InternalError = 1011;
  static const int ServiceRestart = 1012;
  static const int TryAgainLater = 1013;
  static const int BadGateway = 1014;
  static const int TLSHandshake = 1015;
  // custom - client close itself
  static const int ReconnectWebSocket = 3000;
  static const int NoRealtimeListeners = 3001;
  static const int HeartbeatPingError = 3002;
  static const int HeartbeatPongTimeoutError = 3003;
  // custom - server close
  static const int NoAuthentication = 3050;
}

CloudBaseException getWSCloseError(int code, String? reason) {
  CloseEventInfo? info = CloseEventCodeInfo[code];
  String errMsg = info == null
      ? 'code $code'
      : '${info.name}, code $code, reason ${reason != null ? reason : info.description}';

  return CloudBaseException(
    code: ErrCode.SDK_DATABASE_REALTIME_LISTENER_WEBSOCKET_CONNECTION_CLOSED,
    message: errMsg,
  );
}
