---
title: Redis实现分布式锁
date: 2020-07-01 18:55:26
tags: 中间件
categories: 中间件
---

#### Redis实现分布式锁

加锁流程：![微信图片_20200615115204](https://i.loli.net/2020/06/15/qHhme2d1KnYSLXI.jpg)

需要注意的点：

	- 判断key是否存在
	- 保存key-value
	- 设置key的过期时间

这三部必须是原子操作，否则可能会有以下几种情况发生：

1. 判断key是否存在，得出不存在的结果，保存key-value之前，另一个客户端也执行相同逻辑并且判断了key不存在，此时它也同样会创建并获得相同的锁。
2. 设置key的过期时间之前，程序发生崩溃，导致设置过期时间失败，这可能会导致死锁或者占用资源时间过长。

所幸目前我们使用的redis版本都支持`set key value [EX seconds] [PX milliseconds] [NX|XX]`

此操作为**原子操作**！这样原来分三步且不能出问题的三步，变成了一步原子操作！！！这样就规避了我们上面提到的情况。

具体代码如下。

``````python
import uuid
import math
import time

from redis import WatchError


def acquire_lock_with_timeout(conn, lock_name, acquire_timeout=5, lock_timeout=3):
    """
    基于 Redis 实现的分布式锁
    
    :param conn: Redis 连接
    :param lock_name: 锁的名称
    :param acquire_timeout: 获取锁的超时时间，默认 5 秒
    :param lock_timeout: 锁的超时时间，默认 3 秒
    :return:
    """
	# 创建一个uuid可以有效防止出现重复key
    identifier = str(uuid.uuid4())
    lockname = f'lock:{lock_name}'
    lock_timeout = int(math.ceil(lock_timeout))

    end = time.time() + acquire_timeout

    while time.time() < end:
        # 如果不存在这个锁则加锁并设置过期时间，避免死锁
        if conn.set(lockname, identifier, ex=lock_timeout, nx=True):
            return identifier

        time.sleep(0.001)

    return False

``````

解锁流程：

![微信图片_20200615122135](https://i.loli.net/2020/06/15/gdlW165A3zweBD8.jpg)

跟加锁一样，判断key是否存在和判断是否持有锁和删除key-value都必须是一组原子操作。

否则，当客户端判断key存在并且判断自己有锁，redis的过期时间到了，锁被redis自动释放，同时另一个客户端通过这个key加锁成功，如果第一个客户端执行了key-value操作，则这个不属于第一个客户端的锁就会被释放。

这一步需要用到lua脚本，鉴于我对lua不熟悉。以下释放锁的部分我借鉴于https://zhuanlan.zhihu.com/p/112016634，这里有提到如何通过lua脚本释放分布式锁。

``````python
def release_lock(conn, lock_name, identifier):
    """
    释放锁
    
    :param conn: Redis 连接
    :param lockname: 锁的名称
    :param identifier: 锁的标识
    :return:
    """
    unlock_script = """
    if redis.call("get",KEYS[1]) == ARGV[1] then
        return redis.call("del",KEYS[1])
    else
        return 0
    end
    """
    lockname = f'lock:{lock_name}'
    unlock = conn.register_script(unlock_script)
    result = unlock(keys=[lockname], args=[identifier])
    if result:
        return True
    else:
        return False
``````

以上就是我学习redis分布式锁的全部内容。