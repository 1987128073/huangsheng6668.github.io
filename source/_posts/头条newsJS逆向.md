---
title: 头条newsJS逆向
date: 2020-07-24 18:08:38
tags: JS逆向
categories: JS逆向
---
听说头条更新了，而且我下个周确定入职，所以想练练JS逆向，好久不搞JS逆向这一块了，话不多说，搞起。

#### 参数对比
![picture 1](http://img.juziss.cn/cc6276d81cd8eaf4c3e65981ef8d8fd2a056a67b1e000bd61700c52108fb636c.png)  

![picture 2](http://img.juziss.cn/82101d95231970ef4316a9c61a85b9eb1026023bc6f0b86eca5457371e184d4e.png)  

![picture 3](http://img.juziss.cn/3ec9b0e799ea75ca0b8af6b9de4dcafb4e3c667b0530395a6f617d2078bb502f.png)  

从以上三图可知我们需要的参数是max_behot_time(时间戳)、as、cp、_signature

#### 寻找加密处
1. as、cp
全局搜索`as:`即可搜到as和cp，打个断点下拉就能看到了~
![picture 4](http://img.juziss.cn/bb18c44a6cc9bbec624dbc6278489a61cabcda567cc68dc0c7fe3491fd068295.png)  

我们可以看到as和cp来自e,而这个e是下图
![picture 5](http://img.juziss.cn/3d1db78a9d328570648215e78be43ce7a8d3227383e7623a439e6056a07e24cf.png)  

找到a()
![picture 7](http://img.juziss.cn/1c2aefc1c7ee1553dedf3b9ced7ef2586c7c556d0ad4eade50f91f96f7cd8e64.png)  

进入到a之后看看这个o是啥玩意。
![picture 8](http://img.juziss.cn/8c0c15e8037c9c8e6d4df4c3ca40cf80ba15e0039c3cb164eab732fb59fcb602.png)  

再步进C
![picture 9](http://img.juziss.cn/ce0cfdac29d0a8afd73201aa480bbf46c566c3ee58b2496ea40e42505cc79208.png)  
这个是是在某个自执行函数里面的，我们一般把这个自执行抠出来。报错的地方不影响的话直接去掉即可。
![picture 10](http://img.juziss.cn/300991f1caabc9175e5102e3c43d191c3eb8e447d11d3bf85d4da882f371739f.png)  
2. _signature
这个参数是最让一般人头疼的，我们来慢慢的解决它。
![picture 11](http://img.juziss.cn/f07cef0d146093374716fd15425fd270a1c969181af5be03da7e8804cd3bcad5.png)  
全局搜索找到这个地方。找到`p.calcSignature`所代表的的函数p()
![picture 12](http://img.juziss.cn/e2b377ef3f4466ba553a25a70439895f8f0bcf898b9b40d0f5122700a64bc5ea.png)  
看到那么多location、window就知道这个东西有进行环境检测。能写死先写死。

![picture 13](http://img.juziss.cn/c77b614bab039fa5441d3d4f9787356c022b74dba12855cd3d29b53c2328e22e.png)  
这个参数是除了_signature之外所有参数拼接而成的url：`"https://www.toutiao.com/toutiao/api/pc/feed/?max_behot_time=1595566720&category=__all__&utm_source=toutiao&widen=1&tadrequire=true&as=A1153FE1EB50763&cp=5F1BB08776134E1"
`

window.byted_acrawler.sign的方法实际上是在另一个文件里
![picture 14](http://img.juziss.cn/7b6d35be068ee637ab5a16487fdd9f8cc4792eadd0efccd173813b4f30614125.png)  

这个文件存在着一个大大的自执行函数TAC，这个似乎是头条核心的加密了，我继续整整。

![picture 15](http://img.juziss.cn/3d38c2c9935513d8709f394a52e9f150a19b8e33a1603c59504ab565f5cdbdf0.png)  
先看看这个window.byted_acrawler这里有个init函数，函数里面的vm就是TAC所在的文件，那我们这边大胆假设一下，这个init的执行之后才有了sign。

扣出p并把TAC整个扣出放入p内。构建参数，跑一遍看看。
![picture 17](http://img.juziss.cn/a7825c8b239b5845498893685b2c2907e582c42cc341feb172377345e99e34c1.png)  
是不是给抓包出来的参数对比出来的不一样？目测环境问题。把代码扣出来放浏览器跑跑。

![picture 16](http://img.juziss.cn/6464d47be744376a72871ce2c157bfcc25e1121692a61ef4b63342a577898cb9.png)  

果然是！那问题就是TAC文件里面有环境检测了。看看哪里有window或navigator一般检测就检测这两。
![picture 18](http://img.juziss.cn/bad30c75b6258ceb2af86c73a7b5bfa79fc900933463360ebe0c7aedd1ff811d.png)  
我们看到这里的v是global对象，很有可能通过这个进行了检测。