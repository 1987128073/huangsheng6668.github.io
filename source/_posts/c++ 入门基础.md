---
title: c++ 入门基础
date: 2020-07-01 19:02:43
tags: C++
categories: C++
---

#### c++ 入门基础

##### 常量的定义方式：

1. #define 定义宏常量，写在函数外部，一般定义在文件的上方，相当于java的包名处

2. const修饰的变量，写在函数内部

##### 数据类型

整型：

	1. short   短整型  占两字节

   	2. int   整型   占4字节
            	3. long  长整型  windows为4字节，Linux为4字节，8字节
         	4. long long  长长整型  8字节

| 类型名称  | 中文名称 | 空间大小                            | 取值范围       |
| --------- | -------- | ----------------------------------- | -------------- |
| short     | 短整型   | 2字节                               | (-2^15~2^15-1) |
| int       | 整型     | 4字节                               | (-2^31~2^15-1) |
| long      | 长整型   | windows占4字节，linux占4字节，8字节 | (-2^31~2^31-1) |
| long long | 长长整型 | 8字节                               | (-2^63~2^63-1) |

浮点型：

| 类型名称 | 中文名称 | 空间大小 | 取值范围 |
| -------- | -------- | -------- | -------- |
| float    | 单精度   | 4字节    |          |
| double   | 双精度   | 8字节    |          |
|          |          |          |          |

字符型：

| 类型名称 | 中文名称 | 空间大小 | 取值范围 |
| -------- | -------- | -------- | -------- |
| char     | 字符     | 1字节    |          |

字符串

| 类型名称      | 中文名称      | 空间大小 | 取值范围 |
| ------------- | ------------- | -------- | -------- |
| string        | 字符串        |          |          |
| char 变量名[] | C风格的字符串 |          |          |

示例:

