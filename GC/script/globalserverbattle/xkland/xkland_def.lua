-------------------------------------------------------
-- 文件名　：xkland_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-04-06 09:52:34
-- 文件描述：
-------------------------------------------------------

Xkland.IS_GLOBAL 				= GLOBAL_AGENT or 0;	-- 中心服务器

-- 本服任务变量
Xkland.TASK_GID 				= 2125;					-- 任务变量组

-- 中心服务器用
Xkland.TASK_PASSPORT			= 1;					-- 进出复活点许可证
Xkland.TASK_SERIES_KILL			= 2;					-- 连斩标志
Xkland.TASK_LAND_ENTER			= 15;					-- 从岛上进入标记

-- 本地服务器用
Xkland.TASK_TONGNAME			= 3;					-- 记录帮会名字(3-10)
Xkland.TASK_SESSION				= 11;					-- 记录参加的届数
Xkland.TASK_COMP_COIN 			= 12;					-- 首领竞拍金币数量
Xkland.TASK_WAR_GROUP			= 13;					-- 本服选择军团编号
Xkland.TASK_WAR_BOX				= 14;					-- 本服兑换的箱子个数
Xkland.TASK_AWARD_MONEY			= 16;					-- 领袖投入赏金
Xkland.TASK_WAR_EXP				= 17;					-- 本服领取的经验

-- 跨服任务变量
Xkland.GA_TASK_GID				= 3;					-- 任务变量组

-- 中心服务器设置，自动同步给本服
Xkland.GA_TASK_WAR_RANK			= 1;					-- 跨服城战排名
Xkland.GA_TASK_WAR_POINT		= 2;					-- 跨服城战积分
Xkland.GA_TASK_WAR_GROUP		= 3;					-- 跨服军团编号
Xkland.GA_TASK_WAR_BOX			= 4;					-- 可以领箱子个数
Xkland.GA_TASK_WAR_REVIVAL		= 5;					-- 个人免费复活的次数
Xkland.GA_TASK_WAR_BACKMONEY	= 6;					-- 返还的跨服绑银
Xkland.GA_TASK_WAR_EXP			= 7;					-- 征战奖励经验

-- 跨服全局变量
Xkland.GA_DBTASK_GID			= 3;					-- 任务变量组
Xkland.GA_DBTASK_OCCUPY_DAY		= 11;					-- 连续占领城天数
Xkland.GA_DBTASK_SESSION		= 12;					-- 跨服城战届数
Xkland.GA_DBTASK_PERIOD			= 13;					-- 1-竞拍期，2-选择阵营期，3-战争期，4-休战期
Xkland.GA_DBTASK_SYSTEM_MONEY	= 14;					-- 系统获得绑银
Xkland.GA_DBTASK_OPEN			= 15;					-- 系统开关

-- 跨服global buffer
Xkland.GA_INTBUF_GID			= 3;					-- 任务变量组
Xkland.GA_INTBUF_COMPETITIVE	= 11;					-- 首领竞拍前6名

-- 常量定义
Xkland.MAX_GROUP				= 6;					-- 最大军团数量
Xkland.MIN_GROUP				= 2;					-- 最小军团数量
Xkland.MANTLE_LEVEL				= 7;					-- 披风等级
Xkland.MAX_TONG_COUNT			= 100;					-- 成员帮会数量
Xkland.MAX_MAP_PLAYER			= 400;					-- 每个地图最大人数
Xkland.MIN_COMPETITIVE			= 1000;					-- 每次最少
Xkland.MAX_COMPETITIVE			= 1000000;				-- 每次最多
Xkland.TOTAL_COMPETITIVE		= 1000000000;			-- 竞标总额
Xkland.MAX_FREE_REVIVAL			= 1000000000;			-- 免费复活次数
Xkland.MAX_OCCUPY_DEATHS		= 9;					-- 王座更变有效积分次数
Xkland.THRONE_MAP_ID			= 1722;					-- 王座地图id
Xkland.MAX_OVERFLOW				= 2000000000;			-- 防溢出数字

