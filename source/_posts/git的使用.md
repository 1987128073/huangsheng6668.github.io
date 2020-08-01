---
title: git的使用
date: 2020-07-19 15:51:33
tags: git
categories: git
---
#### git的使用
##### git的来由
git是一个**分布式版本控制系统**，其实由Linux之父林纳斯创建，其质量如何不言而喻。其开发的目的是为了更好的管理和开发Linux的内核。git在本地磁盘上保存着所有当前项目的历史更新，处理速度快；git的绝大多数操作都只需要访问本地文件和资源，**不用实时联网**。

##### git的三种工作区域
![picture 5](http://img.juziss.cn/7330a7743acd2faf84667987ea60429e59a732a314dceb39a80660bf23c45786.png)  

###### 本地仓库
每个git init之后都会产生这样一个文件夹.git,其内部是这样的
![picture 1](http://img.juziss.cn/8110bf55ca579b3d98e0490c7f093f1021bd507ff46bbaf72a81f45bb072a117.png)  

hooks: 里面存放这,看下图可以知道，这些是一些shell脚本
![picture 2](http://img.juziss.cn/f10c1768d4b0a37092adf51d2b58668a923806e89b5b9cfee40c12ddaeddb938.png)  

info: 仓库的一些信息
logs: 日志信息（废话了）
objects: 存放所有的git对象
![picture 4](http://img.juziss.cn/1f111db92d5ef9d61837bb404fed571142868bc9e5e1ea81af3f541e46edeb4e.png)  
refs：
	- heads：保存当前最新的一次提交的哈希值
	- tags: 空的，估计我最近写博客没有啥标签

###### 工作区
用户操作目录,大白话**就是你平时存放项目代码的地方**

###### 暂存区
说白了，你每次add之后都会先提交到暂存区.

##### git的三种状态
###### committed(已提交)
该文件已经被保存在本地仓库中

###### modified(已修改)
修改某文件，但是还没提交

###### staged(已暂存)
把已修改的文件放在下次提交时要保存的清单当中

![picture 6](http://img.juziss.cn/4a713e7e5bd54cb6bfbea22625eb8739c9b11773ad62e6857a7adc11b796edfc.png)  

![picture 7](http://img.juziss.cn/47217d7835eb426c66e743fff6fa4987b9da01bd3d1b4b6c31ea5fd06630f57c.png)  

![picture 8](http://img.juziss.cn/b0c7ebc8f9f3afbc7858c7aac5b5951bb2977cf099bbffbd3f6b599862966540.png)  

##### git的分支
1. git中的分支，本质上是一个**commit对象的可变指针。**

2. git会使用master作为分支的默认名字，在若干次提交后其实已经存在了一个指向最后一次提交对象的master分支，它在每次提交的时候都会自动向前移动。
3. git鼓励在工作中频繁使用分支与合并 


![picture 9](http://img.juziss.cn/2f54102b4fde56a2f25b6f6b178e3fc9d5ae652c9fab7641bbbe7597a64f6e75.png)  

![picture 10](http://img.juziss.cn/134258095dcfc7235da33a3844471d5cbee1e06216f7ed1b38b841aec3454853.png)  

![picture 11](http://img.juziss.cn/362cdec0fc7ddd6d22227033f7a14f0320995269f43735a38ec3e5c6f3d47f63.png)  

![picture 12](http://img.juziss.cn/b613425b408c4fe1310f7aff66c232717326bd5f7d012f39c29b76a5cb95f074.png)  

![picture 13](http://img.juziss.cn/40db048c52d0a4b5e64c5d1bacc8b6ae4eede10a7da83459adfb9e125f9a3b1d.png)  

##### git的标准工作流程
![picture 45](http://img.juziss.cn/7695e5a80abc37d5dc31b24492dfde1899c8a791536364d3ca08fe7df8e278f6.png)  

以上是git的最标准，最常见的工作流程。

对此的解释是：
1. master是一条稳定的分支，不会对这条分支轻易的修改，如线上有bug在master分支分出hotfix分支用来解决bug。当有新的需求时会再开一条分支develop,开发人员通过这个分支再分出自己的feature分支，开发完成之后合并回develop，测试从develop分支分出release进行测试，测试没问题即合并回master分支。

##### git的基本操作
###### 配置用户名和邮箱
`git config --global user.name "your username"`
`git config --global user.email "your email"`

###### 创建版本库
1. 创建项目目录
```shell
mkdir testgit
cd test
```
2. 初始化目录
`git init`

###### 查看仓库状态
`git status`

###### 添加到暂存区
`git add fileA fileB fileC ...`

###### 提交到本地仓库
`git commit -m 注释信息`

###### 查看修改内容
- 工作区 `git diff`
- 仓库 `git file`

###### 查看版本
```
git log --pretty=oneline
git log --pretty=short
git log --pretty=full
git log --pretty=fuller
```
以上是简单模式，基本够用了，不行的话自己定制
`git log --pretty=format:"%h - %an, %ar : %s"`


以下是格式化参数说明
选项 | 说明
---|---
%H | 提交对象（commit）的完整哈希字串
%h | 提交对象的简短哈希字串
%T | 树对象（tree）的完整哈希字串
%t | 树对象的简短哈希字串
%P | 父对象（parent）的完整哈希字串
%p | 父对象的简短哈希字串
%an | 作者（author）的名字
%ae | 作者的电子邮件地址
%ad | 作者修订日期（可以用 -date= 选项定制格式）
%ar | 作者修订日期，按多久以前的方式显示
%cn | 提交者(committer)的名字
%ce | 提交者的电子邮件地址
%cd | 提交日期
%cr | 提交日期，按多久以前的方式显示
%s | 提交说明

##### 版本回退
回到上一个版本
`git reset --hard HEAD^`
使用git reset 只能回退本地分支：
![picture 50](http://img.juziss.cn/9ec23cfc58e4b5b75bee1923ddb06d8d1151f32e4cf2954db03fabf65ff42533.png)  

丢弃工作区的修改(撤回)
`git checkout -- file`
##### 删除文件
`git rm file git commit -m 注释`

##### 查看当前分支
`git branch (-a)`
![picture 46](http://img.juziss.cn/01e12acb3f2ec6f9e59e038c6fc28a696fa7a0d1f3ae87d6c94c9bb3057467a4.png)  

##### 新建分支
`git branch develop`
新建分支之后并没有自动切换过去，需要主动切换分支

##### 切换分支
`git checkout develop`

##### 新建并切换分支
`git checkout -b feature`
该操作相当于前面两步骤合在一起执行。

##### 删除分支
`git branch -d feature`
需要注意的一点是当前所在分支无法被删除

##### 合并分支
`git checkout develop && git merge feature `
以上的命令解释为：把feature合并到develop分支

#### git和远程服务器的交互
##### 添加远程服务器
`git remote add xx.git(别名)  host/xxx.git`
示例：
`git remote add dcmsStatics4.5git(别名）http://gitlab.cephchina.com/ccod_project/dcmsstatics4-5git.git
`

##### 查看远程服务器的相关信息
`git remote -v`
`git remote show xx.git`

##### 重命名远程仓库信息
`git remote rename demo test`

##### 删除远程仓库
`git remote rm test`


注：第一次提交的时候加上`-u` 可以使得本地的master和远程的新的master关联起来

##### 本地master推送到远程仓库的master
`git push xx.git master`

##### 从远程仓库获取数据
- `git fetch origin develop` 获取远程仓库的数据至.git目录，但并不merge本地的分支
- `git merge origin/develop` 把获取远程仓库的数据手工merge到当前分支
- `git pull origin develop` 获取远程仓库的数据，并merge至当前分支，相当于以上两步

##### 合并两个不同项目
`git merge 项目名 --allow-unrelated-histories`

##### 跟踪分支
从远程分支checkout出来的本地分支叫做跟踪分支，**跟踪分支是一种和远程分支有直接联系的本地分支。**跟踪分支里使用git push会自行判断要把推送发往哪个服务器

**在git clone仓库下来之后会自动创建一个master分支来跟踪origin/master。所以一开始我们就可以使用git push和git pull**

##### 从远程库克隆
1. 从SVN克隆`git svn clone 地址`
2. 从git远程库上克隆`git clone 地址`

###### 在本地创建和远程分支对应的分支
`git checkout -b branch-name origin/branch-name`

#### tag(标签)
git的标签用于给分支做标记
![picture 54](http://img.juziss.cn/c3c99505ceb5d847d75e093b3bb792ef14c7ab53b8d38138fcd843706a146c91.png)  

##### 创建标签
###### 轻量级标签
`git tag <tag-name> commit id`

###### 带说明的标签
```git
git tag -a <tag-name> commit id
git tag -m <msg> <tag-name> commit id
```

###### 带签名的标签（GPG加密，需安装）
```git
git tag -s <tag-name> commit id
git tag -u <key-id> commit id
```

##### 查看标签
```git
git tag
git tag -n
git show <tag-name>
```

##### 删除标签
`git tag -d <tag-name>`

##### 共享标签
向上游版本库提交标签
```git
git push origin <tag-name>
git push origin --tags
```

删除远程版本库的标签
`git push origin :tag2`


#### git分支冲突
当不同分支在同一文件的同一部分都做了修改，则git就无法把两者都合在一起,发生冲突的时候git不会把代码提交。

##### 查阅合并时出现冲突的文件
- `git status`,git会在冲突的文件里加入标准的冲突解决标记，可以通过它们手工定位并解决这些冲突。
- `git log --graph --pretty=oneline --abbrev-commit`也可以看到分支合并的情况

##### 忽略特殊文件
创建和编写`.gitgnore`文件，编写不需要提交的文件，则提交之后这些文件将不会被提交
示例:
```
# 忽略所有 .a 结尾的文件
*.a
# 但 lib.a 除外
!lib.a
# 仅仅忽略项目根目录下的 TODO 文件，
/TODO
# 忽略 build/ 目录下的所有文件
build/
# 忽略 doc/notes.txt 
doc/*.txt
```

##### 切换用户
###### 查看当前配置用户
`git config --list`
修改配置：打开全局的`.gitconfig`文件，直接在文件当中修改。

git cherry-pick:新建分支并复制相应节点到分支上
![picture 51](http://img.juziss.cn/02662822e90981ae0f7b271e265986b8fb8b7d82159ffb1d6813aeef800a65da.png)  

git过滤掉调试语句
![picture 52](http://img.juziss.cn/317119d2019315c16ea1a16b305c4d972d433def244f52257368aab0943f6ec3.png)  

![picture 53](http://img.juziss.cn/8bfd6b74fe41d731f4109f4c63d09965aaa150d4fbb452354bd3b2b06d959309.png)  

git describe:描述最近的标签
![picture 55](http://img.juziss.cn/6e749b99e6ebafc16cdfb2a50158f561f60412407664aca69fef1bddddf8f117.png)  

![picture 56](http://img.juziss.cn/b85522f8bf51ec1328e5242f579274fea90e0195da27bfc467a9a190cfe9340e.png)  
