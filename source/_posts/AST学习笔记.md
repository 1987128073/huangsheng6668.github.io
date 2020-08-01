---
title: AST学习笔记
date: 2020-07-01 19:00:27
tags: JS逆向
categories: JS逆向
---

#### AST学习笔记

1. 类似于以下这些结构被称为节点(Node),一个AST可以由单一节点或是成百上千节点构成。组合在一起可以描述用于静态分析的程序语法。

``````json
{
  type: "FunctionDeclaration",
  id: {...},
  params: [...],
  body: {...}
}

{
  type: "Identifier",
  name: ...
}

{
  type: "BinaryExpression",
  operator: ...,
  left: {...},
  right: {...}
}
``````

每个节点都有如下所示的接口：

``````json
interface Node {
  type: string;
}
``````

type:节点的类型；每一种类型的节点定义了一些附加属性来进一步描述该节点

```
{
  type: ...,
  start: 0,
  end: 38,
  loc: {
    start: {
      line: 1,
      column: 0
    },
    end: {
      line: 3,
      column: 1
    }
  },
  ...
}
```

每一个节点都会有 `start`，`end`，`loc` 这几个属性。

#### Babel的处理步骤

1. 解析(parse)
   - 词法分析：词法分析阶段把字符串形式的代码转换为 **令牌（tokens）** 流。.
     - 语法分析：**语法分析阶段会把一个令牌流转换成 AST 的形式。 **这个阶段会使用令牌中的信息把它们转换成一个 AST 的表述结构，这样更易于后续的操作。
2. 转换(transform)：转换步骤接收 AST 并对其进行遍历，在此过程中对节点进行添加、更新及移除等操作。
3. 生成(generate)：深度优先遍历整个 AST，然后构建可以表示转换后代码的字符串。还会创建源码映射(source maps)

#### 遍历

对需要转换为AST的节点进行**树形遍历**，比方说我们有一个 `FunctionDeclaration` 类型。它有几个属性：`id`，`params`，和 `body`，每一个都有一些内嵌节点。

```
{
  type: "FunctionDeclaration",
  id: {
    type: "Identifier",
    name: "square"
  },
  params: [{
    type: "Identifier",
    name: "n"
  }],
  body: {
    type: "BlockStatement",
    body: [{
      type: "ReturnStatement",
      argument: {
        type: "BinaryExpression",
        operator: "*",
        left: {
          type: "Identifier",
          name: "n"
        },
        right: {
          type: "Identifier",
          name: "n"
        }
      }
    }]
  }
}
```

于是我们从 `FunctionDeclaration` 开始并且我们知道它的内部属性（即：`id`，`params`，`body`），所以我们依次访问每一个属性及它们的子节点。

接着我们来到 `id`，它是一个 `Identifier`。`Identifier` 没有任何子节点属性，所以我们继续。

之后是 `params`，由于它是一个数组节点所以我们访问其中的每一个，它们都是 `Identifier` 类型的单一节点，然后我们继续。

此时我们来到了 `body`，这是一个 `BlockStatement` 并且也有一个 `body`节点，而且也是一个数组节点，我们继续访问其中的每一个。

这里唯一的一个属性是 `ReturnStatement` 节点，它有一个 `argument`，我们访问 `argument` 就找到了 `BinaryExpression`。.

`BinaryExpression` 有一个 `operator`，一个 `left`，和一个 `right`。 Operator 不是一个节点，它只是一个值因此我们不用继续向内遍历，我们只需要访问 `left` 和 `right`。.

**Babel 的转换步骤全都是这样的遍历过程。**

#### Visitors(访问者)

访问者是一个用于AST遍历的跨语言的模式。它们就是**一个对象**，在这个对象定义了用于在树形结构中获取具体节点的方法。

例子：

```js
const MyVisitor = {
  Identifier() {
    console.log("Called!");
  }
};

// 你也可以先创建一个访问者对象，并在稍后给它添加方法。
let visitor = {};
visitor.MemberExpression = function() {};
visitor.FunctionDeclaration = function() {}
```

> **注意**： `Identifier() { ... }` 是 `Identifier: { enter() { ... } }` 的简写形式。.

这是一个简单的访问者，把它用于遍历中时，每当在树中遇见一个 `Identifier` 的时候会调用 `Identifier()` 方法。

#### Paths(路径)

Path是表示两个节点之间连接的对象。当我们通过成员方法例如Identifier(),实际上是访问路径而非节点。

```js
const MyVisitor = {
  Identifier(path) {
    console.log("Visiting: " + path.node.name);
  }
};
```

#### 几个重要的API

##### traverse(解析后的生成的ast, enter/exit(path)...)

该API用于遍历树形结构，也是在这里对代码进行更新和增删操作，例子：

```js
const parser = require('@babel/core');
const fs = require('fs');
const type_babel = require("babel-types");
const traverse = require('@babel/traverse').default;
const code = `function square(n) {
  return n * n;
}`;

const ast = parser.parse(code);

traverse(ast, {
    enter(path){
        if(type_babel.isIdentifier(path.node, {name: 'n'})){
            path.node.name = 'x';
            console.log(path.toString());
        }
    }
});
```

##### generate(被解析的code且被遍历的ast对象, {}对象内部可以放置一些参数,被解析的code)

第二个参数可填入的对象：

![image-20200602155730971](https://i.loli.net/2020/06/02/bGqD68XRnUh3oiT.png)

![image-20200602155742905](https://i.loli.net/2020/06/02/xBeQ3zyNwrUuIgc.png)

示例：

```js
const parser = require('@babel/core');
const fs = require('fs');
const type_babel = require("babel-types");
const generate = require("babel-generator").default;
const traverse = require('@babel/traverse').default;
const code = `function square(n) {
  return n * n;
}`;

const ast = parser.parse(code);

traverse(ast, {
    enter(path){
        if(type_babel.isIdentifier(path.node, {name: 'n'})){
            path.node.name = 'x';
            console.log(path.toString());
        }
    }
});
console.log(generate(ast, {retainLines: false,
    compact: "auto",
    concise: false,
    quotes: "double",}, code).code);

fs.writeFile('ast.json',JSON.stringify(ast, null, '\t'), (err)=>{});
```