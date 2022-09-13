-------------------------------------------------------
-- 文件名　：atlantis_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-03-09 11:31:58
-- 文件描述：
-------------------------------------------------------

-- 系统开关
Atlantis.IS_OPEN				= 1;

-- 任务变量
Atlantis.TASK_GID 				= 2161;					-- 任务变量组
Atlantis.TASK_USE_TIME			= 1;					-- 每天使用时间
Atlantis.TASK_PROTECT			= 2;					-- 保护设置

-- 常量定义
Atlantis.MAX_PLAYER				= 360;					-- 地图最大人数
Atlantis.MIN_LEVEL				= 100;					-- 角色等级限制
Atlantis.MIN_MANTLE				= 6;					-- 披风等级限制
Atlantis.MAX_TIME				= 7200;					-- 每天2小时
Atlantis.OPEN_DAY				= 25;					-- 120天开放
Atlantis.SUPER_TIME				= 5;					-- 保护时间
Atlantis.MIN_BAG_CHIP			= 5;					-- 超过5个掉落20%

-- 怪物相关
Atlantis.NPC_LEVEL				= 120;					-- 怪物等级
Atlantis.MAX_MONSTER			= 20;					-- 最大20堆怪
Atlantis.MAX_DAY_BOSS			= 16;					-- 每天最多8个boss
Atlantis.MAX_EQUIP				= 7;					-- 地图最多7个神兵
Atlantis.MAX_MOVER				= 15;					-- 最多15个羊
Atlantis.MOVER_RATE				= 3000;					-- 随机怪概率30%
Atlantis.BOSS_RATE				= 1000;					-- boss概率8%
Atlantis.EQUIP_RATE				= 1000;					-- 神兵概率10%
Atlantis.MAX_DROP_TIMES			= 32;					-- 最大掉落次数

-- 消息类型
Atlantis.MSG_TOP				= 1;					-- 全服公告
Atlantis.MSG_MIDDLE				= 2;					-- 中央红字
Atlantis.MSG_BOTTOM				= 3;					-- 底部黑条
Atlantis.MSG_CHANNEL			= 4;					-- 频道提示

-- 怪物ID
Atlantis.NPC_MOVER_ID			= 7364;					-- 随机怪				
Atlantis.NPC_EQUIP_ID			= 7374;					-- 神兵
Atlantis.NPC_BOSS_ID			= 7366;					-- boss
Atlantis.NPC_STAR_ID			= 7371;					-- 七星阵

-- 计时器
Atlantis.TIMER_PLAYER			= 5;					-- 监控频率
Atlantis.TIMER_MONSTER			= 300;					-- 监控频率
Atlantis.TIMER_MOVER			= 900;					-- 监控频率
Atlantis.TIMER_BOSS				= 360;					-- 监控频率
Atlantis.TIMER_DEAMON			= 60;					-- 监控频率

-- 地图ID
Atlantis.MAP_ID					= 2013;

-- 月影之石ID
Atlantis.ITEM_MOON_ID 			= {18, 1, 476, 1};

-- 落神锤
Atlantis.ITEM_HAMMER_ID			= {18, 1, 1245, 1};

-- 时间段系数
Atlantis.TIME_RATE =
{
	[0200] = 1,
	[1000] = 0,
	[1400] = 0.7,
	[1600] = 0.5,
	[2000] = 1,
	[2300] = 0.5,
	[2400] = 1,
};

-- 兑换列表
Atlantis.CHANGE_LIST = 
{
	[1] = {szBase = "楼兰珍宝·碧玉", szName = "碧血护腕碎片", tbBaseId = {18, 1, 1235, 1}, tbItemId = {18, 1, 1237, 1}, nNeedChip = 10, nNeedMoon = 3},
	[2] = {szBase = "楼兰珍宝·灵晶", szName = "金鳞护腕碎片", tbBaseId = {18, 1, 1235, 2}, tbItemId = {18, 1, 1238, 1}, nNeedChip = 10, nNeedMoon = 10},
	[3] = {szBase = "楼兰珍宝·雅瓷", szName = "碧血戒指碎片", tbBaseId = {18, 1, 1236, 1}, tbItemId = {18, 1, 1240, 1}, nNeedChip = 10, nNeedMoon = 4},
	[4] = {szBase = "楼兰珍宝·白玉", szName = "金鳞戒指碎片", tbBaseId = {18, 1, 1236, 2}, tbItemId = {18, 1, 1241, 1}, nNeedChip = 10, nNeedMoon = 13},
};

-- 材料列表
Atlantis.ITEM_CHIP_ID = 
{
	[1] = {tbItemId = {18, 1, 1235, 1}, szName = "楼兰珍宝·碧玉"},
	[2] = {tbItemId = {18, 1, 1235, 2}, szName = "楼兰珍宝·灵晶"},
	[3] = {tbItemId = {18, 1, 1236, 1}, szName = "楼兰珍宝·雅瓷"},
	[4] = {tbItemId = {18, 1, 1236, 2}, szName = "楼兰珍宝·白玉"},
};

