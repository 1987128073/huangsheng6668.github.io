---
title: 插件reres的使用
date: 2020-03-19 13:31:44
tags: JS逆向
---

##### reres是什么？
&nbsp;&nbsp;&nbsp;&nbsp;reres是一款Chrome插件，当碰到想替换的js、css、html时想要替换，这个时候就可以使用reres来进行解决。

##### reres的规则
&nbsp;&nbsp;&nbsp;&nbsp;reres点击这款reres插件之后，然后点击添加规则，会看到如下的界面：

![8rf0JA.png](https://s1.ax1x.com/2020/03/19/8rf0JA.png)

###### IF URL match:
&nbsp;&nbsp;&nbsp;&nbsp;reres用以匹配需要替换的文件，这个比如说你需要替换某个js，那就把其绝对路径写上去。记住**匹配是只能是正则表达式**，当然你也可以获取那个文件的绝对路径。然后通过“^绝对路径”的形式来匹配。

###### Response:
&nbsp;&nbsp;&nbsp;&nbsp;reres用以替换匹配到的文件的相应文件，即IF URL match匹配到了则会通过Response匹配到的文件进行替换。这个是需要写好路径的，如果是本地文件则需要加上"file:///",如file:///C:/test.js

直接实战！


###### 示例
实战网页（需要会员才可以登录查看）：
&nbsp;&nbsp;&nbsp;&nbsp;aHR0cDovL3d3dy5jcmF3bGVyLWxhYi5jb20vIy9xdWVzdGlvbnMvMTA=

进入该网站之后，打开检查可以发现一个debugger;
![8rhXB8.png](https://s1.ax1x.com/2020/03/19/8rhXB8.png)

&nbsp;&nbsp;&nbsp;&nbsp;不过掉这个debugger下面的请求是无法继续的，所以我们把debugger之后的代码全部copy到我们的ide里面，然后通过各种整理之后得到了一个完整的可以让页面正常运行不报debugger,请求能正常发出的js，然后我们替换页面的js。
&nbsp;&nbsp;&nbsp;&nbsp;通过reres来替换，由于我这边把它改成了nodejs的服务（主要是忘记改动哪了。。。），所以目前无法演示替换后的样子，但是我们可以通过观察请求可以看到我们的js已经替换原js了~
替换后：
![8rIGfH.png](https://s1.ax1x.com/2020/03/19/8rIGfH.png)
可以看到debugger没有了！
![8rIUXt.png](https://s1.ax1x.com/2020/03/19/8rIUXt.png)

PS：记得把reres的打开文件选项打开，如果确定匹配写得没错，记得再去打开那个打开文件选项，就是它是√的都要关了再开，然后刷新页面。
