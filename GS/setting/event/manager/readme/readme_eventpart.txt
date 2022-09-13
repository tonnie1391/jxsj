活动组合表:		
字段名	参数	说明
PartId	keyInt	"活动ID,关键字,不能重复."
Name	szStr	"活动名,如有npc对话做为npc对话选项"
ExClass	szStr	"扩展类,不填则使用基类,详情请查看script\event\exclass\default.lua"
Kind	"szStr,见下活动类型表"	活动大类
SubKind	"szStr,见下活动类型表"	活动小类
StartDate	YYYY/mm/dd/HH/MM	YYYY-mm-dd HH:MM:00 开启活动
StartDate	YYYY/mm/dd	YYYY-mm-dd 00:00:00 开启活动
EndDate	YYYY/mm/dd/HH/MM	YYYY-mm-dd HH:MM:00 结束活动
EndDate	YYYY/mm/dd	YYYY-mm-dd 24:00:00 结束活动
ExParam1	见下ExParam表	参数表
...	见下ExParam表	参数表
ExParam20	见下ExParam表	参数表
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
DropPath	Path	
Txt	szStr	
AwardPath	Path	
MapPath	Path	
UiAwardPath	Path	
Double	n	
		
"字段名和参数之间用"":""分隔"	"例:Task:MaxCount,TaskId"	
"参数之间用"",""分隔"	"例:TimerStart:HHMM,HHMM"	