-- 白金装备
Atlantis.ITEM_EQUIP_ID =
{
	[Env.FACTION_ID_SHAOLIN]  = {[1] = {2, 1, 1447, 10}, [2] = {2, 1, 1448, 10}},
	[Env.FACTION_ID_TIANWANG]  = {[1] = {2, 1, 1449, 10}, [2] = {2, 1, 1450, 10}},
	[Env.FACTION_ID_TANGMEN]  = {[1] = {2, 2, 163, 10},  [2] = {2, 2, 164, 10}},
	[Env.FACTION_ID_WUDU]  = {[1] = {2, 1, 1451, 10}, [2] = {2, 1, 1452, 10}},
	[Env.FACTION_ID_EMEI]  = {[1] = {2, 1, 1455, 10}, [2] = {2, 1, 1456, 10}},
	[Env.FACTION_ID_CUIYAN]  = {[1] = {2, 1, 1456, 10}, [2] = {2, 1, 1453, 10}},
	[Env.FACTION_ID_GAIBANG]  = {[1] = {2, 1, 1459, 10}, [2] = {2, 1, 1457, 10}},
	[Env.FACTION_ID_TIANREN]  = {[1] = {2, 1, 1458, 10}, [2] = {2, 1, 1460, 10}},
	[Env.FACTION_ID_WUDANG]  = {[1] = {2, 1, 1463, 10}, [2] = {2, 1, 1462, 10}},
	[Env.FACTION_ID_KUNLUN] = {[1] = {2, 1, 1461, 10}, [2] = {2, 1, 1464, 10}},
	[Env.FACTION_ID_MINGJIAO] = {[1] = {2, 1, 1465, 10}, [2] = {2, 1, 1466, 10}},
	[Env.FACTION_ID_DALIDUANSHI] = {[1] = {2, 1, 1454, 10}, [2] = {2, 1, 1456, 10}},
	[Env.FACTION_ID_GUMU] = { [1] = {2,1,1530,10}, [2] = {2,2,246,10}},
};

-- 精英怪列表
Atlantis.MONSTER_LIST =
{
	[1] = {nNpcId = 7353, szNpcClass = "atlantis_npc_monster1"},
	[2] = {nNpcId = 7354, szNpcClass = "atlantis_npc_monster2"},
};

-- 精英怪掉落
Atlantis.MONSTER_DROP_FILE = "\\setting\\npc\\droprate\\atlantis\\monster.txt";

-- 附属怪列表
Atlantis.MONSTER_BABY =
{
	[7353] = {
		[1] = {nPercent = 80, nBabyId = 7356},
		[2] = {nPercent = 60, nBabyId = 7356},
		[3] = {nPercent = 40, nBabyId = 7356},
		[4] = {nPercent = 20, nBabyId = 7356},
	},
--	[7354] = {
--		[1] = {nPercent = 80, nBabyId = 7358},
--		[2] = {nPercent = 60, nBabyId = 7358},
--		[3] = {nPercent = 80, nBabyId = 7358},
--		[4] = {nPercent = 20, nBabyId = 7358},
--	},
};

-- 复活点坐标
Atlantis.REVIVAL_LIST =
{
	[1] = {2013, 1793, 3489},
	[2] = {2013, 1865, 3160},
	[3] = {2013, 2064, 3382},
};

-- 回程点坐标
Atlantis.MAP_CITY_POS = {24, 1764, 3491};

-- boss点坐标
Atlantis.MAP_BOSS_POS =
{
	[1] = {2013, 1590, 3096},
	[2] = {2013, 1857, 3394},
	[3] = {2013, 2160, 3731},
};

-- 精英点坐标
Atlantis.MAP_MONSTER_POS =
{
	[1]  = {2013, 1558, 3485},
	[2]  = {2013, 1639, 3241},
	[3]  = {2013, 1647, 3500},
	[4]  = {2013, 1655, 3402},
	[5]  = {2013, 1650, 3570},
	[6]  = {2013, 1707, 3147},
	[7]  = {2013, 1715, 3223},
	[8]  = {2013, 1719, 3498},
	[9]  = {2013, 1738, 3290},
	[10] = {2013, 1730, 3649},
	[11] = {2013, 1774, 3388},
	[12] = {2013, 1793, 3187},
	[13] = {2013, 1803, 3568},
	[14] = {2013, 1799, 3655},
	[15] = {2013, 1806, 3769},
	[16] = {2013, 1832, 3332},
	[17] = {2013, 1865, 3476},
	[18] = {2013, 1880, 3276},
	[19] = {2013, 1882, 3644},
	[20] = {2013, 1900, 3087},
	[21] = {2013, 1910, 3358},
	[22] = {2013, 1922, 3417},
	[23] = {2013, 1940, 3020},
	[24] = {2013, 1949, 3177},
	[25] = {2013, 1941, 3560},
	[26] = {2013, 1980, 3120},
	[27] = {2013, 1973, 3363},
	[28] = {2013, 1971, 3646},
	[29] = {2013, 2009, 3032},
	[30] = {2013, 2012, 3235},
	[31] = {2013, 2011, 3473},
	[32] = {2013, 2055, 3162},
	[33] = {2013, 2058, 3664},
	[34] = {2013, 2079, 3283},
	[35] = {2013, 2074, 3545},
	[36] = {2013, 2107, 3093},
	[37] = {2013, 2132, 3190},
};