-- 奖励相关
Xkland.CASTLE_RATE				= 150 * 20000;			-- 城主分配基数
Xkland.BOX_MONEY				= 100000;				-- 个人积分箱子价格
Xkland.CASTLE_BOX_MONEY			= 2000000;				-- 城主箱子价格
Xkland.CASTLE_BOX_EXTRA			= 20;					-- 城主可以额外购买的箱子
Xkland.SHIWEI_LINGPAI			= 8;					-- 每场奖励的侍卫令牌数目
Xkland.CHENGZHU_LINGPAI			= 1;					-- 每场奖励的城主令牌数目
Xkland.COIN_MONEY_RATE			= 200;					-- 金币折算跨服绑银汇率

-- skill
Xkland.RESOURCE_BUFFER			= 1625;					-- 资源点buffer
Xkland.THRONE_BUFFER			= 1627;					-- 占领王座后buffer
Xkland.BALANCE_BUFFER			= 1628;					-- 阵营平衡buffer

-- 时间相关
Xkland.READY_TIME				= 30 * 60;				-- 开战前准备时间
Xkland.PLAY_TIME				= 90 * 60;				-- 战斗进行时间
Xkland.REFRESH_BOAT				= 120 * Env.GAME_FPS;	-- 刷新渡船点
Xkland.BOAT_LIVING				= 60 * Env.GAME_FPS;	-- 渡船点存在时间
Xkland.PROTECT_INTERVAL			= 15 * Env.GAME_FPS;	-- 每隔一定时间加护卫积分
Xkland.SYNC_REPORT_DATA			= 5 * Env.GAME_FPS;		-- 更新即时战报
Xkland.SUPER_TIME				= 5;					-- 5秒无敌时间
Xkland.THRONE_BUFFER_TIME		= 7200 * Env.GAME_FPS;	-- 占领王座buffer时间
Xkland.THRONE_POINT_TIME		= 60 * Env.GAME_FPS;	-- 王座积分时间

-- 积分相关
Xkland.RESOURCE_POINT			= 500;					-- 占领资源点
Xkland.KILLER_BOUNS				= 100;					-- 杀人增加积分
Xkland.PROTECT_DISTANCE			= 30;					-- 护卫资源点距离
Xkland.PROTECT_POINT			= 5;					-- 护卫积分
Xkland.THRONE_POINT				= 50;					-- 王座定时积分

-- path
Xkland.THRONE_SCORE_PATH		= "\\setting\\globalserverbattle\\xkland\\throne_score.txt";
Xkland.LOG_PATH					= "\\log\\gamecenter\\20";

-- period
Xkland.PERIOD_COMPETITIVE		= 1;
Xkland.PERIOD_SELECT_GROUP		= 2;
Xkland.PERIOD_WAR_OPEN			= 3;
Xkland.PERIOD_WAR_REST			= 4;

-- group index
Xkland.CASTLE_GROUP_INDEX		= 1;
Xkland.ATTACK_GROUP_INDEX		= 2;

-- item id
Xkland.NORMAL_BOX_ID			= {18, 1, 939, 1};
Xkland.CASTLE_BOX_ID			= {18, 1, 940, 1};
Xkland.CHENGZHU_LINGPAI_ID		= {20, 1, 869, 1};
Xkland.LINGPAI_ID				= {20, 1, 870, 1};
Xkland.YANHUA_ID				= {18, 1, 70, 1};
Xkland.JADE_ID					= {18, 1, 1, 11};
Xkland.MOON_ID					= {18, 1, 476, 1};
Xkland.WEAPON_ID				= {18, 1, 377, 1};

-- msg type
Xkland.SYSTEM_CHANNEL_MSG		= 1;
Xkland.BOTTOM_BLACK_MSG			= 2;
Xkland.MIDDLE_RED_MSG			= 3;
Xkland.TOP_YELLOW_MSG			= 4;

