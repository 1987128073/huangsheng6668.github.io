---
title: 彻底搞定HOOK不上
date: 2020-07-11 18:50:01
tags: Android逆向
categories: Android逆向
---

##### 如何枚举内存中所有的类，并找出interface的实现类
```js
// Java.enumerateClassLoaders,如果下面不对换这个试试~
Java.enumerateLoadedClasses({
	"onMatch": function(className){
		if (className.indexOf(当前app包名) < 0){
			return;
		}
		var hookCls = Java.use(className);
		var interFaces = hookCls.class.getInterfaces();
		if (interFaces.length > 0) {
			console.log(className);
			for (var i in interFaces) {
				console.log("\t", interFaces[i].toString());
			}
		}
	}
})
```
通过获取当前包下的所有interface,然后打印所有interface，注意有没有当前interface，如果有则说明这个类就是实现类。

##### 如何注入gson到当前内存当中使得我们方便转换对象为json
```js
function main(){
	Java.perform(function x(){
		console.log("In Java perform function")
		var ByteString = Java.use("com.android.okhttp.okio.ByteString");
		var verify = Java.use("org.teamsik.ahe17.qualification.Verifier")

		Java.openClassFile("/data/local/tmp/r0gson.dex").load();
		const gson = Java.use("com.r0ysue.gson.Gson");

		var stringClass = Java.use("java.lang.String");

		var p = stringClass.$new("09042ec2c2c08c4cbece042681cafld13984f24a");
		var pSign = p.getBytes();
		console.log(gson.$new().toJson(p));
		console.log(ByteString.of(pSign).hex());

		var buffer = Java.array('byte', [ 13, 37, 42 ])
		console.log(gson.$new().toJson(buffer));
	})
}
```
r0gson是肉丝编译的gson，导入这个gson就可以转对象为json,以上仅是示例，具体操作还是随机应变。附图：
![picture 2](http://img.juziss.cn/0217ab6efc468f1c18887a51eb93c2eaab54f07b9ce5cfd5485933e548793535.png)  


##### 如何打印byte[]
```js
var ByteString = Java.use("com.android.okhttp.okio.ByteString");
var j = Java.use("c.business.comm.j");
j.x.implementation = function() {
    var result = this.x();
    console.log("j.x:", ByteString.of(result).hex());
    return result;
};

j.a.overload('[B').implementation = function(bArr) {
    this.a(bArr);
    console.log("j.a:", ByteString.of(bArr).hex());
};
```
利用安卓自带的ByteString类

##### 如何打印函数的堆栈信息
```js 
function get_stack(){
	console.log(Java.use("android.util.Log").getStackTraceString(Java.use("java.lang.Throwable").$new()));
}
```

##### 当需要Java来实现加密过程，如何把它导成dex并在js当中引入这个dex
1. 打开AndroidStudio，实现加密过程
2. Sdk目录下的build-tools文件夹下的相应api版本包名内部找到d8这个文件,然后直接通过命令行转相应的class文件为dex
![picture 3](http://img.juziss.cn/53dc622b32a94afa063ebee76134e4a95f4226448fd88fd61dd7aa8fedeca4a4.png)  
3. 把生成的dex， adb push到安卓机里，并添加权限
4. 在hook的js代码里面通过`Java.openClassFile(相应的dex文件所在位置).load()`加载进内存当中，这个函数会返回相应的dex可以通过变量去接这个值，也可以不接(注意，当这段js在Java.perform内部可以直接用.load,不在则不可以)
5. 此时就可以通过Java.use("要调用的类路径")来调用相应的函数了

###### z3用于约束求解和符号执行

##### WallBreaker
该工具是葫芦娃大佬基于objection和frida写的一个objection插件。github:https://github.com/hluwa/Wallbreaker

##### 如何去使用WallBreaker
1. 先git clone WallBreaker到本地
2. 使用命令行去启动objection
`objection -g 包名 explore`
3. objection启动之后，命令行添加这条命令`plugin load WallBreaker路径`
4. 这个时候就可以使用WallBreaker了，其相应命令如下：
```
plugin wallbreaker classsearch <pattern>
plugin wallbreaker classdump <classname> [--fullname]
plugin wallbreaker objectsearch <classname>
plugin wallbreaker objectdump <handle> [--fullname]
```
plugin wallbreaker classdump 包名:
![picture 5](http://img.juziss.cn/003bceaad877d2ec21bf7e90077bbf1ec59bd0a457ff902598b6f8e5f3033298.png)  
以上为wallbreaker的效果图

##### ZenTracer

###### 如何安装ZenTracer
1. 先git该项目github: https://github.com/hluwa/ZenTracer
2. `pip install PyQt5`，有时候可能下载不了，这种情况升级一下pip,`pip install --upgrade pip`
3. 执行ZenTracer，`python ZenTracer.py`
4. 手机启动frida,然后再打开文件，就可以通过ZenTracer来hook东西了

以上这些工具其实作用不大，最好的工具还是自己写代码hook

##### Frida-DEXdump
这个又是葫芦娃大佬写的工具，该工具十分牛逼，通过暴力搜索在内存中找到dex然后脱壳。
###### 使用方法
大佬的原话是这样：
![picture 6](http://img.juziss.cn/f2bccf3ea23f2cd90263216ac96240f005d912a2f3ea9f5d4c85ee4a01042721.png)  

github: https://github.com/hluwa/FRIDA-DEXDump

##### Frida-unpack
该工具也是用来脱壳的，这个不做详细介绍，因为两者使用起来都简单，当然。当然两个都可能会出现dump不完全的情况。
github: https://github.com/dstmath/frida-unpack