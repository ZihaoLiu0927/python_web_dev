#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import configs.config_common
from configs.config_common import merge, toDict

configs = configs.config_common.configs

prod_configs = {
    'debug': False,
    'db': {
        'host': 'mysql',
        'port': 3306,
        'user': 'root',
        'password': '123456',
        'db': 'web'
    },
}

try:
    configs = merge(configs, prod_configs)
except ImportError:
    pass

configs = toDict(configs)