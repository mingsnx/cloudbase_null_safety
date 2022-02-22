/*

  collection_add
  collection_doc
  collection_get
  doc_get
  collection_update
  doc_update
  doc_set
  collection_where
  collection_orderby
  collection_field
  collection_limit
  collection_skip
  collection_remove
  doc_remove

  //collection_create

*/

var cases_data = {
  'name': 'interface_collection_P0集合',
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
      'eval': (res) => res.total == 0
    },

    {
      'desc': 'collection_add插入一条记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_add',
        'collection_name': 'doc_wcc',
        'data': {
          'wcc': "自动化测试一路顺风！",
          '_id': "W_0Cuc6YbCHWYMcK"     //插入一条数据，指定ID
        },
      },
      'output': {
        'id': 'W_0Cuc6YbCHWYMcK'
      },
      'eval': (res) => res.id == 'W_0Cuc6YbCHWYMcK'
    },

    {
      'desc': 'collection_doc一条记录数据',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_doc',
        'collection_name': 'doc_wcc',
        'record_id': "W_0Cuc6YbCHWYMcK"
      },
      'eval': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK'
    },

    {
      'desc': 'collection_get获取一条记录数据',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_get',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK',
      },
      'eval': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK'
    },


    {
      'desc': 'doc_get获取一条记录数据',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_get',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK',
      },
      'eval': (res) => res.data[0]['_id'] == 'W_0Cuc6YbCHWYMcK'
    },

    {
      'desc': 'collection_update更新一条记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_update',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK',
        'data': {
          'wcc': "collection_update测试成功"
        },
      },
      'eval': (res) => res.updated == 1
    },

    {
      'desc': 'doc_update更新一条记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_update',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK',
        'data': {
          'wcc': "doc_update测试成功"
        },
      },
      'eval': (res) => res.updated == 1
    },

    {
      'desc': 'doc_set更新一条记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_set',
        'collection_name': 'doc_wcc',
        'doc_id': 'W_0Cuc6YbCHWYMcK',
        'data': {
          'wcc': "doc_set_updated测试成功",
          'test': "test collection field"
        },
      },
      'eval': (res) => res.updated == 1
    },

    {
      'desc': 'doc_set插入一条不存在的记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_set',
        'collection_name': 'doc_wcc',
        'doc_id': "W_docset_created",
        'data': {
          'wcc': "doc_set_created测试成功"
        },
      },
      'eval': (res) => res.updated == 0
    },
    {
      'desc': 'collection_where筛选一条记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_where',
        'collection_name': 'doc_wcc',
        'filter': {
          'wcc': "doc_set_created测试成功"
        },
      },
      'eval': (res) => res.data.length == 1
    },

    {
      'desc': 'collection_orderby_asc升序排序记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_orderBy',
        'collection_name': 'doc_wcc',
        'order_key': "wcc",
        'order_type': "asc"
      },
      'eval': (res) => res.data[0]['wcc'] == 'doc_set_created测试成功'
    },

    {
      'desc': 'collection_orderby_desc降序序排序记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_orderBy',
        'collection_name': 'doc_wcc',
        'order_key': "wcc",
        'order_type': "desc"
      },
      'eval': (res) => res.data[0]['wcc'] == 'doc_set_updated测试成功'
    },

    {
      'desc': 'collection_field记录数据指定显示字段,其中一个key为_id',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_field',
        'collection_name': 'doc_wcc',
        'field': {
          '_id': false,
          'wcc': true
        }
      },
      'eval': (res) => res.data[0]['_id'] == null && res.data[0]['wcc'] != null
    },
//    {
//      'desc': 'collection_field记录数据指定显示字段,key均不为_id,且field类型不一致',
//      'run_count': 1,
//      'level': 0,
//      'request': {
//        'cmd': 'collection_field',
//        'collection_name': 'doc_wcc',
//        'field': {
//          'wcc': true,
//          'test': false
//        }
//      },
//      'eval': (res) => res.code == 'INVALID_PARAM'
//    },
    {
      'desc': 'collection_field记录数据指定显示字段,key均不为_id,且field类型一致',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_field',
        'collection_name': 'doc_wcc',
        'field': {
          'wcc': true,
          'test': true
        }
      },
      'eval': (res) => res.data[0]['test'] != null && res.data[0]['wcc'] != null
    },

    {
      'desc': 'collection_limit显示记录数据条数',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_limit',
        'collection_name': 'doc_wcc',
        'limit': 1
      },
      'eval': (res) => res.data.length == 1
    },

    {
      'desc': 'collection_skip跳过N条记录数据条数显示',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_skip',
        'collection_name': 'doc_wcc',
        'skip': 1
      },
      'eval': (res) => res.data[0]['wcc'] == 'doc_set_created测试成功'
    },

    {
      'desc': 'collection_remove删除一条记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'collection_remove',
        'collection_name': 'doc_wcc',
        'filter': {
          'wcc': "doc_set_updated测试成功"
        }
      },
      'eval': (res) => res.deleted == 1
    },

    {
      'desc': 'doc_remove删除一条记录',
      'run_count': 1,
      'level': 0,
      'request': {
        'cmd': 'doc_remove',
        'collection_name': 'doc_wcc',
        'doc_id': "W_docset_created",
      },
      'eval': (res) => res.deleted == 1
    },

  ]
};