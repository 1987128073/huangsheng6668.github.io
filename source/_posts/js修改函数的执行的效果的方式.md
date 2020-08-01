---
title: js修改函数的执行的效果的方式
date: 2020-07-01 18:37:18
tags: JS逆向
categories: JS逆向
---

#### js修改函数的执行的效果的方式

       1. 覆盖原函数（即重写原函数
       2. 通过中间变量存储原函数，然后在一个新函数里面调用旧函数，并添加新的内容（即AOP与装饰器 
       3. hook函数

**Object.defineProperty**:用于替换一个对象的属性，属性里存的可能是方法，也有可能存的是一个值，

**赋值 '=' 相当于调用了setter(写成set也是可以的)，获取一个值相当于调用其getter(也可以写成get)**

示例，hook Cookie:

```
var temp = "";
Object.defineProperty(document,'cookie',{
	set: function(val){
		console.log(val);
		temp = val;
		return val;
	},
	get:function(){
		return temp;
	}
})
```

<h3>hook是有时机</h3>

1. 在控制台注入的hook  刷新网页就失效了
   在网页加载第一个js的位置 第一行下断点 然后在控制台手动注入hook
   {有可能注入hook的时机还是会晚一点}

2. 利用FD的替换响应 注入hook  
   这种的时机比较靠前
3. 油猴 不推荐，因为有些网站会检测得出是否在使用浏览器插件（不过用得挺爽的

**webpack通用抓取方式**:

1. 找到这个加载器（加载模块的方法
2. 找到调用的模块
3. 构造一个自执行方法   
4. 导出加密方法
5. 编写自定义方法 按照流程加密