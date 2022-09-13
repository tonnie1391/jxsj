-------------------------------------------------------
-- 文件名　：qinshihuang_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-20 14:20:37
-- 文件描述：
-------------------------------------------------------

local tbQinshihuang = Boss.Qinshihuang or {};
Boss.Qinshihuang = tbQinshihuang;

-- 系统开关
tbQinshihuang._bOpen 				= 1;		-- 系统开关
tbQinshihuang.bOpenQinFive 			= 1;		-- 第五层开关(0)

-- 任务变量
tbQinshihuang.TASK_GROUP_ID 		= 2098;		-- 任务变量组
tbQinshihuang.TASK_USE_TIME 		= 1;		-- 每日皇陵使用时间
tbQinshihuang.TASK_START_TIME 		= 2			-- 最后一次皇陵开启时间
tbQinshihuang.TASK_BUFF_LEVEL 		= 3;		-- 正面buff等级
tbQinshihuang.TASK_BUFF_FRAME 		= 4;		-- 正面buff剩余时间
tbQinshihuang.TASK_PROTECT 			= 5;		-- 宕机保护
tbQinshihuang.TASK_REVTIME 			= 8;		-- 重生时间
tbQinshihuang.TASK_REFINE_ITEM 		= 10;		-- 每天使用炼化声望物品的个数(10)

-- 掉落表
tbQinshihuang.BIG_BOSS_DROP_FILE	=	"\\setting\\npc\\droprate\\qinling\\big_boss.txt";
tbQinshihuang.SMALL_BOSS_DROP_FILE	=	"\\setting\\npc\\droprate\\qinling\\small_boss.txt";
tbQinshihuang.SMALL_BOSS_POS_PATH 	= 	"\\setting\\boss\\qinshihuang\\smallboss_pos.txt";

-- 额外掉落
tbQinshihuang.EXTERN_DROP_LEADER_FLOOR2 = {"\\setting\\npc\\droprate\\qinling\\f2_leader_other.txt", 1};
tbQinshihuang.EXTERN_DROP_LEADER_FLOOR3 = {"\\setting\\npc\\droprate\\qinling\\f3_leader_other.txt", 1};
tbQinshihuang.EXTERN_DROP_LEADER_FLOOR4 = {"\\setting\\npc\\droprate\\qinling\\f4_leader_other.txt", 1};
tbQinshihuang.EXTERN_DROP_JINYING		= {"\\setting\\npc\\droprate\\qinling\\specialandboss_other.txt", 1};
tbQinshihuang.EXTERN_DROP_SMALLBOSS 	= {"\\setting\\npc\\droprate\\qinling\\specialandboss_other.txt", 2};
tbQinshihuang.EXTERN_DROP_BIGBOSS 		= {"\\setting\\npc\\droprate\\qinling\\specialandboss_other.txt", 4};

-- 消息类型
tbQinshihuang.MSG_TOP				= 1;		-- 全服公告
tbQinshihuang.MSG_MIDDLE			= 2;		-- 中央红字
tbQinshihuang.MSG_BOTTOM			= 3;		-- 底部黑条
tbQinshihuang.MSG_CHANNEL			= 4;		-- 频道提示
tbQinshihuang.MSG_GLOBAL			= 5;		-- 全服提示

-- 夜明珠需求
tbQinshihuang.tbYemingzhu =
{
	[1] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	[2] = {0, 0, 0, 0, 0, 0, 1, 1, 3, 5},
	[3] = {0, 0, 0, 0, 0, 1, 1, 3, 9, 15},
	[4] = {0, 0, 0, 1, 1, 1, 2, 6, 18, 30},
	[5] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
};

-- boss data
tbQinshihuang.tbBoss = tbQinshihuang.tbBoss or {};	

-- player data
tbQinshihuang.tbPlayerList = tbQinshihuang.tbPlayerList or {};

-- passer data
tbQinshihuang.tbPasser = tbQinshihuang.tbPasser or {};

-- tong list
tbQinshihuang.tbTongList = tbQinshihuang.tbTongList or {};

-- boss pos
tbQinshihuang.tbBossPos =
{
	[1540] = {1540, 1820, 3282},
	[1538] = {1538, 1727, 3445},
	[1536] = {1536, 1816, 3922},
};

tbQinshihuang.tbMapIndex =
{
	[1540] = 1,
	[1538] = 2,
	[1536] = 3,
};

-- 掉落的箱子gdpl
tbQinshihuang.tbDropStone = {18, 1, 1314, 1};

-- 传送列表
tbQinshihuang.tbTranList = 
{
	[1] = {[0] = "秦始皇陵二层",
		{"秦始皇陵二层（东）", {1537, 2180, 3318}},
		{"秦始皇陵二层（南）", {1537, 1839, 3657}},
		{"秦始皇陵二层（西）", {1537, 1677, 3513}},
		{"秦始皇陵二层（北）", {1537, 2034, 3161}},
	},                                      
	[2] = {[0] = "秦始皇陵三层",                                 
		{"秦始皇陵三层（左）", {1538, 1523, 3424}},
		{"秦始皇陵三层（右）", {1538, 1713, 3234}},
	},                                      
	[3] = {[0] = "秦始皇陵四层",                                 
		{"秦始皇陵四层（东）", {1539, 1880, 3617}},
		{"秦始皇陵四层（南）", {1539, 1707, 3793}},
		{"秦始皇陵四层（西）", {1539, 1525, 3629}},
		{"秦始皇陵四层（北）", {1539, 1746, 3403}},
	},                                      
	[4] = {[0] = "秦始皇陵五层",                                 
		{"秦始皇陵五层（王座）", {1540, 1711, 3429}},
	},
};

-- trap
tbQinshihuang.MAP_TRAP_POS =
{
	["trap_1to3"]	 	= {1536, 1538, 1636, 3448},
	["trap_1to5"] 		= {1536, 1540, 1710, 3430},
	["4zto5trap"] 		= {1539, 1540, 1790, 3183},
	["4yto5trap"]		= {1539, 1540, 1915, 3312},
};

-- map list
tbQinshihuang.MAP_LIST =
{
	[1536] = 1,
	[1537] = 1,
	[1538] = 1,
	[1539] = 1,
	[1540] = 1,
}

if (EventManager.IVER_bOpenTiFu ~= 1) then
	tbQinshihuang.MAX_DAILY_TIME = 7200;		-- 每天2小时(7200)
else
	tbQinshihuang.MAX_DAILY_TIME = 2 * 7200;	-- 不限制
end
