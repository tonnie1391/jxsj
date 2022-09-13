-- 文件名　：zongzi_def.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-21 14:10:10
-- 描  述  ：

SpecialEvent.ZongZi2011 = SpecialEvent.ZongZi2011 or {};
local tbZongZi = SpecialEvent.ZongZi2011 or {};

-- task id
tbZongZi.TASK_GROUP_ID			= 2143;	-- 任务组ID
tbZongZi.TASK_LAST_BOIL_TIME	= 19;	-- 最近一次煮粽子开始时间
tbZongZi.TASK_BOIL_STATE		= 20;	-- 煮粽子状态，1：可能正在煮 0：没在煮 
tbZongZi.TASK_LAST_BOILED_DAY	= 21;	-- 最后成功煮粽子的日期
tbZongZi.TASK_BOIL_DAY_COUNT	= 22;	-- 当天成功煮粽子个数
tbZongZi.TASK_EAT_TOTAL_COUNT	= 23;	-- 活动期间使用粽子总数

-- const
tbZongZi.OPEN_DAY	= 20100121;		-- 活动开始时间
tbZongZi.CLOSE_DAY	= 20100220;		-- 活动结束时间

tbZongZi.ITEM_GUOZI_ID			= {18, 1, 1121, 1};	-- 锅子
tbZongZi.ITEM_MUCAI_ID			= {18, 1, 1122, 1};	-- 木材
tbZongZi.ITEM_ZONGZI_ID			= {18, 1, 1123, 1};	-- 粽子
tbZongZi.ITEM_BENXIAO_ID		= {1, 12, 35, 4};	-- 奔宵

tbZongZi.ITEM_VALIDITY_BENXIAO	= 3 * 30 * 24 * 3600;-- 奔宵有效期
tbZongZi.ITEM_VALIDITY_ZONGZI	=  30 * 24 * 3600;	-- 粽子有效期

tbZongZi.BOIL_STEP_BOILED		= 3;	-- 煮熟阶段
tbZongZi.BOIL_STEP_NPC	=	--	各阶段npc的ID
{
	[1] = 7277,	-- 火
	[2] = 7277,	-- 锅
	[3] = 7277,	-- 锅
};

tbZongZi.BOIL_STEP_MSG	=	-- 各阶段提示
{
	[1] = {szStep = "您的锅子已经开始煮粽子了", szAlert = "你的锅还有<color=yellow>%s秒<color>就要熄火了，赶快添木柴啊！！", szMsgActived = "再等<color=yellow>%s秒<color>才能加木柴"},
	[2] = {szStep = "火不够旺了，赶快加点木柴吧", szAlert = "你的锅还有<color=yellow>%s秒<color>就要熄火了，赶快添木柴啊！！", szFlameOut = "真遗憾，你煮粽子的火已经熄灭了，下次要仔细点呀！！", szMsgActived = "再等<color=yellow>%s秒<color>才能收获", szMsgNoActive = "快快加木柴，不然再<color=yellow>%s秒<color>后会熄火"},
	[3] = {szStep = "粽子已经煮熟了，可以收获了", szAlert = "你的锅子再过<color=yellow>%s秒<color>就要消失了，赶快收获啊！！", szFlameOut = "真遗憾，你煮粽子的锅因为时间到消失了，下次要及时收获呀！！", szMsgNoActive = "快快收获，不然锅子会在<color=yellow>%s秒<color>后消失"},	
};

tbZongZi.MAX_BOIL_DAY_COUNT		= 5;	-- 每天最多5次
tbZongZi.MAX_BOIL_TOTAL_COUNT	= 100;	-- 活动期间最多能使用100个
tbZongZi.LEVEL_LIMIT			= 60;	-- 玩家等级限制
tbZongZi.ALERT_TIME				= 20;	-- 熄火前20秒提示
tbZongZi.EXP_TIME				= 5;	-- 每5秒给一次经验
tbZongZi.BASE_EXP_MULTIPLE		= 0.5;	-- 经验倍率
tbZongZi.RANGE_EXP				= 45;	-- 组队组粽子经验范围
tbZongZi.BENXIAO_MAXVALUE		= 10000;-- 随奔宵的最大值，与下面的值一起组成概率
tbZongZi.BENXIAO_PROBABILITY	= 1;	-- 出现的概率，范围从1到BENXIAO_MAXVALUE
tbZongZi.MAX_BENXIAO_COUNT		= 10;	-- 最多随奔宵的个数

tbZongZi.RANDOM_ITEM_ID			= 147;	-- 随机物品编号

tbZongZi.BOIL_STEP_TIME	=
{
	[1] = 60,	-- 激活
	[2] = 60,	-- 加柴
	[3] = 60,	-- 收获
};
tbZongZi.BOIL_CD_TIME			= 180;	-- 熄火之后需要等足时间
