---
title: 常见的APK相关概念和操作
date: 2020-07-01 18:58:11
tags: Android逆向
categories: Android逆向
---

#### 常见的APK相关概念和操作



#### 安卓相关的开发细节

xxx.dex相当于xxx.class，即安卓的编译产生的文件

#### 安卓软件包：APK

APK是一个压缩文件，用zip压缩解压

#### ####  APK包的目录结构

assets: 资源文件（图片、网页、视频），**不会被编译**

res: 资源文件(静态文本、图片、关键资源),比如说字体文件会放在这个目录，编译之后成为静态文件，汉化，**要被编译**

lib: .so库，系统库，自己打包的库。有的把加密/token生成方式放在.so文件里，库里都是C语言写的，反编译出来是汇编

META-INF:签名信息。

AndroidManifest.xml: 配置信息（关键），举例：修改权限；程序一旦启动会去先加载里面的内容

classes.dex: android dalvik虚拟机可执行文件，主要逻辑代码都在这里

resources.arsc: 资源索引/对应文件

**加固的APK，被漏洞利用解压会有问题**



#### APKTOOL 反编译APK包

1. 反解APK命令：`apktool d xx.apk`
2. 打开AndroidManifest.xml
   - APP权限配置文件
   - 程序入口
3. 反编译出smali文件（一种汇编代码)
   - .smali可以和.dex相互转换
   - 修改APK代码通常修改smali文件（重新修改.java源码文件，重新编译的难度太大）
   - baksmali.jar smali.jar对dex和smali文件做转换
4. classes.dex
   - 源代码在classes.dex文件里
   - 可以反编译出.java代码
5. .smali --> .dex -->.java，这三种文件可以通过工具互相转换
6. 大厂会利用apktool漏洞，apk会反编译失败，这种情况要么等升级要么使用老版本的apk
7. 重新打包apk命令: `apktool b 目录`
8. 重新签名之后才能安装（看下面的签名）

#### APKTOOL和直接改后缀为.zip再解压有啥区别：

1. xx.dex文件没有了，变成smali文件夹了；直接把xx.dex反编译成smali文件夹，以smali为结尾的文件，以汇编为主的代码文件，不全是汇编；要改源码一般不要直接改别人的java代码，一般改smali文件，改了之后只需要二次打包做签名就好了。
2. 反编译之后AndroidManifest.xml可以打开了，直接解压是不能打开的

如何看AndroidManifest.xml这个文件：

1. 首先先看包名，因为后续如果需要HOOK，知道包才能HOOK；Android的日志比较多，可以通过报名去过滤信息
2. 然后看application,去找启动的时候加载了哪个类，即APP的入口；因为这个入口类是写好写死的，是**不能混淆的**
3. 看activity,有一个activity代表一个界面，找到有MAIN的就是第一个启动界面，Activity也是一个类



#### 签名

keytool jarsigner工具是JAVA JDK自带的，以下是它的命令

1.  生成证书
    - keytool -genkey -keystore my-release-key.keystore -alias my_alias -keyalg RSA -keysize 4096 -validity 10000
2.  用证书给apk签名
    - jarsigner -sigalg MD5withRSA -digestalg SHA1 -keystore my-release-key.keystore -signedjar 签名之后的apk名 要签名的apk my_alias

每一个APK对应一个签名，防止有地方出现冲突。

**未签名APK不能在安卓手机上安装，APP在启动时会对签名校验，要逆APP，跳过校验**

### 常用的adb命令

安卓设备列表 adb devices adb devices 

显示device unauthorized adb kill-server adb start-server 

进入安卓shell adb shell 

安卓日志 adb logcat adb logcat -s keyword 

把文件推送进安卓设备 adb push 

打印AndroidManifest.xml 

adb shell dumpsys activity top 

adb shell dumpsys package packagename 

adb install XXX.apk 

adb uninstall packagename 

拉取安卓文件到本地 

adb pull android-path local-path 猿人学Python 猿人学Python 猿人学Python 

推送本地文件到安卓 

adb push local-path android-path adb shell pm clear package_name 

网易模拟器 adb connect 127.0.0.1:7555



#### APK启动加载

1.DEX加载流程： （安卓源码）

Davlivk虚拟机加载dex文件

Java层Dex加载流程：

​	BootClassLoader ----> PathClassLoader ---> DexClassLoader

Vative层Dex加载流程：

​	libdvm.so （重新编译system.img)

​	OpenDexFileNative

2.点击图标，APP加载流程





#### APP四大组件

  1 .Activity:

​		一个Activity通常就是一个界面



#### 破解安装签名

即使签名成功后，但是安装到模拟器或者实体机之后，打开APP会进入签名校验，校验失败会自动弹出，不让程序运行，这个时候就需要破解安装签名。

1. jadx之后找到相应的application
2. 找到android:name = "xxx",找到这个xxx
3. 去找相应的启动类，因为启动时会率先校验签名，所以必须去这个启动类里去找到相应的类，通过观察它在哪个位置进行了签名校验，随后在smali文件里面删除对应的位置或者更改就可以了。