-- 复活点分组索引
Xkland.REVIVAL_POS_INDEX =
{
	[1] = {1718, 1941, 3428},
	[2] = {1718, 1597, 3442},
	[3] = {1719, 1941, 3428},
	[4] = {1719, 1597, 3442},
	[5] = {1720, 1941, 3428},
	[6] = {1720, 1597, 3442},
};

-- 复活点攻守索引，1-守，2-攻
Xkland.REVIVAL_POS_WAR = 
{
	[1] = {[1] = {1718, 1941, 3428}, [2] = {1719, 1941, 3428}, [3] = {1720, 1941, 3428}},
	[2] = {[1] = {1718, 1597, 3442}, [2] = {1719, 1597, 3442}, [3] = {1720, 1597, 3442}},
	[3] = {[1] = {1718, 1696, 3334}, [2] = {1719, 1696, 3334}, [3] = {1720, 1696, 3334}},
};

-- 王座坐标
Xkland.THRONE_POS = {1722, 1584, 3221};

-- 消耗绑银
Xkland.MONEY_COST =
{
	[7] = {nCost = 10000, tbRadio = {3, 9, 3, 7}}, 
	[8] = {nCost = 30000, tbRadio = {4, 8, 3, 7}}, 
	[9] = {nCost = 100000, tbRadio = {5, 7, 3, 7}}, 
	[10] = {nCost = 200000, tbRadio = {6, 6, 3, 7}}, 
};

-- 头衔积分列表
Xkland.RANK_POINT =
{
	[1] = {1000, "士兵"},
	[2] = {2000, "校尉"},
	[3] = {3000, "统领"},
	[4] = {6000, "副将"},
	[5] = {10000, "大将"},
	[6] = {15000, "元帅"},
};

-- 第二届以后攻守头衔
Xkland.NORMAL_TITLE =
{
	[1] = "守方军团",
	[2] = "攻方军团"	
};

-- 披风等级
Xkland.MANTLE_TYPE =
{
	[7] = "雏凤披风等级",
	[8] = "潜龙披风等级",
	[9] = "至尊披风等级",
	[10] = "无双披风等级",
};

-- 地图列表
Xkland.MAP_LIST = 
{
	[1] = 1718,
	[2] = 1719,
	[3] = 1720,
	[4] = 1721,
	[5] = 1722,
};

-- 地图名字
Xkland.MAP_NAME =
{
	[1718] = "外围矿区一",
	[1719] = "外围矿区二",	
	[1720] = "外围矿区三",	
	[1721] = "铁浮城城内",	
	[1722] = "铁浮城王座",		
}

-- 资源点坐标
Xkland.RESOURCE_LIST =
{
	[1718] = {[6831] = {1718, 1810, 3262}, [6832] = {1718, 1842, 3481}, [6833] = {1718, 1697, 3513}},
	[1719] = {[6831] = {1719, 1810, 3262}, [6832] = {1719, 1842, 3481}, [6833] = {1719, 1697, 3513}},
	[1720] = {[6831] = {1720, 1810, 3262}, [6832] = {1720, 1842, 3481}, [6833] = {1720, 1697, 3513}},
};

-- 渡传点坐标
Xkland.BOAT_LIST =
{
	[1718] = {[6829] = {1718, 1716, 3206}},
	[1719] = {[6829] = {1719, 1716, 3206}},
	[1720] = {[6829] = {1720, 1716, 3206}},
	[1721] = {[6830] = {1721, 1783, 3484}},
};

-- 复活点3坐标
Xkland.REVIVAL_LIST = 
{
	[1718] = {{nNpcId = 6819, tbPos = {1718, 1725, 3357}}, {nNpcId = 6820, tbPos = {1718, 1712, 3345}}},
	[1719] = {{nNpcId = 6819, tbPos = {1719, 1725, 3357}}, {nNpcId = 6820, tbPos = {1719, 1712, 3345}}},
	[1720] = {{nNpcId = 6819, tbPos = {1720, 1725, 3357}}, {nNpcId = 6820, tbPos = {1720, 1712, 3345}}},
};

