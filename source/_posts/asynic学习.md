---
title: asyncio学习
date: 2020-07-08 14:48:12
tags: python 
categories: python 
---
#### asyncio的学习

##### 协程
1. 什么是协程？
	又称为微进程，是一种用户态内的上下文切换技术。简而言之，其实就是通过一个线程实现代码块相互切换执行。

2. 实现协程的几种方法：
	1. greenlet,早期的模块
	2. yield关键字
	3. asyncio装饰器
	4. async、await关键字

##### 协程的意义
	在一个线程中，如果遇到IO等待时间，线程将利用空闲的时间再去干其他的事。

#### 异步编程
1. 事件循环
	理解为一个死循环，去检测并执行某些代码。

2. 协程函数和协程对象
	协程函数，定义函数时候`async def 函数名`
	协程对象，执行协程函数()得到的就是协程对象。
	**注意：执行协程函数创建协程对象， 函数内部代码不会执行。所以需要协程对象和事件循环搭配运行。**

3. await
	await  可等待对象 (协程对象、Future、Task对象 、 IO等待)
	遇到IO操作挂起当前协程/任务（，等待IO操作完成之后继续往下执行。当前协程挂起时，事件循环可以去执行其他协程（任务）。

4. Task对象
	在事件循环当中添加多个任务的。
	示例：
	![picture 1](http://img.juziss.cn/590cb4022824e77a29dd58597ab3ca14db00b328766904dc6496a267eed08797.png)  
	图中有三个任务在事件循环里，一个是main,这个是最先执行的，然后运行了这个main，里面添加了两个任务task1、task2当遇到await时，挂起当前线程执行task1,输出一个1，然后task1内部有一个await asynicio.sleep，这里有个await然后挂起，执行task2,也执行到await asynicio.sleep时继续挂起，此时等待task1里的await执行完毕之后继续向下执行，然后task2里的await也执行完毕之后继续向下执行,当这两个任务执行完毕之后继续向下顺序执行main函数里的。

	![picture 2](http://img.juziss.cn/190b81fb3cfb517c90c40dd4cdcd9a03bf3c08f2011e98fe56dcc8567126bbd2.png)  

	但是我们平时的话用的比较多的是这种:

```python

import asyncio


async def func():
    print(1)
    await asyncio.sleep(2)
    print(2)
    return "返回值"


async def main():
    print('main begin')
    task_list = [asyncio.create_task(func()), asyncio.create_task(func())]
    print('main end')
    # 这种无序并发,timeout默认为None
    done, pending = await asyncio.wait(task_list, timeout=None)
    # 这种顺序并发
    # done, pending = await asyncio.wait(task_list)
    print(done)
    print(pending)
```

或是这种
![picture 3](http://img.juziss.cn/0063621df42a5f687400e9c27b08bfc0196b9590bdceb6b9c2b4709a5f497a70.png)  


5. asyncio.Future对象
> Future objects are used to bridge low-level callback-based code with high-level async/await code.

Task继承Future, Task对象内部await结果的处理基于Future对象来的。

6. concurrent.futures.Future对象
	![picture 4](http://img.juziss.cn/cf5e9d0ba94cfa12ee7cd7d747ec7f34a7e5a9d363271c6726b46bcec593d55d.png)  
	当某个第三方库不支持协程时可以考虑通过图中这种方式把对象变成Future对象
实例：
```python
import asyncio
import requests


async def download_something(url):
    loop = asyncio.get_event_loop()
    be_future = loop.run_in_executor(None, requests.get, url)
    response = await be_future
    print(response.text)


if __name__ == '__main__':

    urls = ['http://www.baidu.com', 'http://www.baidu.com', 'http://www.baidu.com']
    tasks = [download_something(url) for url in urls]
    loop = asyncio.get_event_loop()
    loop.run_until_complete(asyncio.wait(tasks))
```

#### 异步迭代器
实现__aiter__()方法的对象，__anext__必须返回一个awaitable对象，async_for会处理异步迭代器的__anext__方法返回的可等待对象，直到引发一个StopAsyncIteration异常。有PEP492引入。

##### 什么是异步可迭代对象
可在async for语句中被使用的对象。必须通过它的__aiter__()方法返回一个asychronous iterator。由PEP492引入。

##### async for的代码必须写在async函数内
备注：async for一般用于想要获取其入口迭代对象，想循环获取其每一个值的时候会用到。
示例：
```python
import asyncio

class Reader:
	""" 自定义异步迭代器（同时也是异步可迭代对象） """

	def __init__(self):
		self.count = 0

	async def readline(self):
		self.count += 1
		if self.count == 100:
			return None
		return self.count

	async def __anext__(self):
		val = await self.readline()
		if val is None:
			print(item)

asyncio.run(func())
```

#### 异步上下文管理器
此种对象通过定义__aenter__()和__aexit__()方法来对async with语句中的环境进行控制。由PEP 492引入。

该用处在于操作之前要打开什么，操作完之后在进行关闭

示例：
```python
import asyncio

class AsyncContextManager:
	def __init__(self):
		self.conn = conn

	async def do_something(self):
		return 666

	async def __aenter__(self):
		return self

	async def __aexit__ (self, exc_type, exc, tb):
		await asyncio.sleep(1)

async def func():
	async with AsyncContextManager() as f:
		result = await f.do_something()
		print(result)

asyncio.run(func())
```

#### uvloop
这个是asyncio的事件循环的替代方案。事件循环 > 默认asyncio的事件循环。
一般使用都是：
```python
import asyncio
import uvloop

try:
	asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
exept Execption as e: 
	pass

...
```

#### 大示例1——redis异步操作
在使用python代码操作redis时，链接、操作、断开都是网络I/O。
这里使用aioredis:
```python
import asyncio
import aioredis


async def execute(address, password):
	print('开始执行', address)
	# 网络IO操作： 创建redis连接
	redis = await aioredis.create_redis(address, password)

	# 网络IO操作：在redis中设置哈希值car,内部在设三个键值对，即：redis = {'car', key=1,key=2,key=3}
	await redis.hmset_dict({'car', key=1,key=2,key=3})

	# 网络IO操作：去redis中获取值
	result = await redis.hgetall('car', encoding='utf-8')
	print(result)

	# 网络IO操作：关闭redis连接
	await redis.wait_close()

	print('结束', address)

asyncio.run(execute('redis://host', 'password'))
```

####  大示例2——异步MySQL
这里使用aiomysql

```python
import asyncio
import aiomysql


async def execute(host, passwd):
	print('开始', host)
	# 网络IO操作：先去连47.93.40.197，遇到IO则自动切换任务，去连接47.93.40.198:6379
	conn = await aiomysql.connect(host=host, port=3306, user='root', password=password, db='mysql')

	# 网络IO操作：遇到IO会自动切换任务
	cur = await conn.cursor()

	# 网络IO操作：遇到IO会自动切换任务
	result = await cur.execute('SELECT host, user FROM user')
	print(result)

	# 网络IO操作：遇到IO会自动切换任务
	await cur.close()
	conn.close()
	print('结束', host)

task_list = [
	execute('47.93.41.197', 'passwd')
	execute('47.93.40.197', 'passwd')
]

asyncio.run(asyncio.wait(task_list))
```

#### 大示例3——FastAPI框架
安卓FastAPI
```
pip install fastapi
pip install uvicorn
```

示例：
```python
import uvicorn
import aioredis
form aioredis import Redis
from fastapi import FastAPI

app = FastAPI()

# 创建一个redis连接池
REDIS_POOL = aioredis.ConnectionsPool('redis://host', password='passwd', minsize=1, maxsize=10)

@app.get('/')
def index():
	"""普通操作接口"""
	return {'message': 'Hello World'}

@app.get('/red')
async def red():
	"""异步请求接口"""
	print('请求来了')
	
	await asyncio.sleep(2)
	# 连接池取出一个连接
	conn = await REDIS_POOL.acquire()
	redis = Redis(conn)

	# 设置值
	await redis.hmset_dict('car', key1=1,key2=2,key3=3)

	# 读取值
	result = await redis.hgetall('car', encoding='utf-8')
	print(result)

	# 连接归还连接池
	REDIS_POOL.release(conn)

	return result

if __name__ == '__main__':
	uvicorn.run('文件名:app', host='localhost', port=5000, log_level='info')

```
#### 大示例4——爬虫
使用aiohttp
```python
import aiohttp
import asyncio


async def fetch(session, url):
    print('发生请求:', url)
    async with session.get(url, verify_ssl=False) as response:
        text = await response.text()
        print('得到结果:', url, len(text))
        return text


async def main():
    url_list = [
        'https://python.org',
        'https://www.baidu.com',
        'https://www.puthonav.com'
    ]
    async with aiohttp.ClientSession() as session:
        tasks = [asyncio.create_task(fetch(session, url)) for url in url_list]
        done, pending = await asyncio.wait(tasks)
        print(done)


if __name__ == '__main__':
	asyncio.run(main())
```
