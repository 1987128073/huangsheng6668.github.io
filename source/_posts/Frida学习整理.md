---
title: Frida学习整理
date: 2020-07-01 18:45:37
tags: Android逆向
categories: Android逆向
---

#### Frida学习整理

&nbsp;&nbsp;&nbsp;&nbsp;一个逆向框架，能HOOK安卓、IOS、windows、应用层、native层，注入JS或者Python代码，不需要重启设备，编译（设备一定要root，虽然有不root方法，但是可能会碰到各种坑）

&nbsp;&nbsp;&nbsp;&nbsp;HOOK先决条件：

	1. 要看懂需要Hook哪个方法

   	2. 要有源代码

&nbsp;&nbsp;&nbsp;&nbsp;Frida组成部分：

		- Frida-server: 运行在设备上
		- Frida: Python模块
		- Frida-tools: 提供cli工具命令，跟Frida-server交互

&nbsp;&nbsp;&nbsp;&nbsp;Frida常用模块API：

	- Java模块：HOOK JAVA层的类方法相关
	- Process模块：处理当前线程相关
	- Interceptor模块：操作指针相关，多用来HOOK Native相关
	- Memory模块：内存操作相关
	- Module模块：处理so相关

固定的代码部分：

~~~
// 参数是function(),为JS代码
Java.perfom(function(){
	var test = java.use("类路径（含类名），跟平时写JAVA的路径一样");
	// 要HOOK的函数的要做的相关操作
	test.函数名.implentation = function(有参数就传没参数就不穿，有几个参数写几个){
		具体要HOOK的操作
	}
})
~~~

如何HOOK so库：

Module模块:

 - findExportByName(moduleName|null, exportName)

   ​	moduleName: lib名字

   ​	exportName: 函数名字

   该函数**返回exportName的地址**

- findBaseAddress(moduleName)

  ​	moduleName: lib名字

  该函数**返回lib的基地址**（用以HOOK so库的基地址）

Process模块：

 - findModuleByAddress(address)

   ​	address: lib的指针地址

   该函数返回一个Module对象

Momery模块

 - readCString(pointer)

   ​	pointer:指针地址

   把pointer还原成字符串

- readUtf8String(pointer)

- readAnsiString(pointer)

Interceptor模块： 监听

 - attach(target, callbacks)

   ​	target:指针地址

   ​	callbacks: 回调函数

   ​		onEnter

   ​		onLeave

- replace(target, replacement) —— 该函数用以改变原函数逻辑的

HOOK so示例：

假设要HOOK一个hello.so中的printHello();

	1. var  pointer = Module.findExportByName("hello.so", "printHello")  ——此时Hook住了这个函数,返回一个地址指针    

   	2. Interceptor.attach(pointer, callbacks) ——通过刚才的pointer传进来callbacks可以调用onEnter,即HOOK住之后马上执行onEnter，结束之后进入到onLeave函数（）



​		

常HOOK的系统so库

​	libc.so常调用函数：

​		void * dlopen(const char * filename, int flag); 加载动态链接库



#### 常用的API函数

device = frida.get_usb_device()     // 获取设备

pid = device.spawn()    // APP启动时Hook,此函数也需要APP运行时调用，只是需要重启设备



#### Frida脱壳

##### 加固原理

- **APP启动，壳dex先加载起来，壳负责读源classes.dex，对源classes.dex加密，并写进壳的classes.dex,生成新的apk**

##### 解密原理

- 新apk被点击，启动，把源classes.dex读出来，解密源classes.dex，把源classes.dex给加载起来

##### dex文件格式

- 不同的文件格式都有自己定义的文件格式（.txt,.excel,.xml等等）
- dex开头的前8个字节是magic位 -->dex 035，4个字节是校验位，20个字节是签名
- 从32字节开始，4个字节  dex文件大小

##### 脱壳原理：

1. APP启动
2. 壳dex先加载起来
3. 壳负责把源dex文件读出来
4. 壳把源dex文件解密
5. 把解密后的dex加载进内存，源dex运行起来
6. 源dex文件最终会加载进内存
7. HOOK加载dex的函数，把dex从内存中dump出来
8. Hook DexFile: :OpenMemory()

#### frida rpc

与常规HOOK不同之处：

- 常规HOOK是被动，Hook的函数/方法要被动等待触发，不能主动调用要Hook的代码，**rpc能主动调用要HOOK的代码**

