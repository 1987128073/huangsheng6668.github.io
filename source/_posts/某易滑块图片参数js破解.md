---
title: 某易滑块图片参数js破解 
date: 2020-03-14 15:55:57 
tags: JS逆向 
categories: JS逆向 
---

#### 某易滑块图片参数js破解

1. 破解图片下载的参数

   我们要进行验证码验证，首先我们是一定要获取相应的图片的，没有图片，必要的诸如滑动距离，滑块位置是根本无法获取的，所以最重要的一步便是破解图片的参数

   ![image-20200523122804063](https://i.loli.net/2020/05/23/dponbr3BeMIt6hN.png)

   经过多次比对分析，id是定值，每一个host（域名）对应一个id，token只要是第一次请求这个验证码图片都没有附带token,所以这个值可有可无，所以我们只需要获取fp、cb两个参数即可。

2. 全局搜索

   ![image-20200523123541777](https://i.loli.net/2020/05/23/9r2vFyK38WI5iMb.png)

   通过搜索`fp:`或者`cb:`两个参数即可搜索到，我们先来攻克cb(fp挺麻烦的)

3. 跟进，并扣

   ![image-20200523133922556](https://i.loli.net/2020/05/23/URj7winT1fdmtKr.png)

   ![image-20200524000643652](https://i.loli.net/2020/05/24/LR73ZQdAEFHJmqP.png)

   我们可以看到,$.uuid(32)是一个随机的32位的随机值，其实从名字也能看得出是uuid。

   ![image-20200523134259564](https://i.loli.net/2020/05/23/euQaRH6pV85jNmI.png)

   然后我们可以看到l()返回的也是一个随机的值，24位。跟进A（）来到了B(),接下来就是体力活，直接扣就完事了。

   ![image-20200523134404853](https://i.loli.net/2020/05/23/bmK7AsueWSOLiMH.png)

   结果：

   ![image-20200524000732012](https://i.loli.net/2020/05/24/9kgnRDjaJ3lC1SM.png)

4. 找到fp生成的位置

   回到刚才我们找到cp:l()的位置

   ![image-20200523123541777](https://i.loli.net/2020/05/23/9r2vFyK38WI5iMb.png)

   找到`s = i.fingerprint `,然后全局搜索fingerprint,找到这个位置

   ![image-20200524121143912](https://i.loli.net/2020/05/24/PjATUE4wf2k9sbg.png)

5. Hook window.gdxidpyhxde 

   通过油猴也好或者其他啥东西Hook，只要你能HOOK就行，建议只用油猴的找其他方式HOOK，因为有些可能会检测油猴这款插件

    ![image-20200524121847719](https://i.loli.net/2020/05/24/EV4YLqnr9wtFOjx.png)

   这里HOOK来到这里之后，你一定很失望吧，什么呀，怎么是赋值的null,但是！！！你先通过对这个js进行window[be]搜索之后发现，这个js有两处除了这个赋值为null的，还有赋值为其他值的

   ![image-20200524122202117](https://i.loli.net/2020/07/01/ZFeYGEbmMxcKTR7.png)

   然后找找W（）中有没有调用N()的地方

   ![image-20200524122306897](https://i.loli.net/2020/05/24/jqY4DbhBtV53Sys.png)

   还真有，那看来这个W()十有八九就是我们想要的加密处。

   ![image-20200524122409866](https://i.loli.net/2020/05/24/FTPyOjUCNRu18mh.png)

   直接运行到这个位置，看看他的参数的生成过程，h有两处被赋值了，一处在try里面一处在catch里面，我们需要看看它到底是哪一处的值。

   ![image-20200524122921988](https://i.loli.net/2020/07/01/4OFU1IeqYwjuTrQ.png)

   直接在这两处打断点，然后直接跳过来，在h = h + u[7] + p在打一处，直接跳，看看怎没走catch![image-20200524123036334](https://i.loli.net/2020/05/24/ugOrNsSQeJKGY5D.png)

   发现他没走catch，那可以确定跟fp相关的两部关键赋值为

   `h = Oe`和`h = h + u[7] + p`

   我们先把h相关的打上断点，把流程分析一下

   ![image-20200524161636211](https://i.loli.net/2020/05/24/WNxPIfk634nCOHR.png)

   p = 时间戳 + de;

   ![image-20200524161945150](https://i.loli.net/2020/05/24/9Y7lbgHpTWuVzcZ.png)

   n[u[61]] = G;这个G为域名，那我们把这个域名部分提取出来，方便日后针对使用易盾的网站进行变换。

   关于Oe的我们都打上断点，然后跳到断点看看Oe的赋值逻辑

   ![image-20200526104144414](https://i.loli.net/2020/05/26/oQ4U81tBL5GF2Pk.png)

   Oe走的是else的逻辑，把一个K这个数组join一下拼接成一串加密的字符串，这个加密的字符串之前是被a加密的，加密的参数位一个F数组，和$e起初为0，后续一直加上常量Xe为3。

   分析到这就可以了，接下来我们把W()最外层的函数扒下来，然后把那些自执行包括最外层的函数名之类的都删掉

   ![image-20200526122134577](https://i.loli.net/2020/05/26/Z8Ep3G6iHjyYWbU.png)![image-20200526122211429](https://i.loli.net/2020/05/26/SrYkRaq8ypfvcOG.png)

   大概删成这个样子，运行，我们不需要cookie，把

   ![image-20200526122823877](https://i.loli.net/2020/05/26/1A4yn6veYcSDOdQ.png)

   

   删掉，然后会提示U()和H（）那部分报错，直接删掉这两个函数，因为我们刚才也分析过U()这个函数其实无关加密，这个时候几乎就已经可以运行了，把

   ![image-20200526123052826](https://i.loli.net/2020/05/26/6KJ5VXSNW1kvisj.png)

   这个G删掉，换成一个全局变量，因为这个G是域名，网站一变这个G也在变

   ![image-20200526123359127](https://i.loli.net/2020/05/26/oKOnMh8usFGpl4L.png)

   ![image-20200526123415745](https://i.loli.net/2020/05/26/crAWnztLICOv9ym.png)

   再跑一遍，出结果了

   ![image-20200526123439408](https://i.loli.net/2020/05/26/jRNcdAvSGVuUxEX.png)

   可是你以为这样就可以了吗？天真！

   ![image-20200526123516459](https://i.loli.net/2020/05/26/kjWcLH3atyvmBzY.png)

   这个m函数内部其实是有判断指纹之类的，然后通过多次刷新，发现它是个定值，换一个网站这个位置可能需要重新赋值，我们这里直接写死。

   ![image-20200526123645686](https://i.loli.net/2020/05/26/zgxvmNVwHlXuhep.png)

   再运行

   ![image-20200526123729055](https://i.loli.net/2020/05/26/Lk1CExsMdUiv9Rm.png)

   这个结果对不对我不知道，加上刚才求到的cb组成一个新的url去请求一下,开服务的我就不做演示了

   ![image-20200526124138988](https://i.loli.net/2020/05/26/gB27F4tMOb69nJ3.png)

   OK，至此图片加密就已经解决了。

   