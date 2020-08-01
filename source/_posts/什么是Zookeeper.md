---
title: 什么是Zookeeper 
date: 2020-03-14 15:55:57 
tags: 中间件 
categories: 中间件 
---

#### 什么是Zookeeper

Zookeeper是服务于**分布式系统**，用于统一配置管理、统一命名服务、分布式锁、集群管理。Zookeeper的创建是为了解决分布式系统对节点管理的问题（需要实时感知节点状态、对节点进行统一管理等等）。

Zookeeper的数据结构可以看成树结构，它的每一个节点叫做Znode,Znode分为两种类型：

	1. 短暂/临时（Ephemeral):当客户端和服务端断开连接后，创建的Znode会自动删除

   	2. 持久 (Persistent):当客户端和服务端断开连接后，所创建的Znode不会删除

为了去监听这些节点，需要配合**监听器**



#### 监听器的场景

- 监听Znode节点的数据变化
- 监听子节点的增减变化



#### Zookeeper如何做到统一配置管理

假设有**多个系统的多个.yml或.xml等等这些配置文件的配置项都是相同的**，要修改一个配置项那就要做多次，并且很可能要重启系统！

所以我们可以把相同的配置项都提取出来，做成一个公共的common.yml,即使common.yml做了修改，系统也不需要重启，**只需要把这个common.yml配置放在Znode节点中**，则这些系统就可以监听这个Znode节点，当节点发生变更，**及时相应。**

![img](https://mmbiz.qpic.cn/mmbiz_jpg/2BGWl1qPxib1WCfFk2icxudIMHNPQMHIDJkMbN7WO6ITfDPHtO09zibW532otIiaLlw5vAsvtPth0FNrz4dInibPEKA/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



#### Zookeeper如何统一命名服务

统一命名与域名理解一样，为某一部分资源给它取一个名字，别人通过这个名字拿到相应的资源。



#### Zookeeper怎么取实现分布式锁

假如有A、B、C三个系统，都去访问/locks节点，访问的时候会**创建**带**顺序号**的**临时、短暂(EPHEMERAL_SEQUENTIAL)**节点，比如下图

![img](https://mmbiz.qpic.cn/mmbiz_jpg/2BGWl1qPxib1WCfFk2icxudIMHNPQMHIDJczzKQ6bLPE3Buwib1YJeqluPWicmZUbPadvFCU6UopDDkajKQu1FLO3A/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

拿到/locks节点下的所有子节点（id_000000、id_000001、id_000002），通过判断**自己创建的是不是最小的那个节点**：

 - 是——拿到锁；
   - 释放锁：执行完操作后，把创建的节点给删掉
- 不是——监听比自己要小1的节点变化



#### 集群状态

![img](https://mmbiz.qpic.cn/mmbiz_jpg/2BGWl1qPxib1WCfFk2icxudIMHNPQMHIDJ4lnbuRg5lEDmjlSTmdarCs8Dq7Pjg213pAq7QlXxzc7dIklkGuAWYQ/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

如图所示，三个系统分别在ZooKeeper创建各自的临时节点，当一个节点管理，对应的节点就会被删除，则通过监听groupMember下的子节点，其他系统就可以感知哪个系统挂了（新增同理，只要监听groupMember就可以感知新增了什么系统）。

假如集群为主从架构模式下：

**ZooKeeper还能实现动态选举Master的功能：**

​	原理：

​		Znode节点类型是带**顺序号**的**临时节点(`EPHEMERAL_SEQUENTIAL`)**

​		Zookeeper会每次选举最小编号的作为Master，如果Master挂了，自然对应的Znode节点就会删除。然后让**新的最小编号作为Master**，这样就可以实现动态选举的功能了。