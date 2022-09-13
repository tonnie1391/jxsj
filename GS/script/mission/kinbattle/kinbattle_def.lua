-------------------------------------------------------
-- 文件名　：kinbattle_def.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-2 11:38:40
-- 文件描述：
-------------------------------------------------------

-- system switch
KinBattle.OPEN_STATE			= 1;	-- 系统开关

-- task id
KinBattle.TASK_GROUP_ID			= 2028;	-- 任务组ID
KinBattle.TASK_MATCH_COUNT		= 5;	-- 参加次数
KinBattle.TASK_LAST_KILL		= 6;	-- 最近一次家族战杀人数
KinBattle.TASK_LAST_MAXSERIES	= 7;	-- 最近一次家族战最大连斩
KinBattle.TASK_KILL				= 8;	-- 总杀人数
KinBattle.TASK_MAX_KILL			= 9;	-- 最多单场杀人数
KinBattle.TASK_MAX_SERIES		= 10;	-- 单场最大连斩

-- const
KinBattle.TIMER_SIGNUP			= 10 * 60 * Env.GAME_FPS;	-- 报名之后准备时间
KinBattle.TIMER_GAME			= 							-- 比赛时间
{
	[1] = 20 * 60 * Env.GAME_FPS,
	[2] = 40 * 60 * Env.GAME_FPS,
	[3] = 60 * 60 * Env.GAME_FPS,
};

KinBattle.TIMER_SYNCDATA		= 10 * Env.GAME_FPS;	-- 比赛期间的同步客户端数据间隔
KinBattle.SUPER_TIME			= 5;		-- 进入家族战场之后的保护时间
KinBattle.TIME_DEATHWAIT		= 10;		-- 死亡后要在后营等待的时间
KinBattle.MONEY_COST			= 200000;	-- 开启家族战需要的家族资金
KinBattle.MIN_PLAYER_COUNT		= 20;		-- 最小开启玩家个数
KinBattle.MAX_LOOKER_COUNT		= 15;		-- 最多观战人数
KinBattle.MAX_SYNC_COUNT		= 20;	-- 最多同步排行榜玩家个数
KinBattle.LOOKER_LEVEL			= 50;	-- 观战等级限制
KinBattle.MAP_TYPE_COUNT		=		-- 各类型的地图数量,注意与maplist顺序对应
{
	[1] = 7,
	[2] = 0,
	[3] = 0,	
};
-- map id
KinBattle.MAP_LIST	 = 
{
	[1] = {1839, 1846, 1847, 23},	-- 家族战地图，准备场1，准备场2，离开飞往的城市id(必须要保证在同一服务器) 
	[2] = {1840, 1848, 1849, 24}, 
	[3] = {1841, 1850, 1851, 25}, 
	[4] = {1842, 1852, 1853, 26}, 
	[5] = {1843, 1854, 1855, 27},
	[6] = {1844, 1856, 1857, 28},
	[7] = {1845, 1858, 1859, 29}, 
};

-- 离开点
KinBattle.LEAVE_POS	=
{
	[26] = {1547, 3233},
	[25] = {1554, 3197},
	[29] = {1560, 4036},
	[24] = {1870, 3422},
	[28] = {1497, 3358},
	[27] = {1531, 3293},
	[23] = {1508, 3121},
};

KinBattle.PREPARE_POS = {1677, 3292};

-- 对应的地图类型进入地图的坐标点
KinBattle.MAP_ENTER_POS = 
{
	[1] = 
	{
		[1] = {1410, 3161},
		[2] = {1616, 3268},
		[3] = {1418, 3407},
		[4] = {1639, 3543},
	}
};

-- 观战进入坐标点
KinBattle.MAP_LOOKER_POS =
{
	[1] = {1410, 3161},	
};
-- 双方复活点
KinBattle.MAP_REVIVAL_POS = {1677, 3292};

-- 双方阵营
KinBattle.MAP_TEMP_CAMP =
{
	[1] = 1,
	[2] = 2,
};

KinBattle.tbMissionList = KinBattle.tbMissionList or {};

KinBattle.TIMER_GAME_DEC	=
	{
		[1] = "20分钟",	
		[2] = "40分钟",	
		[3] = "60分钟",	
	};
	