-- 系统每周阶段
Xkland.PERIOD_DAY_FIRST = {[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 2, [6] = 3, [0] = 1};
Xkland.PERIOD_DAY_NORMAL = {[1] = 1, [2] = 2, [3] = 3, [4] = 1, [5] = 2, [6] = 3, [0] = 1};

-- 玩家箱子分配比例
Xkland.PLAYER_BOX_RADIO =
{
	[1] = {0.05, 10},
	[2] = {0.15, 8},
	[3] = {0.30, 6},
	[4] = {0.45, 4},
	[5] = {0.60, 3},
	[6] = {0.80, 2},
	[7] = {1.00, 1},
};

-- 经验奖励
Xkland.PLAYER_EXP_RADIO =
{
	[1] = {0.05, 800},
	[2] = {0.15, 700},
	[3] = {0.30, 600},
	[4] = {0.45, 550},
	[5] = {0.60, 500},
	[6] = {0.80, 450},
	[7] = {1.00, 400},	
};

-- 平衡性buffer等级
Xkland.BALANCE_LEVEL =
{
	[1] = 90,
	[2] = 80,
	[3] = 70,
	[4] = 60,
	[5] = 50,
}

-- 军团颜色
Xkland.GROUP_COLOR = 
{
	[1] = "yellow",
	[2] = "cyan",
	[3] = "green",
	[4] = "pink",
	[5] = "red",
	[6] = "gold",
};

-- 竞标绑银
Xkland.BIDDING_MONEY = 
{
	[1] = {399, 1000},
	[2] = {400, 10000},
};

-- 雕像坐标
Xkland.STATUE_POS = 
{
	 [0] = {tbPos = {1804, 3493}, tbMapId = {24}},
	 [1] = {tbPos = {1854, 3375}, tbMapId = {1609, 1610, 1611, 1612, 1613, 1614, 1615, 1645, 1646, 1647, 1648, 1649, 1650}},
};

-- 雕像id
Xkland.STATUE_ID =
{
	[0] = 6867,
	[1] = 6868,
};
			
-- 地图传送点
Xkland.NPC_CLASS = 
{
	["revival_in_1"] 	= {TransPos = {[1718] = {1718, 1912, 3359}, [1719] = {1719, 1912, 3359}, [1720] = {1720, 1912, 3359}}, Proccess = 0, Check = "Check_RevivalOut", FightState = 1, SuperTime = 5},
	["revival_out_1"] 	= {TransPos = {[1718] = {1718, 1941, 3428}, [1719] = {1719, 1941, 3428}, [1720] = {1720, 1941, 3428}}, Proccess = 0, Check = "Check_RevivalIn", FightState = 0, SuperTime = 0},
	["revival_in_2"] 	= {TransPos = {[1718] = {1718, 1635, 3413}, [1719] = {1719, 1635, 3413}, [1720] = {1720, 1635, 3413}}, Proccess = 0, Check = "Check_RevivalOut", FightState = 1, SuperTime = 5},
	["revival_out_2"] 	= {TransPos = {[1718] = {1718, 1597, 3442}, [1719] = {1719, 1597, 3442}, [1720] = {1720, 1597, 3442}}, Proccess = 0, Check = "Check_RevivalIn", FightState = 0, SuperTime = 0},
	["revival_in_3"] 	= {TransPos = {[1718] = {1718, 1728, 3358}, [1719] = {1719, 1728, 3358}, [1720] = {1720, 1728, 3358}}, Proccess = 0, Check = "Check_RevivalOut", FightState = 1, SuperTime = 5},
	["revival_out_3"] 	= {TransPos = {[1718] = {1718, 1696, 3334}, [1719] = {1719, 1696, 3334}, [1720] = {1720, 1696, 3334}}, Proccess = 0, Check = "Check_RevivalSpecIn", FightState = 0, SuperTime = 0},
	["floor_1_to_2"] 	= {TransPos = {[1718] = {1721, 1627, 3646}, [1719] = {1721, 1687, 3330}, [1720] = {1721, 1899, 3579}}, Proccess = 0, Check = "Check_Floor_2", FightState = 1, SuperTime = 5},
	["floor_2_to_11"] 	= {TransPos = {[1721] = {1718, 1856, 3280}}, Proccess = 0, Check = "Check_Default", FightState = 1, SuperTime = 5},
	["floor_2_to_12"] 	= {TransPos = {[1721] = {1719, 1856, 3280}}, Proccess = 0, Check = "Check_Default", FightState = 1, SuperTime = 5},
	["floor_2_to_13"] 	= {TransPos = {[1721] = {1720, 1856, 3280}}, Proccess = 0, Check = "Check_Default", FightState = 1, SuperTime = 5},
	["floor_2_to_31"]	= {TransPos = {[1721] = {1722, 1440, 3270}}, Proccess = 0, Check = "Check_Floor_3", FightState = 1, SuperTime = 5},
	["floor_2_to_32"]	= {TransPos = {[1721] = {1722, 1546, 3375}}, Proccess = 0, Check = "Check_Floor_3", FightState = 1, SuperTime = 5},
	["floor_3_to_21"] 	= {TransPos = {[1722] = {1721, 1887, 3322}}, Proccess = 0, Check = "Check_Default", FightState = 1, SuperTime = 5},
	["floor_3_to_22"] 	= {TransPos = {[1722] = {1721, 1928, 3340}}, Proccess = 0, Check = "Check_Default", FightState = 1, SuperTime = 5},
	["ferry_boat_1"] 	= {TransPos = {[1718] = {1721, 1627, 3646}, [1719] = {1721, 1687, 3330}, [1720] = {1721, 1899, 3579}}, Proccess = 10, Check = "Check_Floor_2", FightState = 1, SuperTime = 5},
	["ferry_boat_2"] 	= {TransPos = {[1721] = {1722, 1626, 3192}}, Proccess = 10, Check = "Check_Floor_3", FightState = 1, SuperTime = 5},
};

-- 竞拍数据
-- 1. 第一次前6名代表6个军团领袖
-- 2. 第二次以后，最高者成为攻方领袖
-- tbCompetitiveBuffer = {[1] = {szPlayerName, szGateway, nCompetitive, szTongName, nPlayerSex}, ...}
Xkland.tbCompetitiveBuffer = Xkland.tbCompetitiveBuffer or {};

-- 竞拍前6名数据
-- tbSyncCompBuffer = {[1] = {szPlayerName, szGateway, nCompetitive, szTongName}, ...}
Xkland.tbSyncCompBuffer = Xkland.tbSyncCompBuffer or {};

-- 军团数据
-- tbGroupBuffer = {[1] = {szGroupName, nTongCount, tbAward = {nAwardCount, nMultiple, nExtraBox, nForceSend}, tbCaptain = {szPlayerName, szGateway, szTongName, nPlayerSex}, tbTong = {szTongName = szGateway}}, tbPreTong = {szTongName = szGateway}...};
Xkland.tbGroupBuffer = Xkland.tbGroupBuffer or {};

-- 军团战斗数据
-- tbWarBuffer = {[1] = {nGroupIndex, nPoint, nRevivalMoney, nResource, nThronePoint}, ...};
Xkland.tbWarBuffer = Xkland.tbWarBuffer or {};

-- 本服军团映像
Xkland.tbLocalGroupBuffer = Xkland.tbLocalGroupBuffer or {};

-- 玩家战斗数据
-- tbPlayerBuffer = {[szPlayerName] = {nGroupIndex, nPoint, nKillCount, nCurSeriesKill, nMaxSeriesKill, nRank, nProtect, nResource}, ...};
Xkland.tbPlayerBuffer = Xkland.tbPlayerBuffer or {};

-- 城堡数据
-- tbCastleBuffer = {szPlayerName, szGateway, szTongName, nPlayerSex, nCastleMoney, nCastleBox, nGroupIndex, tbTong = {szTongName = {nBox, nLingPai}}};
Xkland.tbCastleBuffer = Xkland.tbCastleBuffer or {};

-- 本服城堡映像
Xkland.tbLocalCastleBuffer = Xkland.tbLocalCastleBuffer or {};

-- 资源点
Xkland.tbResource = Xkland.tbResource or {};

-- 渡船点
Xkland.tbBoat = Xkland.tbBoat or {};

-- 复活点旗帜
Xkland.tbRevival = Xkland.tbRevival or {};

-- 王座数据
Xkland.tbThrone = Xkland.tbThrone or {nOwnerGroup = 0, szPlayerName = "", nModify = 0, nMinute = 0};

-- 地图人数
Xkland.tbMapPlayerCount = Xkland.tbMapPlayerCount or {};

-- 玩家排序
Xkland.tbSortPlayer = Xkland.tbSortPlayer or {};

-- 军团排序
Xkland.tbSortGroup = Xkland.tbSortGroup or {};

-- 城主雕像
Xkland.tbCastleNpcId = Xkland.tbCastleNpcId or {};

-- 有效buffer
Xkland.VAILD_GBLBUFFER = 
{
	[GBLINTBUF_XK_COMPETITIVE]	= "tbCompetitiveBuffer",
	[GBLINTBUF_XK_GROUP]		= "tbGroupBuffer",
	[GBLINTBUF_XK_PLAYER]		= "tbPlayerBuffer",
	[GBLINTBUF_XK_WAR]			= "tbWarBuffer",
	[GBLINTBUF_XK_CASTLE]		= "tbCastleBuffer",
	[GBLINTBUF_XKL_GROUP]		= "tbLocalGroupBuffer",
	[GBLINTBUF_XKL_CASTLE]		= "tbLocalCastleBuffer",
};

-- 有效buffer
Xkland.VAILD_CENTER_BUFFER = 
{
	[11] = "tbSyncCompBuffer",
};

-- 系统是否开启
function Xkland:CheckIsOpen()
--	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_OPEN) or 0;
	return 0;
