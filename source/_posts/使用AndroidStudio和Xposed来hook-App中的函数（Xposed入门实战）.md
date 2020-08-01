---
title: 使用AndroidStudio和Xposed来hook App中的函数（Xposed入门实战）
date: 2020-03-16 10:47:12
tags: Android逆向
categories: Android逆向
---
&nbsp;&nbsp;&nbsp;&nbsp;起初是因为想爬微信公众号的信息，了解到有四种方式可以爬到：

1. 搜狗的微信公众号搜索
2. mitmproxy+appium
3. X-Wechat-Key
4. Hook微信，获取微信公众号推送

&nbsp;&nbsp;&nbsp;&nbsp;采用中间人攻击的方式获取包，属于第二种，也不一定要用mitmproxy，也可以用fildder之类的，总之能抓到包的都是好工具。
&nbsp;&nbsp;&nbsp;&nbsp;第三种则属于微信的通用接口，比如公众号的点赞、阅都需要通过该接口完成，要获取Key肯定是需要逆向或者通过Hook来获取，该方法目前没有详尽的文章去叙述，而我也只是看了很多文章道听途说而来，具体是否可行需要各位自行钻研。

&nbsp;&nbsp;&nbsp;&nbsp;目前我想要采取的是用Xposed来Hook公众号推送来达到我的目标，也就有了本篇踩坑笔记。

##### 什么是Xposed

让我们看看维基百科的释义：
>Xposed框架（Xposed framework）是一套開放原始碼的、在Android**高權限模式**下運行的框架服务，**可以在不修改APK文件的情况下修改程序的运行（修改系统）**，基于它可以制作出许多功能强大的模块，且在功能不冲突的情况下同时运作。這套框架需要设备解锁了Bootloader方可安裝使用[1]（root为解锁Bootloader的充分不必要条件，而xposed安装仅需通过TWRP等第三方Recovery卡刷安装包而不需要设备拥有完整的root权限）。

&nbsp;&nbsp;&nbsp;&nbsp;**高权限意味着普通的用户需要用root**，毕竟刚开始接触万一少了什么权限的使用起来会很麻烦。
&nbsp;&nbsp;&nbsp;&nbsp;还需要注意一点，**Xposed可以在不修改APK文件，即安卓的应用安装包不被更改的情况下修改程序的运行。**

&nbsp;&nbsp;&nbsp;&nbsp;这跟我们使用Mitmproxy类似，可以在相应的请求之前或者之后来完成对请求或相应的修改来达到修改运行结果。只不过Xposed可以精确到某个函数执行之前或之后来通过参数的拦截等来达到修改应用。

&nbsp;&nbsp;&nbsp;&nbsp;这真的是太强大了，所以为了日后的APP的逆向，我们的Xposed还是很有必要去学习的。
&nbsp;&nbsp;&nbsp;&nbsp;让我们来开始第一个Xposed实战吧！

##### 案例需要

1. AndroidStudio(本人的是AndroidStudio3.6.1)
2. 一台Root了的手机（本人的是Nexus5,Android6.0），或者模拟器
3. 安装Xposed应用

&nbsp;&nbsp;&nbsp;&nbsp;这些东西可以自行百度，笔者这里不做过多介绍，重在实战。

##### 在AndroidStudio新建项目

&nbsp;&nbsp;&nbsp;&nbsp;由于笔者有Java的经验，再加上AndroidStudio是基于IDEA来创建的，所以操作起来跟IDEA类似，至于要选择什么Activity笔者也是一知半解，不是专业搞Android但是这不影响我们的实战，后续其实我们要Hook的也是现成的项目(我觉得的),此处我选择的是Empty Activity。
![88B0k6.png](https://s1.ax1x.com/2020/03/15/88B0k6.png)

&nbsp;&nbsp;&nbsp;&nbsp;别的我不清楚，但是我清楚的一点是MainActivity相当于SpringBoot的Appliction,也就是程序的入口，如果我的想法不对，请指正我。
&nbsp;&nbsp;&nbsp;&nbsp;然后再由 onCreate这个函数名我更确信了，MainActivity是安卓的程序入口。
![884Z5Q.png](https://s1.ax1x.com/2020/03/15/884Z5Q.png)

&nbsp;&nbsp;&nbsp;&nbsp;我们在这个类当中，创建一个新的方法，叫做sayHi(String name)

![884IZ8.png](https://s1.ax1x.com/2020/03/15/884IZ8.png)

&nbsp;&nbsp;&nbsp;&nbsp;需要说明的是**Toast是Andriod的简易的消息提示框**，makeText的函数键名知意，就是创建一段带有消息提示框，具体参数可以点击源码去查看，这里不做赘述。

**&nbsp;&nbsp;&nbsp;&nbsp;然后把XposedBridgeApi-54.jar包放进lib包（一般lib包是没有的，要自己在app目录下新建即可）里面，然后在java这个包里新建一个hook包（记得右键addLibray），并创建一个类，实现IXposedHookLoadPackage这个接口**（用IDE的好处是只要你导入了jar包，你只需要输入个IX就有提示，然后看名字见名知意就可以快速的打印出来）

![885BSs.png](https://s1.ax1x.com/2020/03/15/885BSs.png)

**&nbsp;&nbsp;&nbsp;&nbsp;我们再通过 XposedHelpers的findAndHookMethod函数来Hook我们刚才创建的那个函数，第一个参数名为包名和函数名，第二个则是loadPackageParm.classLoader,不知道是不是固定值，但是这个跟反射有关，姑且当做固定值看待，然后第三个是我们刚才创建的函数名字，第四个是参数的类型，第五个参数为要怎么Hook,新建一个XC_MethodHook对象，并重写它的两个函数,两个函数的作用就见名知意啦~**

![8Gt4j1.png](https://s1.ax1x.com/2020/03/16/8Gt4j1.png)

**我们还需要在AndroidManifest.xml当中配置一下**
![88ToXn.png](https://s1.ax1x.com/2020/03/16/88ToXn.png)

**build.gradle需要导入这句话，以此来引用我们的jar包**
![88bkSe.png](https://s1.ax1x.com/2020/03/16/88bkSe.png)

**在main目录下创建一个assets包，新建一个file文件（文件没有后缀），在里面写下你hook的文件路径**
![8GtilR.png](https://s1.ax1x.com/2020/03/16/8GtilR.png)

然后我们编译一下这个我们写的项目，编译好之后会生成一个APK文件，把这个文件放到我们的手机里面，然后安装，这里我使用的是abd install xx.apk的形式给手机安装这个项目（记住要cd 到APK所在的目录哦！）

![88TmwV.png](https://s1.ax1x.com/2020/03/16/88TmwV.png)

**此时你的手机或者模拟器的xposed的模块就会看到你的项目的名字，把它勾起来，然后重启一下**

然后打开手机或者模拟器相应的应用，发现该软件弹出“安卓”两个字则意味着我们成功hook了