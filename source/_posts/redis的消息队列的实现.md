---
title: redis的消息队列的实现
date: 2020-07-10 08:55:00
tags:: 中间件
categories: 中间件
---
#### redis的消息队列的实现
1. 普通的订阅与消费模式
	redis提供channel,消费者首先通过subscriber订阅一个或多个channel,当生产者publish消息时，消费者即可消费相应消息。
	相应语法：
	- subscribe channel [channel ...]	订阅channel
	- publish channel message 生产者推送消息到channel

2. 订阅某种类型的channel(某种类型在redis上的命名都为xx)
	例如订阅日志类型的消息队列。可以采用`Pattern Subscribe`主题订阅
	![picture 1](http://img.juziss.cn/9d7dba036915f6dae255f034fc33c4f4951f29a2ac51f38f5cb4efc0001e2a3d.png)  

	语法:
	`psubscribe pattern [pattern ...]`,例如这里就是`psubscribe log*`

以上两种的缺点:
	1. 无法持久化保存消息，如果 Redis 服务器宕机或重启，那么所有的消息将会丢失；
	2. 发布订阅模式是“发后既忘”的工作模式，如果有订阅者离线重连之后不能消费之前的历史消息。

一个注意点:
	**当消费端有一定的消息积压时，也就是生产者发送的消息，消费者消费不过来时，如果超过 32M 或者是 60s 内持续保持在 8M 以上，消费端会被强行断开。**

3. 基于List和ZSet解决发布订阅不能持久问题:
	![picture 2](http://img.juziss.cn/e0884a05aa40a087be0714ff63de59e0567e772a144ab4de8e9a8f0237845494.png)  

基于List的优点:
	1. 消息可以被持久化，借助 Redis 本身的持久化（AOF、RDB 或者是混合持久化），可以有效的保存数据；
	2. 消费者可以积压消息，不会因为客户端的消息过多而被强行断开。

基于List的缺点:
	1. 消息不能被重复消费，一个消息消费完就会被删除；
	2. 没有主题订阅功能。

使用ZSet:
和List用法相同，只需要zadd来push消息，zrangebyscore来消费消息。ZSet实现起来会比List和发布订阅模式复杂，因为其多了个score属性，我们可以通过它存储时间戳，实现延迟队列。

使用ZSet优点:
	1. 支持消息持久化；
	2. 相比于 List 查询更方便，ZSet 可以利用 score 属性很方便的完成检索，而 List 则需要遍历整个元素才能检索到某个值。

使用ZSet缺点:
	1. ZSet 不能存储相同元素的值，也就是如果有消息是重复的，那么只能插入一条信息在有序集合中；
	2. ZSet 是根据 score 值排序的，不能像 List 一样，按照插入顺序来排序；
	3. ZSet 没有向 List 的 brpop 那样的阻塞弹出的功能。

4. 基于Stream的消息队列的实现
	基于发布/订阅模式的消息队列其实也是足够我们使用的了，但是前面两种我们讲的有那么一些缺点：
		- 发布订阅模式 PubSub，不能持久化也就无法可靠的保存消息，并且对于离线重连的客户端不能读取历史消息的缺陷；
		- 列表实现消息队列的方式不能重复消费，一个消息消费完就会被删除；
		- 有序集合消息队列的实现方式不能存储相同 value 的消息，并且不能阻塞读取消息。

	但是以上的缺点在使用Stream时都不存在了。

	Redis5.0时推出了Stream,其借鉴了Kafka的设计思路，支持**消息持久化和消息轨迹的消费**，支持**ack确认消息的模式。**

	##### Stream的基本操作：
- xadd 添加消息
	`xadd key ID field string [field string ...]`
- xlen 查询消息长度
`xlen key`
- xdel 根据消息ID删除消息
`xdel key ID [ID ...]`
- del 删除整个Stream
`del key [key ...]`
- xrange 读取区间消息
`xrange key start end [COUNT count]`
- xread读取某个消息之后的消息
`xread [COUNT count] [BLOCK milliseconds] STREAMS key [key ...] ID [ID ...]
- xgroup create创建一个消费者组
`xgroup create stream-key group-key ID` ,这里的ID一般为0-0或$,第一个意味着从第一个开始读取，第二个意味着从最后一个开始读取
- xreadgroup从消费者组读取消息
`xreadgroup group group-key consumer-key streams stream-key`
- xack消费信息确认
`xack key group-key ID [ID ...]`
- xpending查询未消费消息
`xpending stream-key group`
- xinfo查询流的相关指令：
	1.  xinfo stream stream-key 查询流信息
	2.  xinfo groups stream-key 查询消费组消息
	3.  xinfo consumers stream group-key  查看消费者组成员信息
- delconsumer 删除消费者
`xgroup delconsumer stream-key group-key consumer-key`
- 删除消费者组
`xgroup destroy stream-key group-key`

我们以Kafka的视角来看Redis Stream,一个Stream相当于broker,一个Stream这里对应几个消费者组，对应的是kafka的分区，接收者每次都会跑到消费者组拉取数据。

![picture 1](http://img.juziss.cn/ff5e1e9aa82ee7ca97f1fa7f1607af640c2dcafe598aa19cd27d499209cb7587.png)  

实际的redis Stream设计图
![picture 1](http://img.juziss.cn/d60b7721903a092a6a2330b48bc7b080182aba2b273bcbde4bf421a5fd387d0c.png)  