end

-- 是否全局服务器
function Xkland:CheckIsGlobal()
	return self.IS_GLOBAL;
end

-- 第几届争夺
function Xkland:GetSession()
	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SESSION) or 0;
end

-- 1-竞拍期，2-选择阵营期，3-战争期，4-休战期
function Xkland:GetPeriod()
	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD) or 0;
end

-- 占城持续时间
function Xkland:GetOccupyTime()
	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_OCCUPY_DAY) or 0;
end

-- 判断战役状态，1-初始化, 2-开战, 0-结束
function Xkland:GetWarState()
	return self.nWarState or 0;
end

-- 计算城池箱子
function Xkland:CalcCastleBoxCount()
	local nBoxCount = 0;
	local nCurSystemMoney = GetGlobalSportTask(Xkland.GA_DBTASK_GID, Xkland.GA_DBTASK_SYSTEM_MONEY) or 0;
	local nExtraBox = self.tbCastleBuffer.nExtraBox or 0;
	nBoxCount = math.floor(nCurSystemMoney / self.CASTLE_RATE + 9) + nExtraBox;
	return nBoxCount;
end

-- 计算城池令牌
function Xkland:CalcLingPaiCount()
	return self.SHIWEI_LINGPAI;
end

-- 计算城主令牌的数目
function Xkland:CalcChengZhuLingPaiCount()
	return self.CHENGZHU_LINGPAI;
