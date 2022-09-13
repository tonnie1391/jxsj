召唤npc说明				
字段名	描述	格式	类型	说明
EventId	总活动ID	n	整型	"总活动ID,关键字,不能重复"
EventName	活动名	String	整型	"活动名,如果有npc活动,将会做为npc处对话选项"
EventDescript	活动描述	String	整型	"活动描述,如果有npc活动,将会做为npc处对话描述"
EventStartDate	开始时间	YYYY/mm/dd/HH/MM或YYYY/mm/dd	整型	"开始时间,0或空为永久开启;YYYY-mm-dd HH:MM:00 开启活动"
EventEndDate	结束时间	YYYY/mm/dd/HH/MM或YYYY/mm/dd	整型	"结束时间,0或空为永久开启;YYYY-mm-dd HH:MM:00 结束活动"
EventTable	活动表路径	String	整型	eventpart活动表连接路径
TaskIdBegin	使用起始任务变量	n	整型	该活动使用的任务变量起始段
TaskIdEnd	使用结束任务变量	n	整型	该活动使用的任务变量结束段
