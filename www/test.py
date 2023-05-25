import asyncio, aiomysql

import orm

from models import User

async def test(loop):

    await orm.create_pool(user='root', password='lzh270015##', db='web', loop=loop)

    u = User(name='Test2', email='test2@example.com', passwd='123456', image='abut:blank')

    await u.save()

loop = asyncio.get_event_loop()

loop.run_until_complete(test(loop))