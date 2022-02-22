/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

class ServerDate {
  num? offset;

  ServerDate([this.offset]);

  Map toJson() {
    return {
      '\$date': {'offset': offset == null ? 0 : offset}
    };
  }
}
