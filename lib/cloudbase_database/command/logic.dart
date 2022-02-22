/// orgin pub package: https://pub.dev/packages/cloudbase_database
/// author: https://cloudbase.net/ & lirongcong.bennett@gmail.com

import '../serializer.dart';

class LogicCommandLiteral {
  static const AND = 'and';
  static const OR = 'or';
  static const NOT = 'not';
  static const NOR = 'nor';
}

class LogicCommand {
  dynamic actions;

  LogicCommand(this.actions, step) {
    if (step is List && step.length > 0) {
      actions.add(step);
    }
  }

  dynamic toJson() {
    return {'_actions': Serializer.encode(actions)};
  }

  LogicCommand and(dynamic expressions) {
    return logicOP(LogicCommandLiteral.AND, expressions);
  }

  LogicCommand or(dynamic expressions) {
    return logicOP(LogicCommandLiteral.AND, expressions);
  }

  LogicCommand logicOP(String cmd, dynamic expressions) {
    expressions = (expressions is List) ? expressions : [expressions];

    var args = [];
    args.add('\$$cmd');
    args.addAll(expressions);

    return LogicCommand(actions, args);
  }
}
