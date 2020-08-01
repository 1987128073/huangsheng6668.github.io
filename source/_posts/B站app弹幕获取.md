---
title: B站app弹幕获取
date: 2020-07-12 23:46:48
tags:
---

##### 抓包

我们采用Charles抓包，首先请看这个效果
评论信息：
![picture 3](http://img.juziss.cn/ef56362b23e4729dd91bd69ab5b61aac1ecf1dd6f34a151f8d306bff72388433.png)  

弹幕信息：
![picture 4](http://img.juziss.cn/c339b479337e9d675d883120f8d5a96f08a8eaad9ad2b7f390cfb7ce67a324c7.png)  

我们看到弹幕信息的包有很多乱码，其实这不是乱码，是被压缩了。判断依据是其accept-encoding的第一个值为gzip,请求为这个的话返回的就是图上Charles显示的这样。

**对比抓到的包，首先，我们重复抓一个视频看看有什么值是固定不变的**
![picture 7](http://img.juziss.cn/32faa3cc37647f2d98fcc9c252b5fc1e34f526d0f216c331c309d20a0fc13790.png)  

![picture 8](http://img.juziss.cn/bc658836a4a5733945a3bcf7024f96089fbabca8643ab9d471ccaeb841bd68a0.png)  

当我们抓相同的包时，会变化的只有ts(时间戳)、sign签名。

**对比其他的包**

![picture 9](http://img.juziss.cn/f519f746be0355d1f3af4ad6f3a656a9a62e19dc4212ae0391f0d2c99d7311bc.png)  

对比之后发现会变化的有oid、ts、sign；所以我们确定要抓弹幕最重要的就是构造oid、ts(10位时间戳)、sign

可以写死的参数信息有:
```python
{
	aid: 668556934,
	appkey: 1d8b6e7d45233436,
	build: 5310300,
	mobi_app: android,
	plat: 2,
	platform: android,
	ps: 0,
	type: 1
}
```

我们通过参数信息先进行搜索看看
![picture 11](http://img.juziss.cn/fb479dfd01526d44f014e3c386ca9284894d0a0e1a7f0c8dfe28f509e206d408.png)  

这边的搜索技巧就是搜固定的不变的值，具体原因我总结为自己的经验。

搜到如上图的地方，判断这个肯定是有调用过的函数。

目前已经有了个线索1：
pek这个类是有调用的。一般来说调用这个类肯定是为了组建一个map