/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

class RegExp {
  String regexp;
  String? options;

  RegExp(this.regexp, [this.options]);

  Map<String, dynamic> toJson() {
    var json = {'\$regex': regexp};

    if (this.options != null) {
      json['\$options'] = options!;
    }

    return json;
  }
}
