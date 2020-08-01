---
title: go语言的基本类型
date: 2020-07-01 18:43:17
tags: GoLand
categories: GoLand
---

#### go语言的基本类型

数字：

1. int、int8、int16、int32、int64
2. uint、uint8、uint16、uint32、uint64、uintptr（与上面的区别在于，带u开头的是无符号类型
3. byte(uint8的别名)
4. rune(int32的别名)
5. float32、float64
6. complex64、complex128(复数类型，由两个浮点数表示，其中一个表示实部，一个表示虚部，complex64表示为32位实数和虚数；complex128则表示为64位的实数和虚数)

布尔:

bool

字符串

string



#### 基本类型的默认值

bool:

默认值为false

![J3iyp4.png](https://s1.ax1x.com/2020/04/20/J3iyp4.png)



string:

默认值为"",即空字符串

![J3kJLn.png](https://s1.ax1x.com/2020/04/20/J3kJLn.png)



int型相关:

默认皆为0

![J3ADtf.png](https://s1.ax1x.com/2020/04/20/J3ADtf.png)



float型相关:

默认皆为0

![J3AOBR.png](https://s1.ax1x.com/2020/04/20/J3AOBR.png)



complex型:

默认为0+0i

![J3EAHI.png](https://s1.ax1x.com/2020/04/20/J3EAHI.png)

#### go不支持隐式转换

![J3VkzF.png](https://s1.ax1x.com/2020/04/20/J3VkzF.png)

必须进行显式转换才可以

![J3eAb9.png](https://s1.ax1x.com/2020/04/20/J3eAb9.png)

#### go可以建立类型别名

![J3e4r4.png](https://s1.ax1x.com/2020/04/20/J3e4r4.png)



#### 类型的预定义值

1. math.MaxInt64
2. math.MaxFloat64
3. math.MaxUint32

![J3nP0J.png](https://s1.ax1x.com/2020/04/21/J3nP0J.png)



#### 指针类型

指针类型与C/C++相比的差异在于不能进行指针运算

![J3n63V.png](https://s1.ax1x.com/2020/04/21/J3n63V.png)



![J3ngjU.png](https://s1.ax1x.com/2020/04/21/J3ngjU.png)

以上是对Go语言基本类型的简要了解，让我们继续往下深入它！