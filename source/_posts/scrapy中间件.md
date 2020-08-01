#### Scrapy中间件

学习之前我们先看看Scrapy的整体结构
![picture 3](http://img.juziss.cn/4480248372d63f6a423447c25b8ff80dfa0a8a94666c070cb1435cc9ba2530a8.png)  

结构示意：
1. Spiders(爬虫):它负责处理所有Responses,从中分析提取数据，获取Item字段需要的数据，并将需要跟进的URL提交给引擎，再次进入Scheduler(调度器)
2. Engine(引擎)：负责Spider、ItemPipeline、Downloader、Scheduler中间的通讯，信号、数据传递等。
3. Scheduler(调度器)：它负责接受引擎发送过来的Request请求，并按照一定的方式进行整理排列，入队，当引擎需要时，交还给引擎。
4. Downloader(下载器)：负责下载Scrapy Engine(引擎)发送的所有Requests请求，并将其获取到的Responses交还给Scrapy Engine(引擎)，由引擎交给Spider来处理
5. ItemPipeline(管道):它负责处理Spider中获取到的Item，并进行进行后期处理（详细分析、过滤、存储等）的地方.
6. Downloader Middlewares（下载中间件）：你可以当作是一个可以自定义扩展下载功能的组件。
7. Spider Middlewares（Spider中间件）：你可以理解为是一个可以自定扩展和操作引擎和Spider中间
8. 通信的功能组件（比如进入Spider的Responses;和从Spider出去的Requests）

我们今天的重点主要是*中间件*。

##### 下载中间件
> 下载器中间件是介于Scrapy的request/response处理的钩子框架，是用于全局修改Scrapy request和response的一个轻量、底层的系统。

以上是官方文档的释义。

但是实际上可以简单理解为用于**更换代理IP，更换Cookies，更换User-Agent，自动重试**的中间件。

有了下载中间件的请求和响应的流程编程了：
![picture 4](http://img.juziss.cn/c015301e541375d9d32698fda01c5b340e68ce4d1be03487ccf08fa94c6de4bd.png)  

##### 如何开发一个下载中间件
每个Scrapy项目建立好时，都会有一个叫做**middlewares.py**的这样一个文件，打开之后是这样
![picture 5](http://img.juziss.cn/0d725faa5955b6bc15d4e743b5d017c7cf2339e4df90aa086632715117b920b2.png)  

我们每新建一个中间件，都需要在这个文件里面新建一个类，比如说我们这里新建一个代理中间件。

```
class ProxyMiddleware(object):

    def process_request(self, request, spider):
        proxy = random.choice(settings['PROXIES'])
        request.meta['proxy'] = proxy

```
ps: Request中meta参数的作用是传递信息给下一个函数

我们这里就设置好了一个从固定代理里随机获取一个代理并设置给request的这样一个代理类。其他细节不是我们要讲的重点，不过有个重点细节。

settings.py这个文件里的这个位置
```
# Enable or disable downloader middlewares
# See http://scrapy.readthedocs.org/en/latest/topics/downloader-middleware.html
#DOWNLOADER_MIDDLEWARES = {
#    'AdvanceSpider.middlewares.MyCustomDownloaderMiddleware': 543,
#}
```
这里的DOWNLOADER_MIDDLEWARES中的内容替换为*'AdvanceSpider.middlewares.ProxyMiddleware': 543,*

后面的数字表示这种中间件的顺序（数字越小这里request的优先级越高）。由于中间件是按顺序运行的，因此如果遇到后一个中间件依赖前一个中间件的情况，中间件的顺序就至关重要。

顺序最好不要瞎写，最好是要清楚Scrapy自带的中间件的顺序：
![picture 6](http://img.juziss.cn/ba4e077c217aa8c27bb54a82f37e7485ff8c2d8f969e1dbc3b4820377a68f495.png)  

**Scrapy其实自带了UA中间件（UserAgentMiddleware）、代理中间件（HttpProxyMiddleware）和重试中间件（RetryMiddleware）。所以，从“原则上”说，要自己开发这3个中间件，需要先禁用Scrapy里面自带的这3个中间件。**

```
DOWNLOADER_MIDDLEWARES = {
  'AdvanceSpider.middlewares.ProxyMiddleware': 543,
  'scrapy.contrib.downloadermiddleware.useragent.UserAgentMiddleware': None,
  'scrapy.contrib.downloadermiddleware.httpproxy.HttpProxyMiddleware': None
}
```

###### 为何为“原则上”
![picture 7](http://img.juziss.cn/43670f5bcf56420b0e52dd39b7d82942fefe04bd279b1d3281562b3d9fe451f3.png)  

当request['proxy']存在，则这个代理中间件会立即返回而不会覆盖之前我们自己设计的代理中间件的代理。

##### 一定要把代理写在setting吗？
不是的，可以通过把代理写到数据库或redis中，