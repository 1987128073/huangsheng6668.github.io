 <div>
   <span id="sitetime"></span>
   // 这里我没有好办法吧swig的值传到JavaScript代码中。如果您会，请帮我改进。
   <span id="year" style="display:none">{{theme.footer.runtime.year}}</span> 
   <span id="month" style="display:none">{{theme.footer.runtime.month}}</span>   
   <span id="day" style="display:none">{{theme.footer.runtime.day}}</span>   
   <span id="hour" style="display:none">{{theme.footer.runtime.hour}}</span>   
   <span id="minute" style="display:none">{{theme.footer.runtime.minute}}</span>   
   <span id="second" style="display:none">{{theme.footer.runtime.second}}</span>   
	<script language=javascript>
	function siteTime(){        
		window.setTimeout("siteTime()", 1000);
		var seconds = 1000;
		var minutes = seconds * 60;
		var hours = minutes * 60;
		var days = hours * 24;
		var years = days * 365;
		var today = new Date();
		var todayYear = today.getFullYear();
		var todayMonth = today.getMonth()+1;
		var todayDate = today.getDate();
		var todayHour = today.getHours();
		var todayMinute = today.getMinutes();
		var todaySecond = today.getSeconds();
		/* Date.UTC() -- 返回date对象距世界标准时间(UTC)1970年1月1日午夜之间的毫秒数(时间戳)
		year - 作为date对象的年份，为4位年份值
		month - 0-11之间的整数，做为date对象的月份
		day - 1-31之间的整数，做为date对象的天数
		hours - 0(午夜24点)-23之间的整数，做为date对象的小时数
		minutes - 0-59之间的整数，做为date对象的分钟数
		seconds - 0-59之间的整数，做为date对象的秒数
		microseconds - 0-999之间的整数，做为date对象的毫秒数 */        
		var year = document.getElementById("year").innerHTML;
		var month = document.getElementById("month").innerHTML;
		var day = document.getElementById("day").innerHTML;
		var hour = document.getElementById("hour").innerHTML;
		var minute = document.getElementById("minute").innerHTML;
		var second = document.getElementById("second").innerHTML;//北京时间2018-2-13 00:00:00
		var t1 = Date.UTC(year,month,day,hour,minute,second); 
		var t2 = Date.UTC(todayYear,todayMonth,todayDate,todayHour,todayMinute,todaySecond);
		var diff = t2-t1;
		var diffYears = Math.floor(diff/years);
		var diffDays = Math.floor((diff/days)-diffYears*365);
		var diffHours = Math.floor((diff-(diffYears*365+diffDays)*days)/hours);
		var diffMinutes = Math.floor((diff-(diffYears*365+diffDays)*days-diffHours*hours)/minutes);
		var diffSeconds = Math.floor((diff-(diffYears*365+diffDays)*days-diffHours*hours-diffMinutes*minutes)/seconds);
		if(diffYears==0){
		document.getElementById("sitetime").innerHTML=" Website has run  "/*+diffYears+" year "*/+diffDays+" days "+diffHours+" h "+diffMinutes+" min "+diffSeconds+" s";
		} else{
		document.getElementById("sitetime").innerHTML=" Website has run  "+diffYears+" year "+diffDays+" days "+diffHours+" h "+diffMinutes+" min "+diffSeconds+" s";
		}
	}
	//siteTime(document.getElementById("year").innerHTML,document.getElementById("year").innerHTML,document.getElementById("year").innerHTML,document.getElementById("year").innerHTML,document.getElementById("year").innerHTML,0);
	siteTime();
	</script>
</div>