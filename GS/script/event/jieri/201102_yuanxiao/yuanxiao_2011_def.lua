-------------------------------------------------------
-- 文件名　：yuanxiao_2011_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-05 16:27:11
-- 文件描述：
-------------------------------------------------------

local tbYuanxiao_2011 = SpecialEvent.Yuanxiao_2011 or {};
SpecialEvent.Yuanxiao_2011 = tbYuanxiao_2011;

-- task
tbYuanxiao_2011.TASK_GID			= 	2152;		-- 任务变量组
tbYuanxiao_2011.TASK_USE_DINNER		=	1;
tbYuanxiao_2011.TASK_EAT_DINNER		=	2;
tbYuanxiao_2011.TASK_AWARD_TYPE		=	3;
tbYuanxiao_2011.TASK_START_LEVEL	=	4;
tbYuanxiao_2011.TASK_STEP_LEVEL		=	5;
tbYuanxiao_2011.TASK_TOTAL_USE		=	6;
tbYuanxiao_2011.TASK_TOTAL_EAT		=	7;

-- const
tbYuanxiao_2011.MAX_USE_DINNER		=	3;
tbYuanxiao_2011.MAX_EAT_DINNER		=	12;
tbYuanxiao_2011.MAX_TOTAL_USE		= 	30;
tbYuanxiao_2011.MAX_TOTAL_EAT		=	120;
tbYuanxiao_2011.MAX_DINNER_FOOD		=	5;
tbYuanxiao_2011.STEP_RATE			=	30;
tbYuanxiao_2011.MAX_STEP_LEVEL		=	6;
tbYuanxiao_2011.MAX_TYPE			=	4;
tbYuanxiao_2011.MAX_START_LEVEL		=	3;

-- npcid
tbYuanxiao_2011.NPC_TABLE_ID		=	6734;

-- itemid
tbYuanxiao_2011.ITEM_DINNER_ID		=	{18, 1, 720, 1};
tbYuanxiao_2011.ITEM_JADE_ID		=	{18, 1, 722, 1};

-- path
tbYuanxiao_2011.RATE_FILE_PATH 		= 	"\\setting\\event\\jieri\\201102_yuanxiao\\rate.txt";

-- table
tbYuanxiao_2011.TYPE_LEVEL_VALUE	=
{
	[1] = {szName = "级玄晶", tbLevel = {5, 6, 7, 8, 9, 10, 11, 12}};
	[2] = {szName = "魂石", tbLevel = {15, 60, 200, 800, 2500, 10000, 38000, 130000}};
	[3] = {szName = "绑银", tbLevel = {15000, 60000, 200000, 800000, 2500000, 10000000, 38000000, 130000000}};
	[4] = {szName = "绑金", tbLevel = {150, 600, 2000, 8000, 25000, 100000, 380000, 1300000}};
};

function tbYuanxiao_2011:CheckIsOpen()
	local nDate = tonumber(GetLocalDate("%Y%m%d")); 
	if nDate < 20110203 or nDate > 20110217 then
		return 0;
	end
	return 1;
end