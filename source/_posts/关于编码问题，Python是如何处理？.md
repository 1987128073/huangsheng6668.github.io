---
title: 关于编码问题，Python是如何处理？
date: 2020-07-01 18:57:03
tags: 爬虫
categories: 爬虫
---

#### 关于编码问题，Python是如何处理？

1. requests这个库经常爬出来的页面效果存在乱码问题，究其原因很可能是响应头返回的编码跟页面的编码不一致，导致我们看到的文字编码有误。对于这个问题requests的response(即requsts爬取页面返回的响应通过**response.encoding可以得到返回页面的编码**，然后再通过response.content把返回的页面转换位二进制，再通过decode('要转换的编码')这样的方式解决，即response.content.decode('要转换的编码'))；**requests这个encoding首先通过响应头声明得到，如果找不到就会通过chardet这个库来检测编码**。

2. 通过chardet.detect(response.content)这样可以显示返回的编码，然后通过这个编码进行decode相应的文本即可。（chardet.detect出来的中文编码可能是gb2312,经常会把中文gbk转成gb2312

   

   chardet检测编码效果：

![JgyQ1J.png](https://s1.ax1x.com/2020/04/26/JgyQ1J.png)

chardet.detect面对中文时潜在的坑点:

![JgcsFf.png](https://s1.ax1x.com/2020/04/26/JgcsFf.png)



3. cchardet,比前面的那个库多个c，面对中文也可能有点坑

![JgRKyQ.png](https://s1.ax1x.com/2020/04/26/JgRKyQ.png)

关于这个坑点实际上中文有三种编码gb2312 < gbk < gb18030,当字符串中有一个字超出了某个编码范围则会显示下一个大的结果集编码