---
title: python装饰器
date: 2020-07-11 01:54:24
tags: python
categories: python
---
#### python装饰器
##### 什么是装饰器？
> 装饰器是可调用的对象，**其参数是另一个函数（被装饰的函数）。**装饰器可能会处理被装饰的函数，然后把它返回，或者将其替换成另一个函数或可调用对象。

装饰器总是会比被装饰器先执行。

##### 什么是一等对象？
1. 可以把函数赋给变量
2. 可以变成参数传递函数
3. 函数里面可以定义函数
4. 函数可以做为返回值返回（闭包）

##### 装饰器代码示例
1. 普通装饰器
```python

def my_decorator(func):
    def wrapper():
        print('wrapper of decorator')
        func()
    return wrapper

@my_decorator
def greet():
    print('hello world')

greet()
```

2. 带参数的装饰器
```python

def my_decorator(func):
    def wrapper(message):
        print('wrapper of decorator')
        func(message)
    return wrapper


@my_decorator
def greet(message):
    print(message)


greet('hello world')

# 输出
wrapper of decorator
hello world
```
上面那种一般都会写成,这样写会比较灵活。
```python

def my_decorator(func):
    def wrapper(*args, **kwargs):
        print('wrapper of decorator')
        func(*args, **kwargs)
    return wrapper
```

3. 带自定义参数的装饰器
```python

def repeat(num):
    def my_decorator(func):
        def wrapper(*args, **kwargs):
            for i in range(num):
                print('wrapper of decorator')
                func(*args, **kwargs)
        return wrapper
    return my_decorator


@repeat(4)
def greet(message):
    print(message)

greet('hello world')

# 输出：
wrapper of decorator
hello world
wrapper of decorator
hello world
wrapper of decorator
hello world
wrapper of decorator
hello world
```

3. 类装饰器
```python

class Count:
    def __init__(self, func):
        self.func = func
        self.num_calls = 0

    def __call__(self, *args, **kwargs):
        self.num_calls += 1
        print('num of calls is: {}'.format(self.num_calls))
        return self.func(*args, **kwargs)

@Count
def example():
    print("hello world")

example()

# 输出
num of calls is: 1
hello world

example()

# 输出
num of calls is: 2
hello world

```
类装饰器，要装饰的类必须实现__call__这个魔法函数。

4. 装饰器的嵌套
```python

import functools

def my_decorator1(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        print('execute decorator1')
        func(*args, **kwargs)
    return wrapper


def my_decorator2(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        print('execute decorator2')
        func(*args, **kwargs)
    return wrapper


@my_decorator1
@my_decorator2
def greet(message):
    print(message)


greet('hello world')

# 输出
execute decorator1
execute decorator2
hello world
```

5. 异步的装饰器
```python
import pprint
import aiohttp
import datetime
import asyncio


def time_log(func):
    async def wrap(*args, **kwargs):
        print(f'现在时间：{datetime.datetime.now()}，程序开始运行')
        result = await func(*args, **kwargs)
        print(f'现在时间：{datetime.datetime.now()}，运行结束')
        return result
    return wrap

@time_log
async def get(n):
    async with aiohttp.ClientSession() as client:
        resp = await client.get(f'http://httpbin.org/delay/{n}')
        result = await resp.json()
    pprint.pprint(result, indent=2)


asyncio.run(get(3))
```
**当需要装饰异步函数时，装饰器也必须要为异步**