KinBattle.MAP_TYPE_DEC	=
{
	[1] = 
	{
		[1] = "沙漠迷城",	-- 地图名
		[2] = "：大片荒漠中，有着许多蜿蜒曲折的废墟小路。",	-- 地图描述
	},
	[2] = 
	{
		[1] = "青青草原",
		[2] = "：敬请期待",
	},
	[3] = 
	{
		[1] = "城市巷战",
		[2] = "：敬请期待",	
	},
};
	
KinBattle.LOOKER_MODE_DEC	=
{
	[1] = "允许观战",
	[2] = "禁止观战",	
};

KinBattle.DEFAULT_POS = {1, 1401, 3146};

if MODULE_GAMESERVER then
	KinBattle.BAOMING_INFO = "家族战必须是参战双方<color=yellow>族长组队<color>，由<color=yellow>队长<color>选择地图，时间，另一队员确认才可开启。\n家族战开启需要消耗双方家族各<color=yellow>20万家族资金<color>。<color=red>请确保有足够的家族资金且家族资金没有被锁定。<color>";
	KinBattle.PROMPT_KINMSG = 
	{
		[1] = "本家族的成员%s在与[%s]家族的家族战中刚刚完成了%s连斩",
		[2] = "本家族的成员%s在与[%s]家族的家族战中刚刚完成了%s人斩",
		[3] = "本家族的成员%s在与[%s]家族的家族战中完成了第一次伤敌。",
		[4] = "本家族的成员%s在与[%s]家族的家族战中完成了本家族的第一次伤敌。",
		[5] = "本家族的成员%s在与[%s]家族的家族战中第一个完成了%s连斩",
		[6] = "本家族的成员%s在与[%s]家族的家族战中第一个完成了%s人斩",
		[7] = "本家族的成员%s在与[%s]家族的家族战中完成了%s连斩，这是本家族的第一个%s连斩",
		[8] = "本家族的成员%s在与[%s]家族的家族战中完成了%s人斩，这是本家族的第一个%s人斩",
	};
	KinBattle.PROMPT_MAPMSG = 
	{
		[1] = "<color=blue>[%s]<color>家族成员<color=yellow>%s<color>刚刚完成了<color=yellow>%s连斩<color>，达到了<color=yellow>[%s]<color>级别。",
		[2] = "<color=blue>[%s]<color>家族成员<color=yellow>%s<color>刚刚完成了<color=yellow>%s人斩<color>，达到了<color=yellow>[%s]<color>级别。",
		[3] = "<color=blue>[%s]<color>家族成员<color=yellow>%s<color>完成了本次家族战的<color=yellow>第一次伤敌<color>。",
		[4] = "<color=blue>[%s]<color>家族成员<color=yellow>%s<color><color=green>第一个<color>完成了<color=yellow>%s连斩<color>，达到了<color=yellow>[%s]<color>级别。",
		[5] = "<color=blue>[%s]<color>家族成员<color=yellow>%s<color><color=green>第一个<color>完成了<color=yellow>%s人斩<color>，达到了<color=yellow>[%s]<color>级别。",
	};
	KinBattle.SPECIAL_TITLE = 
	{
		[1] = --连斩称号
		{
			[1] = {tbId = {6,50,1,1}, szTitle = "连刃斩", nLimit = 20},
			[2] = {tbId = {6,50,2,2}, szTitle = "斩三斩", nLimit = 50},
			[3] = {tbId = {6,50,3,3}, szTitle = "百斩狂客", nLimit = 100},
			[4] = {tbId = {6,50,4,4}, szTitle = "连斩之王", nLimit = 200},
			[5] = {tbId = {6,50,5,5}, szTitle = "连斩之神", nLimit = 300},
		},
		[2] = -- 杀敌总数称号
		{
			[1] = {tbId = {6,49,1,1}, szTitle = "家族勇士", nLimit = 50},
			[2] = {tbId = {6,49,2,2}, szTitle = "家族精英", nLimit = 100},
			[3] = {tbId = {6,49,3,3}, szTitle = "名门之后", nLimit = 200},
			[4] = {tbId = {6,49,4,4}, szTitle = "族中大侠", nLimit = 300},
			[5] = {tbId = {6,49,5,5}, szTitle = "族中神侠", nLimit = 500},
		},
	};
end