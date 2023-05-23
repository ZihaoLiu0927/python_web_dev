#!/usr/bin/env python3

import logging; logging.basicConfig(level=logging.INFO)

import asyncio, os, json, time
from datetime import datetime

from aiohttp import web

def index(request):
    return web.Response(text='Hello, world!')

async def init():
    app = web.Application()
    app.router.add_route('GET', '/', index)
    logging.info('server started at http://127.0.0.1:9000...')
    return app

app = asyncio.run(init())
web.run_app(app, host='127.0.0.1', port=9000)

