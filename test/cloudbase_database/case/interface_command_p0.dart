/*
	command_eq
	command_neq
	command_lt
	command_lte
	command_gt
	command_gte
	command_in
	command_nin
	command_and
  command_or

  command_set
	command_remove
	command_inc
	command_mul
	command_push
	command_pop
	command_shift
  command_unshift

*/

var cases_data = {

  'name': 'interface_command_p0集合',
  'cases': [

    {
      'desc': 'collection_clean清理掉所有的集合数据。',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_clean',
        'collection_name': 'doc_wcc',
      },
    },

    {
      'desc': 'collection_count检查所有集合数据量',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': "collection_count",
        'collection_name': 'doc_wcc',
      },
      'expect': (res) => res.total == 0
    },

    {
      'desc': 'collection_add插入第一条数据记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'data': {
          '_id': "W_0Cuc6YbCHWYMcK01",     //指定ID
          'string01': "auto test!",
          'number02': 36000,
          'object03': { 'test': "hello!", 'temp': "OK" },
          'array04': ["one", "two"],
          'bool05': true,
          'null06': null
        },
      },
      'output': {
        'id': "{{{id}}}"
      },
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK01'
    },
    {
      'desc': 'collection_add插入第二条数据记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'data': {
          '_id': "W_0Cuc6YbCHWYMcK02",     //指定ID
          'string01': "auto test02!",
          'number02': 25000,
          'object03': { 'test': "hello baby!", 'temp': "SOLO" },
          'array04': [1, 2],
          'bool05': false,
          'null06': null
        },
      },
      'expect': (res) => res.id == 'W_0Cuc6YbCHWYMcK02'
    },

    {
      'desc': 'command_eq判断字段是否等于指定值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_eq',
        'collection_name': 'doc_wcc',
        'eq_key': "number02",
        'eq_value': 36000
      },
      'expect': (res) => res.data[0]['number02'] == 36000
    },

    {
      'desc': 'command_neq判断字段是否不等于指定值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_neq',
        'collection_name': 'doc_wcc',
        'neq_key': "number02",
        'neq_value': 36000
      },
      'expect': (res) => res.data[0]['number02'] != 36000
    },

    {
      'desc': 'command_lt判断字段是否小于指定值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_lt',
        'collection_name': 'doc_wcc',
        'lt_key': "number02",
        'lt_value': 36000
      },
      'expect': (res) => res.data[0]['number02'] < 36000
    },

    {
      'desc': 'command_lte判断字段是否小于或等于指定值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_lte',
        'collection_name': 'doc_wcc',
        'lte_key': "number02",
        'lte_value': 36000
      },
      'expect': (res) => res.data.length == 2
    },

    {
      'desc': 'command_gt判断字段是否大于指定值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_gt',
        'collection_name': 'doc_wcc',
        'gt_key': "number02",
        'gt_value': 30000
      },
      'expect': (res) => res.data[0]['number02'] > 30000
    },

    {
      'desc': 'command_gte判断字段是否大于或等于指定值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_gte',
        'collection_name': 'doc_wcc',
        'gte_key': "number02",
        'gte_value': 25000
      },
      'expect': (res) => res.data.length == 2
    },

    {
      'desc': 'command_in判断字段值是否在指定数组中',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_in',
        'collection_name': 'doc_wcc',
        'in_key': "number02",
        'in_value': [4000, 36000]
      },
      'expect': (res) => res.data[0]['number02'] == 36000
    },

    {
      'desc': 'command_nin判断字段值是否不在指定数组中',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_nin',
        'collection_name': 'doc_wcc',
        'nin_key': "number02",
        'nin_value': [4000, 36000]
      },
      'expect': (res) => res.data[0]['number02'] == 25000
    },

    {
      'desc': 'command_and条件与，表示需同时满足另一个条件',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_and',
        'collection_name': 'doc_wcc',
        'and_key': "number02",
        'and_value0': 20000,
        'and_value1': 30000
      },
      'expect': (res) => res.data[0]['number02'] == 25000
    },

    {
      'desc': 'command_or条件或，表示需满足其中一个条件',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_or',
        'collection_name': 'doc_wcc',
        'or_key': "number02",
        'or_value0': 34000,
        'or_value1': 28000
      },
      'expect': (res) => res.data.length == 2
    },

    {
      'desc': 'command_set设置字段为指定值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_set',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK01',
        'set_key': "object03",
        'set_value': { 'test''': 'success' }
      },
      'expect': (res) => res.updated == 1
    },
    {
      'desc': '验证command_set设置字段准确',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_get',
        'collection_name': 'doc_wcc',
        'doc_id': "W_0Cuc6YbCHWYMcK01",

      },
      'expect': (res) => res.data[0]['object03']['test'] == 'success' && res.data[0]['object03']['temp'] == null
    },

    {
      'desc': 'command_remove删除字段',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_remove',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK01',
        'remove_key': "object03",
      },
      'expect': (res) => res.updated == 1
    },
    {
      'desc': '验证command_remove删除字段准确',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_get',
        'collection_name': 'doc_wcc',
        'doc_id': "W_0Cuc6YbCHWYMcK01",
      },
      'expect': (res) => res.data[0]['object03'] == null
    },

    {
      'desc': 'command_inc原子自增字段值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_inc',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK01',
        'inc_key': "number02",
        'inc_value': 4000
      },
      'expect': (res) => res.updated == 1
    },
    {
      'desc': '验证command_inc自增数据准确',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_get',
        'collection_name': 'doc_wcc',
        'doc_id': "W_0Cuc6YbCHWYMcK01",
      },
      'expect': (res) => res.data[0]['number02'] == 40000
    },

    {
      'desc': 'command_mul原子自乘字段值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_mul',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK01',
        'mul_key': "number02",
        'mul_value': 4000
      },
      'expect': (res) => res.updated == 1
    },
    {
      'desc': '验证command_mul自乘数据准确',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_get',
        'collection_name': 'doc_wcc',
        'doc_id': "W_0Cuc6YbCHWYMcK01",
      },
      'expect': (res) => res.data[0]['number02'] == 160000000
    },

    {
      'desc': 'command_push往数组尾部增加指定值',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_push',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK01',
        'push_key': "array04",
        'push_value': "three"
      },
      'expect': (res) => res.updated == 1
    },
    {
      'desc': '验证command_push往数组尾部增加数据准确',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_get',
        'collection_name': 'doc_wcc',
        'doc_id': "W_0Cuc6YbCHWYMcK01",
      },
      'expect': (res) => res.data[0]['array04'][2] == 'three' && res.data[0]['array04'].length == 3
    },

    {
      'desc': 'command_pop从数组尾部删除一个元素',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_pop',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK01',
        'pop_key': "array04",
      },
      'expect': (res) => res.updated == 1
    },
    {
      'desc': '验证command_pop准确从数组尾部删除一个元素',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_get',
        'collection_name': 'doc_wcc',
        'doc_id': "W_0Cuc6YbCHWYMcK01",
      },
      'expect': (res) => res.data[0]['array04'][1] != 'three' && res.data[0]['array04'].length == 2
    },

    {
      'desc': 'command_shift从数组头部删除一个元素',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_shift',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK01',
        'shift_key': "array04",
      },
      'expect': (res) => res.updated == 1
    },
    {
      'desc': '验证command_shift准确从数组头部删除一个元素',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_get',
        'collection_name': 'doc_wcc',
        'doc_id': "W_0Cuc6YbCHWYMcK01",
      },
      'expect': (res) => res.data[0]['array04'][0] != 'one' && res.data[0]['array04'].length == 1
    },

    {
      'desc': 'command_unshift从数组头部增加一个元素',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'command_unshift',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK01',
        'unshift_key': "array04",
        'unshift_value': "one"
      },
      'expect': (res) => res.updated == 1
    },
    {
      'desc': '验证command_unshift准确从数组头部增加一个元素',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_get',
        'collection_name': 'doc_wcc',
        'doc_id': "W_0Cuc6YbCHWYMcK01",
      },
      'expect': (res) => res.data[0]['array04'][0] == 'one' && res.data[0]['array04'].length == 2
    },
  ]
};