end

-- 计算玩家箱子
function Xkland:CalcPlayerBoxCount(nSort, nAwardCount, nMultiple)
	
	if nAwardCount <= 0 or nMultiple <= 0 then
		return 0;
	end
	
	for nLevel, tbInfo in ipairs(self.PLAYER_BOX_RADIO) do
		local nLimit = math.floor(nAwardCount * tbInfo[1]);
		local nBox = math.floor(nMultiple * tbInfo[2]);
		if nSort <= nLimit then
			return nBox;
		end 
	end
	return 0;
end

-- 计算投入与产出
function Xkland:CalcMemberAward(nAwardCount, nMultiple)
	
	if nAwardCount <= 0 then
		return 0;
	end
	
	local nRet = 0;
	local nTotal = 0;
	local tbRet = {};
	for nLevel, tbInfo in ipairs(self.PLAYER_BOX_RADIO) do
		local nSort = math.floor(nAwardCount * tbInfo[1]);
		local nBox = math.floor(nMultiple * tbInfo[2]);
		tbRet[nLevel] = {nSort, nBox};
		nRet = nRet + (nSort - nTotal) * nBox * self.BOX_MONEY;
		nTotal = nSort;
	end
	
	return nRet, tbRet;
end

-- 获取玩家总排名
function Xkland:GetPlayerSort(szPlayerName)
	for nSort, tbInfo in ipairs(self.tbSortPlayer) do
		if szPlayerName == tbInfo.szPlayerName then
			return nSort;
		end
	end
	return 0;
