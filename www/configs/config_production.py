#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import os
import configs.config_common
from configs.config_common import merge, toDict

configs = configs.config_common.configs

print("prod env: ", os.getenv('DB_PASSWORD'))

prod_configs = {
    'debug': False,
    'db': {
        'host': 'localhost',
        'port': 3306,
        'user': 'root',
        'password': os.getenv('DB_PASSWORD'),
        'db': 'web'
    },
}

try:
    configs = merge(configs, prod_configs)
except ImportError:
    pass

configs = toDict(configs)