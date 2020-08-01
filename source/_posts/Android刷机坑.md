---
title: 遇到的刷机坑（后续如遇问题将继续更新这篇） 
date: 2020-07-05 20:55:57 
tags: Android逆向 
categories: Android逆向 

---

#### 遇到的刷机坑（后续如遇问题将继续更新这篇）

1. fastboot -w参数的坑
	今日给pixel重新在原有android8.1的基础之上重新刷8.1,结果一直刷了好几遍，一直出现下图的问题。先是恢复出厂设置，这个也不行，无视报错再重复刷多遍也是不行。
![picture 2](http://img.juziss.cn/aa61c644ca10071361b90b00965e9a00419f1efcddfa12b65f346c98ca91efde.png)  

后来经查falsh-all.sh的代码有点问题。
![picture 3](http://img.juziss.cn/4729010984e46692e5010573ee0d2a1eb479c6771ef830234f8d8ab144329bb8.png)  
刷机实际上就是用到了这个falsh-all.sh这个文件（一般大家都在linux上刷机),实际上刷机也就这么几段核心代码，但是一般出问题就出在最后一行上，这个-w，肉丝姐说是有些机子不兼容，不过我刚开始从Android10刷到8.1的时候这个-w不影响，但是8.1到8.1却出了问题，这个-w是清楚用户信息的意思.。
![picture 4](http://img.juziss.cn/f6dbf467547e503f570439d50b33adbc45fc2f0b343c8028711f7d0ea6e0a2dd.png)  
，我们看看刚才的报错`Cannot generate image for userdata`,无法为用户数据生成图像。估摸着，既然是涉及到userdata了，这个-w是既然涉及到userdata，那直接去掉，看看结果。

![picture 1](http://img.juziss.cn/eb2ea8f2bc8d558d51d1a4713211b76ffc43ed30c02546dca46c1a680b159048.png)  
哎，可以跑了，并且完成刷机了！！！