-- 移动怪坐标
Atlantis.MAP_MOVER_POS =
{
	[1]  = {2013, 1588, 3505},
	[2]  = {2013, 1621, 3425},
	[3]  = {2013, 1629, 3549},
	[4]  = {2013, 1664, 3521},
	[5]  = {2013, 1680, 3234},
	[6]  = {2013, 1683, 3550},
	[7]  = {2013, 1700, 3293},
	[8]  = {2013, 1700, 3472},
	[9]  = {2013, 1740, 3200},
	[10] = {2013, 1737, 3527},
	[11] = {2013, 1758, 3405},
	[12] = {2013, 1774, 3149},
	[13] = {2013, 1769, 3265},
	[14] = {2013, 1797, 3223},
	[15] = {2013, 1859, 3299},
	[16] = {2013, 1871, 3346},
	[17] = {2013, 1901, 3047},
	[18] = {2013, 1896, 3466},
	[19] = {2013, 1909, 3294},
	[20] = {2013, 1945, 3109},
	[21] = {2013, 1942, 3379},
	[22] = {2013, 1969, 3000},
	[23] = {2013, 1980, 3483},
	[24] = {2013, 2000, 3646},
	[25] = {2013, 2023, 3499},
	[26] = {2013, 2026, 3599},
	[27] = {2013, 2069, 3578},
	[28] = {2013, 2096, 3251},
	[29] = {2013, 2098, 3642},
	[30] = {2013, 2130, 3119},
};

-- trap坐标
Atlantis.MAP_TRAP_POS =
{
	["safe_1_in_1"]	 	= {1793, 3489, 0},
	["safe_1_in_2"] 	= {1793, 3489, 0},
	["safe_1_in_3"] 	= {1793, 3489, 0},
	["safe_1_out_1"]	= {1749, 3502, 1},
	["safe_1_out_2"] 	= {1798, 3541, 1},
	["safe_1_out_3"] 	= {1821, 3456, 1},
	["safe_2_in_1"] 	= {1865, 3160, 0},
	["safe_2_in_2"] 	= {1865, 3160, 0},
	["safe_2_in_3"] 	= {1865, 3160, 0},
	["safe_2_out_1"]	= {1827, 3194, 1},
	["safe_2_out_2"] 	= {1888, 3129, 1},
	["safe_2_out_3"] 	= {1876, 3245, 1},
	["safe_3_in_1"]	 	= {2064, 3382, 0},
	["safe_3_in_2"] 	= {2064, 3382, 0},
	["safe_3_in_3"] 	= {2064, 3382, 0},
	["safe_3_out_1"] 	= {2019, 3375, 1},
	["safe_3_out_2"] 	= {2049, 3319, 1},
	["safe_3_out_3"] 	= {2039, 3439, 1},
};

-- 北斗七星阵
Atlantis.MAP_STAR_POS =
{
	[1]  = {2013, 1874, 3369},
	[2]  = {2013, 1880, 3362},
	[3]  = {2013, 1887, 3370},
	[4]  = {2013, 1884, 3381},
	[5]  = {2013, 1886, 3396},
	[6]  = {2013, 1888, 3408},
	[7]  = {2013, 1899, 3418},
};

-- 玩家列表
Atlantis.tbPlayerList = Atlantis.tbPlayerList or {};

-- 队伍列表
Atlantis.tbTeamList = Atlantis.tbTeamList or {};

-- 精英怪列表
Atlantis.tbMonster = Atlantis.tbMonster or {};

-- 计时器列表
Atlantis.tbTimerId = Atlantis.tbTimerId or {};

-- boss列表
Atlantis.tbBoss = Atlantis.tbBoss;

-- star列表
Atlantis.tbStar = Atlantis.tbStar or {};

Atlantis.nDateCanDirOpen = 20220622;

-- 系统开关
function Atlantis:CheckIsOpen()
	if TimeFrame:GetState("Atlantis") == 0 then
		local nOpenTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
		local nOpenDate = tonumber(os.date("%Y%m%d", nOpenTime));
		
		if (nOpenDate > self.nDateCanDirOpen) then
			return 0;
		end
	end

	if tonumber(GetLocalDate("%H%M")) < 1500 then
		return 0;
	end
	return self.IS_OPEN;
end

