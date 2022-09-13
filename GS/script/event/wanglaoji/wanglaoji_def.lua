--王老吉活动
--孙多良
--2008.08.25

if not SpecialEvent.WangLaoJi then
	SpecialEvent.WangLaoJi = {};
end

local WangLaoJi = SpecialEvent.WangLaoJi;

WangLaoJi.TIME_STATE =
{
	20080916,
	20081104,
	20081110,
	20081116,
}

WangLaoJi.TIME_STATE_NEW =
{
	20080916,
	20081111,
	20081125,
	20081203,
	20081226,
}

--周期
WangLaoJi.TIME_STATE_WEEK =
{
	[20080923] = 1,
	[20080930] = 2,
	[20081007] = 3,
	[20081014] = 4,
	[20081021] = 5,
	[20081028] = 6,
	[20081104] = 7,
	[20081111] = 8,
	[20081118] = 9,
	[20081125] = 10,
}

--周期显示使用。
WangLaoJi.WEEK_MSG =
{
	[1] = "(09/23)",
	[2] = "(09/30)",
	[3] = "(10/07)",
	[4] = "(10/14)",
	[5] = "(10/21)",
	[6] = "(10/28)",
	[7] = "(11/04)",
	[8] = "(11/11)",
	[9] = "(11/18)",
	[10]= "(11/25)",
}

--记录每周第一名
WangLaoJi.KEEP_SORT =
{
	[1] = DBTASD_EVENT_KEEP01,
	[2] = DBTASD_EVENT_KEEP02,
	[3] = DBTASD_EVENT_KEEP03,
	[4] = DBTASD_EVENT_KEEP04,
	[5] = DBTASD_EVENT_KEEP05,
	[6] = DBTASD_EVENT_KEEP06,
	[7] = DBTASD_EVENT_KEEP07,
	[8] = DBTASD_EVENT_KEEP08,
	[9] = DBTASD_EVENT_KEEP09,
	[10]= DBTASD_EVENT_TEMP_01,
}

WangLaoJi.TASK_GROUP = 2047;
WangLaoJi.TASK_GRAGE = 1;	--积分
WangLaoJi.TASK_WEEK	 = 2; 	--进行到第几周; 
WangLaoJi.TASK_AWARD = 3;	--领取最终奖励标志; 
WangLaoJi.TASK_EXAWARD = 14;	--领取周排名额外奖励标志
WangLaoJi.TASK_WEEK_AWARD =  
{
	--领取周奖励对应任务变量表
	[1] = 4,
	[2] = 5,
	[3] = 6,
	[4] = 7,
	[5] = 8,
	[6] = 9,
	[7] = 10,
	[8] = 11,
	[9] = 12,
	[10] = 13,
}

WangLaoJi.DEF_WEEK_GRAGE = 5000; --第一名且达到5000分才获得本周第一名
WangLaoJi.DEF_CARD_GRAGE = 10; --使用卡片获得积分
WangLaoJi.DEF_WEEK_EXGRAGE 		= 15000; --周排名，超过15000分可额外获得一个令牌
WangLaoJi.DEF_WEEK_EXPREGRAGE 	= 10000; --每多10000分，额外多获得一个令牌
WangLaoJi.CAN_GETCARD_FLAG = 0; --宋金获得卡片标志。1为可获得（该功能使用活动系统完成）

WangLaoJi.ITEM_CARD = {18,1,194,1} ; --王老吉降火卡
WangLaoJi.ITEM_TOKEN = {18,1,179,1}; --白银腰带令牌；
WangLaoJi.ITEM_XUANJIN = {18,1,1,7}; --七玄；
WangLaoJi.ITEM_TOKEN500 = {18,1,179,3}; --500点声望令牌；

WangLaoJi.NEWS_INFO = 
{
	{
		nKey = 13,
		szTitle = "庆国庆-王老吉凉茶活动",
		szMsg = [[
活动时间：<color=yellow>9月17日维护后 — 11月04日 0：00<color>
    
活动内容：
    活动期间，打到野外怪物可能掉落<color=green>王老吉凉茶<color>，在篝火时使用<color=green>王老吉凉茶<color>，全队都可以获得10%的篝火经验加成，持续5分钟。（重复使用不叠加）
]],
	},
	{
		nKey = 14,
		szTitle = "庆国庆-江湖防上火行动",
		szMsg = [[
活动时间：<color=yellow>9月17日维护后 — 11月25日 0：00<color>
    
领奖时间：<color=yellow>12月02日24：00前 <color>
    
活动内容：
    在活动期间，参加白虎堂，宋金活动可以有机会获得<color=green>王老吉降火卡<color>
    白虎堂杀死每层的Boss将会掉落<color=green>王老吉降火卡<color>
    宋金战场获得7000分以上的玩家将会获得<color=green>王老吉降火卡<color>
    宋金战场获得3000到6999分之间的玩家将会有一定几率获得<color=green>王老吉降火卡<color>
    <color=green>王老吉降火卡<color>掉落截止时间11月04日0点。
        
收集活动：
    在整个活动期间，每周<color=yellow>（周二0点到下周二0点）积分第一<color>，并且<color=yellow>积分不低于5000分<color>，将会成为本周头名，可获得盛夏活动白银令牌（获得绑定），使用后可在<color=yellow>汴京逍遥谷客商<color>购买如下奖励：
      <color=gold>华夏腾龙束腰（男）<color>
      <color=gold>华夏飞凤玉带（女）<color>
				
    获得盛夏活动白银令牌的玩家，积分将会清空，其他玩家可以保留积分继续参加下一周的竞争
    活动结束时， <color=yellow>最终排名2—20<color>的玩家，可以获得如下奖励：
      <color=green>7级玄晶（绑定）<color>
      
    领奖请到各大城市找<color=yellow>盛夏活动推广员<color>领取奖励。
				
    另外，所有腰带获得者和最终排名前20位的玩家，还有机会获得由王老吉送出的线下奖励，包括：
      <color=green>笔记本电脑<color>
      <color=green>MP3<color>
      <color=green>王老吉凉茶（箱）<color>
				
]],	
	},
	{
		nKey = 15,
		szTitle = "江湖防上火行动延长周",
		szMsg = [[
活动时间：<color=yellow>11月4日0时 — 11月25日0时<color>
    
领奖时间：<color=yellow>12月02日24：00前 <color>
    
活动内容：
    自从江湖防上火行动开启以来，玩家积极参与，总积分不断攀高。本服务器总积分和已经到达开启“<color=yellow>江湖防上火行动延长周<color>”的条件，因此本服务器将自动延长“<color=yellow>江湖防上火行动<color>”<color=green>3周<color>。
    细则如下：
    1、“王老吉降火卡”有效期自动延长一周。在<color=yellow>11月11日0时<color>之前使用的“王老吉降火卡”仍然会获得10点积分。
    2、“江湖防上火行动”截止日期自动<color=green>延后3周<color>。活动截止日期自动延长到<color=yellow>11月25日0时<color>。期间，每周（周二0点到下周二0点）积分第一，且总积分不低于5000分的玩家，将会获得“<color=yellow>盛夏活动白银令牌<color>”（获得绑定）。
    3、获得盛夏活动白银令牌的玩家，积分将会清空，其他玩家可以保留积分继续参加下一周的竞争
    4、活动结束时，<color=yellow>最终排名2—20<color>的玩家，可以获得如下奖励：<color=yellow>
      名次  奖励
      2-20  7级玄晶（绑定）<color>
]],	
	},	
	
}