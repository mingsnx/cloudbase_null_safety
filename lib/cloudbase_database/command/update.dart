/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import '../serializer.dart';

class UpdateCommandsLiteral {
  static const SET = 'set';
  static const REMOVE = 'remove';
  static const INC = 'inc';
  static const MUL = 'mul';
  static const PUSH = 'push';
  static const PULL = 'pull';
  static const PULL_ALL = 'pullAll';
  static const POP = 'pop';
  static const SHIFT = 'shift';
  static const UNSHIFT = 'unshift';
  static const ADD_TO_SET = 'addToSet';
  static const BIT = 'bit';
  static const RENAME = 'rename';
  static const MAX = 'max';
  static const MIN = 'min';
}

class UpdateCommand {
  dynamic actions;

  UpdateCommand(this.actions, step) {
    if (step is List && step.length > 0) {
      actions.add(step);
    }
  }

  dynamic toJson() {
    return {'_actions': Serializer.encode(actions)};
  }
}
