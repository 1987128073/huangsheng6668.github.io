---
title: Begin Go !
date: 2020-04-20 00:39:07
tags: GoLand 
categories: GoLand 
---

### Begin Go !

编写第一个Go程序

```go
package main

import "fmt"

func main(){
	fmt.Println("Hello World")
}
```



看似简单的一道程序需要有几个点要注意：

1. main函数必须只能存在于main包下，即使你的目录名不叫main
2. main函数没有返回值
3. 文件名不需要叫main.go

### 退出返回值

刚才提到main函数没有返回值，倘若我们需要main函数返回一个**异常**值该如何实现？

**os.Exit()**

```go
package main

import "fmt"

func main(){
	fmt.Println("Hello World")
	os.Exit(-1)
}
```



![JMeh8g.png](https://s1.ax1x.com/2020/04/19/JMeh8g.png)

**os.Args**

main函数不能传参，但是需要传参的话需要借用到os.Args

```go
package main

import (
	"fmt"
	"os"
)

func main()  {
	fmt.Println(os.Args[1])
	if  len(os.Args) > 1{
		fmt.Println("Hello World")
	}
	os.Exit(-1)
}

```

![JMuGuj.png](https://s1.ax1x.com/2020/04/19/JMuGuj.png)

这里需要注意的是，这里的Args从1开始！！！



以上就是我的第一篇关于Go的实战文