![J4r5LQ.png](https://s1.ax1x.com/2020/04/28/J4r5LQ.png)

布尔型:

| 类型名称 | 中文名称 | 空间大小 | 取值范围                 |
| -------- | -------- | -------- | ------------------------ |
| bool     | 布尔     |          | true(或者1);false(或者0) |



##### sizeof关键字

利用sizeof关键字可以统计数据类型所占大小



##### 数据的输入

cin:用于从键盘获取输入

示例：

[![J46KRP.png](https://s1.ax1x.com/2020/04/28/J46KRP.png)](https://imgchr.com/i/J46KRP)



#### 数组的操作

##### 数组名的用途

1. 可以通过数组名统计整个数组占用内存的大小

   

2. 可以通过数组名查看数组在**内存中的首地址**

示例：

![image-20200428132745010](https://i.loli.net/2020/07/01/d5786Y4oxLihHwW.png)



##### 获取元素中的地址

通过`&arr[index]`的方式获取元素在内存中的地址

![image-20200428133113981](https://i.loli.net/2020/07/01/zAd3q8vTsUEp2jN.png)

##### 计算数组的最后一位元素的下标

// 求出数组的长度

`int arrLenght = sizeof(arr) / sizeof(arr[0])`

// 求出数组的最后一个元素的下标

`int arrLastIndex = arrLenght - 1`

#### 二维数组

##### 二维数组名称用途

1. 可以查看占用内存空间大小
2. 可以查看二维数组的首地址

![J5pNDK.png](https://s1.ax1x.com/2020/04/28/J5pNDK.png)



#### 函数

##### 函数的结构：

返回的类型 函数名（参数列表）{函数体  return 值}

##### 值传递

当传入不可变类型的参数给函数时是值传递，值传递是不影响原变量的

##### 函数的声明

如果没有采用面向对象的设计，则定义函数时最好先提前做函数的声明，用以提前告诉编译器，函数的存在，所以**声明最好是在程序比较靠前的位置** ，**声明可以有多次，但是定义只能有一次**

![J5kfaV.png](https://s1.ax1x.com/2020/04/28/J5kfaV.png)

##### 函数的分文件编写

1. 创建后缀名为.h的头文件
2. 创建后缀名为.cpp的源文件
3. 在**头文件中写函数的声明**
4. 在源文件中写函数的定义

#### 指针

##### 指针的作用

​	可以通过指针间接访问内存

1. 内存编号是从0开始记录的，一般用十六进制数字表示

2. 可以利用指针变量保存地址

#### 如何定义一个指针

···

int a = 10;

// 指针定义的语法：数据类型 * 指针变量名；

int *p;

// 让指针记录变量a的地址

p = &a;

cout << "a的地址为: " << &a << endl;

cout << "指针p为：" << p << endl;

// 使用指针

// 可以通过**解引用的方式来找到指针指向的内存**

// 指针前加*代表解引用，找到**指针指向内存中的数据**

 *p = 1000;

cout <<  "a = " a << endl;

cout << "*p  = " *p << endl;

···

#### 指针所占内存空间

**32位的操作系统下： 占用4个字节空间**

**在64的操作系统下： 占用8个字节空间**



#### 空指针和野指针

##### 空指针 ： 指针变量指向内存中编号为0（数字0）的空间

1. **空指针用于给指针变量进行初始化**
2. **空指针是不可以进行访问的**，因为0~255的内存编号是系统占用的，因此不可以访问

##### 野指针： 指针变量指向非法的内存空间

#### const修饰指针

const修饰指针有三种情况：

1. const修饰指针：常量指针，指针指向可以修改，但是指针指向的值不可以修改

![JoGrkT.png](https://s1.ax1x.com/2020/04/29/JoGrkT.png)

2. const修饰常量——指针常量：指针的指向不可以改，指针指向的值可以改

   ![JoJM34.png](https://s1.ax1x.com/2020/04/29/JoJM34.png)

3. const修饰指针又修饰常量

![JoJcUf.png](https://s1.ax1x.com/2020/04/29/JoJcUf.png)

#### 指针和数组

1. 利用指针访问数组中的元素

   ```  c++
   int arr[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};cout << "第一个元素为: " << arr[0] << endl;
   int * p = arr; // arr就是数组首地址
   
   cout << "利用指针访问第一个元素" << p << endl;
   
   p ++; // 让指针向后偏移4个字节
   
   cout <<"利用指针访问第二个元素： "  << *p << endl;
   
   cout << "利用指针遍历数组" << endl;
   
   int * p2 = arr;
   
   for (int i = 0; i < 10 ;i++){
   
   ​	// 利用指针来遍历数组
   
   ​	cout << *p << endl;
   
   ​	p2 ++;
   
   }
   
   system("pause");
   
   return 0;    
   ```

   

   #### 指针和函数

   1. 值传递
   2. 地址传递

   ```c++
   void swap01 (int p1, int p2){
       int temp = p1;
       a = p2;
       b = temp;
   }
   
   void swap02 (int *p1, int *p2){
       int temp = p1;
       a = p2;
       b = temp;
   }
   
   int main(){
       int a = 10;
       int b = 20;
       // 值传递
       swap01(a , b); // a = 10, b = 20
       // 地址传递
       swap02(&a, &b);   // a = 20, b = 10
       
       system("pause");
       return 0;
      
   }
   ```

   



#### 结构体

 结构体属于用户**自定义的数据类型，允许用户存储不同的数据类型**

##### 结构体定义和使用

语法： `struct 结构体名 {结构体成员列表};`

通过结构体常见变量的方式有三种:

1. struct  结构体名  变量名
2. struct  结构体名  变量名 = {成员1值,  成员2值...}
3. 定义结构体时顺便创建变量



示例：

```
#inculde<iosteam>
#inculde<string>
using namespace std;

// 结构体定义
struct student{
	string name;
	int age;
	int score;
}s3; //顺便创建结构体变量

int main(){
	// struct Student s1  （struct关键字可以省略，因为已经定义了结构体
	struct Student s1;
	// 给s1属性赋值
	s1.name = "张三";
	s1.age = 18;
	s1.score = 100;
	
	cout << "姓名" << s1.name << "年龄：" << s1.age << "分数：" + s1.score << endl;
	// struct Student s2 = {...}
	struct Student s2 = {"李四", 19 , 80};
	cout << "姓名" << s2.name << "年龄：" << s2.age << "分数：" + s2.score << endl;

	// 在定义结构体时顺便创建结构体变量(一般不建议)
	s3.name = "王五";
	s3.age = 18;
	s3.score = 90;
	
	
	system("pause");
	return 0;
}
```



##### 结构体数组

将自定义的结构体放入到数组中方便维护

语法： `struct 结构体名 数组名[元素个数] = \{\{\}, \{\}, ... \{\}\};`

```
// 创建结构体数组
// 1. 定义结构体
struct Student{
	string name;
	int age;
	int score;
}

int main(){
	// 2.创建一个结构体数组
	struct Student stuArray[3] = {
		{"张三", 18, 100},
		{"李四", 28, 99},
		{"王五", 38, 66}
	} ;
	// 3.给结构体数组中的元素赋值
	stuArray[2].name = "赵六";
	stuArray[2].age = 80;
	stuArray[2].score = 60;
	
	// 4.遍历结构体数组
	for (int i = 0;i < 3; i++){
		cout << "姓名" << stuArray[i].name << "年龄：" << stuArray[i].age << "分数：" + stuArray[i].score << endl;
	}
}
```

##### 结构体指针

通过指针访问结构体的成员

​	利用操作符 `->`可以通过结构体指针访问结构体属性

示例：

``````c++
struct Student{
	string name;
	int age;
	int score;
}

int main(){
	// 创建学生结构体变量
	struct Student s = {"张三", 18, 100};
	// 通过指针指向结构体变量
	struct Student * p = &s;
	// 通过指针访问结构体变量中的数据
	cout << "姓名:" p -> name << "年龄:" << p-> age "分数:" << p->score << endl;
	system("pause");
	return 0;
}
``````

##### 结构体嵌套结构体

结构体中的成员可以是另一个结构体

示例：

``````c++
struct Student{
	string name;
	int age;
	int score;
}

struct Teacher{
	int id;
	string name;
	int age;
	struct Student stu;
}

int main(){
    // 结构体嵌套结构体
    // 创建老师
    Teacher t;
    t.id = 19000;
    t.name = "老王";
    t.age = 50;
    t.stu.name = "小王";
    t.stu.age = 20;
    t.stu.score = 60;
    
    cout << "老师姓名: " << t.name << "老师编号：" << t.id << "老师年龄：" << t.age << "老师辅导的学生姓名： " << t.stu.name << "老师辅导的学生的年龄： " << t.stu.age << "老师辅导的学生的分数: " << t.stu.score << endl;
}
``````

##### 结构体做函数参数

将结构体作为参数向函数中传递

传递方式有两种：

	1. 值传递

   	2. 地址传递

示例:

``````
#include<iostream>
using namespace std;

struct Student {
	string name;
	int age;
	int score;
}

// 值传递
void printStudent1(struct Student s){
	cout << "子函数中的姓名： " << s.name << "年龄: " << s.age << "分数: " << s.score << endl;
}

// 地址传递
void printStudent2(struct Student *s){
	s -> age = 200;
	cout << "子函数2中姓名 ： " << s -> name << "年龄: " << s->age << "分数:" << s->score << endl;
}

int main(){
	// 创建结构体变量
	struct Student s;
	s.name = "张三";
	s.age = 18;
	s.score = 100;

	printStudent1(s);
	printStudent2(&s);
}
``````

##### 结构体中的const的使用场景

``````c++
struct Student {
	string name;
	int age;
	int score;

}

void printStudents(Student s){
	cout << "姓名： " << s.name << "年龄：" << s.age << "分数: " << s.score << endl;
}

int main(){
	struct Student s = {"张三", 15, 70};
}
``````

