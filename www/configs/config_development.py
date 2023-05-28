#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''
Configuration
'''

import os
import configs.config_common
from configs.config_common import merge, toDict

configs = configs.config_common.configs

dev_configs = {
    'debug': True,
    'db': {
        'host': 'localhost',
        'port': 3306,
        'user': 'root',
        'password': os.getenv('DB_PASSWORD', 'default_password'),
        'db': 'web'
    },
}

try:
    configs = merge(configs, dev_configs)
except ImportError:
    pass

configs = toDict(configs)