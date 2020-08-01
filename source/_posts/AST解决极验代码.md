---
title: AST解决极验代码 
date: 2020-03-14 15:55:57 
tags: JS逆向 
categories: JS逆向 
---

#### AST解决极验代码

1. 分析代码

   ![image-20200606123706459](https://i.loli.net/2020/06/08/VJNvfY26AmhnK1H.png)

   concat是用于拼接数组的函数，返回的是两个函数拼接后的结果，所以AJgjJ.DAi是数组，我们通过获取数组里的元素即可获取可直接获取内部的字符串，然后用字符串代替这些不够明显的赋值。

   ![image-20200606125645749](https://i.loli.net/2020/06/08/Uu6FbHt1qQBAcsW.png)

   我们要获得的就是AJgjJ.DAi(36)之类的字符串或者对象。

   看看这类对象的AST结构

   ![image-20200606153315233](https://i.loli.net/2020/06/08/JXrG5znHfqQMI6c.png)

   CallExpression结构下的argument和MemberExpression的object和property组成我们看到的"数组[num]"形式。

   所以我们要写一段CallExpression的AST替换一下这些数组形式，后续在源码处我会标注好注释方便理解。

   ![image-20200606164217563](https://i.loli.net/2020/06/08/CRHPXx2SN5nhj9c.png)

   ![image-20200606164346667](https://i.loli.net/2020/06/08/2urCSBzeb6d5yVh.png)

   可以看到这里还有AJgjJ.DAi这些，我们看看是否还能在去掉些代码

   ![image-20200607164243141](https://i.loli.net/2020/06/08/1WGFhbHQNSeZs7a.png)

   第一个框的地方是给一个叫Buli的变量赋值，然后给一个全局变量

   ADbcjU赋值，以数组[].concat()的形式拼接。第三个框对这次分析还挺重要的，CfDp看了一下下面的Switch代码里有使用，但是我们注意到这个赋值取的是`ADbcjU[1]`也就是`AJgjJ.DAi`再看需要用到`ADbcjU[0]`的地方，也就是第四个红框，虽然是赋值了，但是变量显示未被使用！

   总结一下这里，**唯一被使用的CfDp实际上就是AJgjJ.DAi**，也就是说，这一段代码是用来混淆视听的！！！AST呼他一脸。

   先看看这类代码在AST里的结构。

   ![image-20200607172147490](https://i.loli.net/2020/06/07/lm3wsKiW1HhZO2V.png)

   先是大的结构，要删的代码是在FunctionExpression里面，也就是我们需要在这个结构里操作。

   ![image-20200607172738904](https://i.loli.net/2020/06/08/5nwJxlF9DH2Ozs8.png)

   要删除的节点在body这个数组的前三个位置，我们在看看其他的位置是不是这样才能判断是否可以删掉。

   ![image-20200607173103660](https://i.loli.net/2020/06/08/ABKH6QyMEnxVb3L.png)

   么的问题，就是这样，但是还是要考虑一下，毕竟有些地方可能会引用到，我想到的一点就是通过一个数组，把需要替换为`AJgjJ.DAi`的name都存起来

   像这类的调用要考虑

   ![image-20200607175535725](https://i.loli.net/2020/06/08/vKEykpqPAnzeLxX.png)

   看结构上，他总是在数组中的第三个位置

   ![image-20200607180004888](https://i.loli.net/2020/06/08/OkBwP8Huirp4nlz.png)

   ![image-20200607180317536](https://i.loli.net/2020/06/08/nXTfR9yC3z5G4V8.png)

   ![image-20200607180152381](https://i.loli.net/2020/06/08/35beOITaPwQWoJ1.png)

   而这个数组总的来说是在`VariableDeclaration`这个结构当中，我们的AST就从中获取。这部分直接上代码

   ``````js
   /**
    *  该函数用于存储需要替换的属性为AJgjJ.DAi的属性名
    * */
   
   function stroeNameInArray(path){
       var array_node = path.node.declarations;
       // 刚才我们分析要获取的name在数组的第三个元素的name，所以长度不小于3
       if (array_node === undefined || array_node.length < 3) return;
       var cond_one_node = array_node[0];
       if (!type.isVariableDeclarator(cond_one_node) || !cond_one_node.init) return;
       if (!cond_one_node.init.object || !cond_one_node.init.property) return;
       var node_object_name = cond_one_node.init.object.name;
       var node_property_name = cond_one_node.init.property.name;
       if (node_object_name !== 'AJgjJ' || node_property_name !== 'DAi') return;
   
       var stroe_name = array_node[2].id.name;
       store_array.push(stroe_name);
   }
   ``````

   这部分处理完成之后，我们该来处理删除节点的事宜。

   ![image-20200607230734498](https://i.loli.net/2020/06/09/brNmVkD4Bg7SUR9.png)

   我们需要删掉总共5个节点

   ``````js
   function delSuplusNode(path){
       var array_node = path.node.declarations;
       if (array_node === undefined || array_node.length < 3) return;
   
       var cond_one_node = array_node[0];
       if (!type.isVariableDeclarator(cond_one_node) || !cond_one_node.init) return;
       if (!cond_one_node.init.object || !cond_one_node.init.property) return;
   
       var node_object_name = cond_one_node.init.object.name;
       var node_property_name = cond_one_node.init.property.name;
       if (node_object_name !== 'AJgjJ' || node_property_name !== 'DAi') return;
   
       var next_del_path1 = path.getNextSibling();
       var next_del_path2 = next_del_path1.getNextSibling();
       
       path.remove();
       next_del_path1.remove();
       next_del_path2.remove();
   }
   ``````

   

   #### 替换

   ![image-20200608102426752](https://i.loli.net/2020/06/09/2Hv5AbKWIcLlEVr.png)

   ![image-20200608102504142](https://i.loli.net/2020/06/09/SefDt3BmzgVhHWu.png)

   我们可以发现需要i替换的都是CallExpression下的callee，因为刚才我们有遍历过CallExpression那我们就直接遍历这个节点，然后对照我们刚才存储名字的数组，如果名字和数组里的其中一个元素相同，则替换为AJgjJ.DAi（num）,实际上我们可以直接取到要替换的值就可以了，不用单独构造MemoryExpression.

   ```js
   /**
    *  该函数用于存储需要替换的属性为AJgjJ.DAi的属性名
    * */
   function stroeNameInArray(path) {
       var array_node = path.node.declarations;
       if (array_node === undefined || array_node.length < 3) return;
       var cond_one_node = array_node[0];
       if (!type.isVariableDeclarator(cond_one_node) || !cond_one_node.init) return;
       if (!cond_one_node.init.object || !cond_one_node.init.property) return;
       var node_object_name = cond_one_node.init.object.name;
       var node_property_name = cond_one_node.init.property.name;
       if (node_object_name !== 'AJgjJ' || node_property_name !== 'DAi') return;
       for (let i = 0; i < array_node.length; i++) {
           try {
               var stroe_name = array_node[i].id.name;
               store_array.push(stroe_name);
           } catch (e) {
   
           }
       }
   }
   ```

   我们看看还有啥比较难看的

   ![image-20200608141437833](https://i.loli.net/2020/06/09/8xobcDmHJsR6EWf.png)

   这是啥？？？这是用来恶心人的**控制流平坦化**.

   关于控制流平坦化，我在网上摘抄了这样一段话，以及一张图片用来解释这个概念。

   > 让所有的基本块都有共同的前驱块，而该前驱块进行基本块的分发，分发用switch语句，依赖于switch变量进行分发

   ![img](https://i.loli.net/2020/06/09/CPMFUvAy6h94gxm.jpg)

   代码的逻辑都是通过分发器进行分发，每一个基本块都有相应的编号用于执行顺序的判断，对于这个流程，我们立马可以想到使用switch来执行，看看刚才我们的控制流平坦化也是这个道理，通过一个死循环作为外部控制switch的case里的代码运行，case内部还需要控制下一步往哪个块走。大致如此。

   但是看到代码心里还是感觉像是。。。

   ![image-20200608154605511](https://i.loli.net/2020/06/08/s7lakptqXSU1EDh.png)

   没事，冷静一下用AST揍它！

   我们先来看看这类代码在AST的结构

   ![image-20200608160215695](https://i.loli.net/2020/06/09/TaXvNJyxCzQljFZ.png)

   首先从大体结构入手

   1. ForStatement的前一个节点是VariableDeclaration这个节点里面存放的value是用于决定switch先往哪走的关键代码。意味着，这个节点的值我们一定要拿下。

   2. 然后是SwitchStatement,这个节点的cases里面的代码就是包含了我们需要的主逻辑

      ![image-20200608161614149](https://i.loli.net/2020/06/09/MsNikSHTtmn69Vb.png)

      我们需要获取每一个test下的value，按这段代码举例，当aaW为test下的value时我们才会保留case内部的代码。因为我们要把代码拆解成普通的逻辑，我们需要把break去掉，其他的做保留。

   3. for代码里面的aaW !== 10，这里是所有代码的终止条件，也需要去获取。

   4. 当出现AJgjJ.EMf()这类格式的代码时候，我们可以发现这种情况下的 代码只有夹在两个AJgjJ.EMf()[][]之间的代码才是真实有效的代码。所以我们需要删除掉AJgjJ.EMf()[][[] 相关的代码，然后保留两个AJgjJ.EMf()之间的代码

      ![image-20200609004723118](https://i.loli.net/2020/06/09/shy1zdi9IwcexqQ.png)

      估计没有说明白，看看AST的这部分结构，我们只要这一部分的节点。

      ![image-20200609005549076](https://i.loli.net/2020/06/09/lvIZCJsYMpyhon6.png)

   让我们开始写出相应的AST。

   

   看一下整体效果，发现还有一些unicode码没得到还原

   ![image-20200609130514866](https://i.loli.net/2020/06/09/Y1MmRAoVXfxNtnZ.png)

   经查，这些都是中文的unicode码，中文的编码恢复AST这方面做的不是很好，参考了蔡老板的公众号也并没有得到解决，不过这个东西也并不影响我们的逆向，就暂且过去吧，后续如果有解决办法会专门写一篇。

   我们现在可以看到还有eval函数

   ![image-20200609170210326](https://i.loli.net/2020/06/09/adyb3tjeBGJVZQm.png)

   恢复eval这边也比较简单，遍历CallExpresiion这个类型，倘若callee的name叫做eval且其内部是StringLiteral则把这个值取出来然后替换，其AST结构如下

   ![image-20200609170759662](https://i.loli.net/2020/06/09/wYhKMFLGWSUqtoe.png)

   代码恢复后变成这样

   ![image-20200609172104440](https://i.loli.net/2020/06/09/Cz6duPKXkHZnYVT.png)

源文件

![image-20200609172141044](https://i.loli.net/2020/06/09/mrXQeVoTSkApwz1.png)

AST一番之后：

![image-20200609172208625](https://i.loli.net/2020/06/09/UOpwhr6PeKvEaZd.png)

以上就是本次的全部内容了。直接测一下B站，B站的登录就是极验，通过fiddler（reres和charles也可以，reres有讲，翻翻前面的教程）来替换远程的文件，替换这个文件

![image-20200609223323243](https://i.loli.net/2020/06/09/xD6YH7kMd21sI89.png)

这个文件是用来加载验证码的，如果验证码能正常出来，能正常划那说明本次AST简化代码成功。

![image-20200609223837350](https://i.loli.net/2020/06/09/PjVmg7r5sNKkeoa.png)

能出验证码，能滑动成功，源代码这里也有我们简化后的js,所以本次AST解决极验代码成功！

![image-20200609223220477](https://i.loli.net/2020/06/09/EFs3gHcUJ2orBVm.png)

下一篇我们来解决极验的图片加密和轨迹加密！