end

-- 计算玩家经验
function Xkland:CalcPlayerExp(nSort, nTotal)
	for nLevel, tbInfo in ipairs(self.PLAYER_EXP_RADIO) do
		if nSort <= math.max(math.floor(nTotal * tbInfo[1]), 1) then
			return tbInfo[2];
		end 
	end
	return 0;
end

-- 帮助锦囊
function Xkland:UpdateHelpTable(szGroupName, szPlayerName, szGateway)
	
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
	
	local szMsg = string.format([[

<color=yellow>第<color=cyan>%s<color><color=yellow>届的跨服城战已结束！<bclr=red>%s<bclr>获胜！<color>

<color=green>铁浮城现任城主：<color>

    <bclr=red><color=yellow>%s<color><bclr><color=yellow>（%s）<color>

<color=green>城主专属：<color>
    <color=yellow>凌天披风--<color><item=1,17,13,9><item=1,17,13,10><item=1,17,14,9><item=1,17,14,10>
    <color=yellow>凌天神驹--<color><item=1,12,29,4>
    <color=yellow>城主雕像<color>

]], self:GetSession(), szGroupName, szPlayerName, ServerEvent:GetServerNameByGateway(szGateway));
	
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_XKLAND_RESULT, "跨服城战战报", szMsg, nEndTime, nAddTime);
end

-- 清除帮助锦囊
function Xkland:ClearHelpTable()
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_XKLAND_RESULT, "跨服城战战报", "", nEndTime, nAddTime);
end

-- 判断当日是否开启战争
function Xkland:CheckWarTaskOpen()
	
	local nPeriod = 0;
	local nDay = tonumber(os.date("%w", GetTime()));
	
	if self:GetSession() == 1 then
		nPeriod = self.PERIOD_DAY_FIRST[nDay];
	else
		nPeriod = self.PERIOD_DAY_NORMAL[nDay];
	end
	
	return (nPeriod == self.PERIOD_WAR_OPEN and 1) or 0;
end

-- 获取军团名字
function Xkland:GetGroupNameByIndex(nGroupIndex)
	local szGroupName = "";
	if Xkland:GetSession() == 1 then
		szGroupName = string.format("第%s军团", Lib:Transfer4LenDigit2CnNum(nGroupIndex));
	else
		szGroupName = self.NORMAL_TITLE[nGroupIndex];
	end
	return szGroupName;
end
