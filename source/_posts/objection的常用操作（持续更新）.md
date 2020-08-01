---
title:  objection常用操作操作
date: 2020-07-01 18:43:17
tags: Android逆向
categories: Android逆向
---

#### objection常用操作操作：
1. 启动objection(-d的意思是走调试模式，这个模式有attach,-g用于指定当前进程的包名)：
	- objection -d -g 包名 explore

2. objection重启APP并Hook
	- objection -g 包名 explore --startup-command 'hook操作'

3. 查看它的activities
	- andriod hooking list activities

4. 查看它的class
	- andriod hooking list classes

5. 通过search命令来查看某个类
	- andriod hooking search classes 类名

6. 通过watch命令来Hook某个类的所有函数(这些dump-xx都可以不要，但是加上的话可以加)
	- andriod hooking list watch 包名.类名 --dump-args --dump-backtrace --dump-return
