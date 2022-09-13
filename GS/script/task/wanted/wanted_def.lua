--官府通缉任务
--孙多良
--2008.08.06

Wanted.TASK_MAIN_ID = 50001;		--主任务Id
Wanted.TEXT_NAME	= "[Truy nã Hải tặc]";--主任务名称
Wanted.ACCEPT_NPC_ID= 2994;			--接任务npc

Wanted.Day_COUNT	= 6;	--每天累计6次;

Wanted.nRandomTask  = 0;	--初始随机
Wanted.TASK_GROUP 	  = 2040;	--任务变量组；
Wanted.TASK_ACCEPT_ID = 1;		--已接任务ID
Wanted.TASK_COUNT  	  = 2;		--已剩任务次数；
Wanted.TASK_FIRST  	  = 3;		--更新后或新建角色当天给予6次标志；
Wanted.TASK_LEVELSEG  = 4;		--接任务等级段；
Wanted.TASK_FINISH    = 7;		--是否已完成目标；1,未完成,0已完成或没有任务

Wanted.TASK_100SEG_RANLEVEL  = 22;		--高级任务时随机碎片等级
Wanted.TASK_ACCEPT_TIME	  	 = 23;		--记录接任务的时间

Wanted.LIMIT_COUNT_MAX	= 36;	--最大累计36次;
Wanted.LIMIT_LEVEL		= 50;	--等级限制;
Wanted.LIMIT_REPUTE		= 20;	--江湖威望限制;

Wanted.ITEM_WULINMIJI = {{18,1,191,1}, 300} --武林秘籍(初级) ID,换取所需名捕令数量
Wanted.ITEM_XISUIJING = {{18,1,192,1}, 300} --洗髓经(初级)  ID,换取所需名捕令数量
Wanted.ITEM_MINGBULING = {18,1,190,1} --名捕令
Wanted.ITEM_MINGBUXIANG = {18,1,1026} --名捕材料（1-5级）
Wanted.ITEM_CALLBOSSLP 	= {18,1,1025,1} --名捕boss召唤令牌

Wanted.DEF_PAYGTP	= 1200;	--兑换令牌需活力1200点
Wanted.DEF_PAYMKP	= 1200;	--兑换令牌需精力1200点
Wanted.DEF_DATE_START	= 0600;	--开始时间
Wanted.DEF_DATE_END		= 0200;	--结束时间


--记录完成次数和上次次数变量
Wanted.DEF_SAVE_TASK = 
{
	--等级 = {本周次数, 上周次数}
	[1] = {DBTASD_WANTED_LV1_WEEKTASK_COUNT, DBTASD_WANTED_LV1_LASTWEEKTASK_COUNT},
	[2] = {DBTASD_WANTED_LV2_WEEKTASK_COUNT, DBTASD_WANTED_LV2_LASTWEEKTASK_COUNT},
	[3] = {DBTASD_WANTED_LV3_WEEKTASK_COUNT, DBTASD_WANTED_LV3_LASTWEEKTASK_COUNT},
	[4] = {DBTASD_WANTED_LV4_WEEKTASK_COUNT, DBTASD_WANTED_LV4_LASTWEEKTASK_COUNT},
	[5] = {DBTASD_WANTED_LV5_WEEKTASK_COUNT, DBTASD_WANTED_LV5_LASTWEEKTASK_COUNT},
	[6] = {DBTASD_WANTED_LV6_WEEKTASK_COUNT, DBTASD_WANTED_LV6_LASTWEEKTASK_COUNT},
}

--定义高级大盗
Wanted.DEF_Adv_LEVEL = {
	[6] = 1,	--高级
};

Wanted.AWARD_LIST =
{
	[1] = 1,	--50级任务奖励名捕令个数
	[2] = 2,	--60级任务奖励名捕令个数
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 0,
	[7] = 0,
	[8] = 0,
}

Wanted.AWARD_LIST2 =
{
	[6] = 1,	--奖励随机材料
}

Wanted.DROPLUCK = 100; --掉落随机装备获得魔法属性额外增加幸运值。
Wanted.DROPRATE =
{
	[55] = "\\setting\\npc\\droprate\\guanfutongji\\tongji_lv55.txt",	--55级boss掉落表
	[65] = "\\setting\\npc\\droprate\\guanfutongji\\tongji_lv65.txt",	--65级boss掉落表
	[75] = "\\setting\\npc\\droprate\\guanfutongji\\tongji_lv75.txt",	--75级boss掉落表
	[85] = "\\setting\\npc\\droprate\\guanfutongji\\tongji_lv85.txt",	--85级boss掉落表
	[95] = "\\setting\\npc\\droprate\\guanfutongji\\tongji_lv95.txt",	--95级boss掉落表
	[120] = 0,	--无掉落
}

--每天重新随机阶段
Wanted.RANDOM_SEG_LIST = 
{
	1,
	2,
	3,
	4,
	5,
	6,
};

--玩家行为类型表，对应正常奖励还是工作室奖励
Wanted.ACTION_KIND = 
{
	[0] =0,--正常玩家
	[1] =0,--正常玩家
	[2] =0,
	[3] =0,
	[4] =1,
	[5] =1,--工作室
	[6] =1,
	[7] =1,
};

--工作室和大盗接任务随机数
Wanted.DEF_ACTION_KIND	=  
{
	[0] = 12, --正常玩家可以12个里面随机
	[1] = 2, --工作室在2个里面随机
}
