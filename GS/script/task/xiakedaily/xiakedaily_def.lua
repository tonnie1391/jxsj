-- 文件名　：xiakedaily.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-05 15:01:10
-- 描  述  ：侠客日常任务

XiakeDaily._OPEN			= 1;				-- 系统开关

XiakeDaily.TASK_MAIN_ID		= 60000;			-- 主任务ID
XiakeDaily.TEXT_NAME		= "[Nhiệm vụ Hiệp Khách]";	-- 主任务名称
XiakeDaily.ACCEPT_NPC_ID	= 3569;				-- 接任务NPC

XiakeDaily.TASK_GROUP		= 2159;				-- 任务组ID
XiakeDaily.TASK_ACCEPT_DAY	= 1;				-- 身上的任务日期
XiakeDaily.TASK_ACHIEVE_DAY	= 2;				-- 最后一次交任务时间
XiakeDaily.TASK_STATE		= 3;				-- 任务状态，0可接任务，1有任务，2今日任务已领奖,3不可接任务
XiakeDaily.TASK_FIRST_TARGET= 4;				-- 目标1状态,0未完成，1完成
XiakeDaily.TASK_SECOND_TARGET=5;				-- 目标2状态，0未完成，1完成
XiakeDaily.TASK_WEEK_COUNT	= 6;				-- 本周完成次数
XiakeDaily.TASK_TARGET1_ID	= 7;				-- 第一个任务id
XiakeDaily.TASK_TARGET2_ID	= 8;				-- 第二个任务id
XiakeDaily.TASK_WEEK		= 9;				-- 第几周
XiakeDaily.TASK_ACCEPT_COUNT= 10;				-- 今日剩余可以接取次数

XiakeDaily.FILE_TASK_INI_PATH	= "\\setting\\task\\xiakedaily\\taskini.txt";	-- 任务配置表				-- ；

XiakeDaily.REFRESH_TIME		= 30000;	-- 任务刷新时间

XiakeDaily.TYPE_FUBENID		=		-- 类型对应的副本id
{
	[1] = {1, 2, 3, 9},	-- 军营
	[2] = {4, 5, 6, 8},	-- 藏宝图
	[3] = {7},			-- 逍遥谷
};

XiakeDaily.RANDOM_TYPEID		=	-- 一周的每天在固定两种任务类型来随机
{
	[1]	= {1, 2},
	[2] = {1, 3},
	[3] = {2, 3},
	[4] = {1, 2},
	[5] = {1, 3},
	[6] = {2, 3},
	[0] = {1, 3},
};

XiakeDaily.DETAIL_TO_INDEX = 
{
	[1] = 
	{
		[1] = 1,	-- 后山
		[2] = 2,	-- 百蛮
		[3] = 3,	-- 海王
		[4] = 4,	-- 鄂伦河源
	},	
	[2] = 
	{
		[32] = 1, 	-- 2星大漠古城
		[42] = 2,	-- 2星万花谷	
		[52] = 3,	-- 2星千琼宫
		[62] = 4,	-- 2星龙门飞剑
	},
	[3] = 
	{
		[1] = 1,
		[3]	= 1,	-- 困难逍遥谷
		[5] = 1,
		[7] = 1,	
	},
};

XiakeDaily.ID_TO_IMAGE	=
{
	[1] = "<pic=image\\item\\other\\scriptitem\\funiushan_vn.spr>",	
	[2] = "<pic=image\\item\\other\\scriptitem\\baimanshan_vn.spr>",	
	[3] = "<pic=image\\item\\other\\scriptitem\\hailingwangmu_vn.spr>",	
	[4] = "<pic=image\\item\\other\\scriptitem\\damogucheng_vn.spr>",	
	[5] = "<pic=image\\item\\other\\scriptitem\\wanhuacangbaotu_vn.spr>",	
	[6] = "<pic=image\\item\\other\\scriptitem\\qianqionggongcangbaotu_vn.spr>",	
	[7] = "<pic=image\\item\\other\\scriptitem\\xiaoyaogu_vn.spr>",	
	[8] = "<pic=image\\item\\other\\scriptitem\\longmenfeijian_vn.spr>",		
	[9]	= "<pic=image\\item\\other\\scriptitem\\elunheyuan_vn.spr>",
	-- [10]= "<pic=image\\item\\other\\scriptitem\\suijicangbaotu_vn.spr>",
};

XiakeDaily.TASK_TREASUREMAP2_GROUPID	=
{
	[4] = {2203, 5},
	[5] = {2203, 6},
	[6] = {2203, 7},
	[8] = {2203, 8},	
};

XiakeDaily.AWARDEX_WEEK_TIMES 	= 5;	-- 额外奖励次数
XiakeDaily.WEEK_MAX_TIMES		= 5;	-- 每周最多完成次数
XiakeDaily.DAY_ACCEPT_TIMES		= 1;	-- 每日可接的次数

XiakeDaily.ITEM_XIAKELING = {18, 1, 1233, 1}; -- 侠客令
XiakeDaily.ITEM_STONE = {18, 1, 1317, 1};	-- 宝石
XiakeDaily.ITEM_STONE_KEY = {18, 1, 1312, 1};	-- 解玉锤

XiakeDaily.AWARD_ONCE			= 2;	-- 单次奖励
XiakeDaily.AWARD_EXTRA			= 4;	-- 额外奖励
XiakeDaily.LEVEL_LIMIT			= 100;	-- 等级限制
XiakeDaily.PRESTIGE_REPUTE		= 6;	-- 江湖威望
XiakeDaily.AWARD_STONE			= 3;	-- 赠送宝石个数
XiakeDaily.AWARD_STONE_KEY		= 2;	-- 赠送解玉锤个数
XiakeDaily.DROPRATE				=  "\\setting\\npc\\droprate\\renwudiaoluo\\junying_newboss.txt";

XiakeDaily.TASK_ITEM_TIME = 27 * 60 * 60;	--侠客令牌的时间,当天的秒数+到隔天3点的秒数