-------------------------------------------------------
-- 文件名　：newland_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-03 15:27:30
-- 文件描述：
-------------------------------------------------------

-- 中心服务器
Newland.IS_GLOBAL 				= GLOBAL_AGENT or 0;

-- 本服任务变量
Newland.TASK_GID 				= 2142;

-- 本地服务器用
Newland.TASK_TONGNAME			= 1;					-- 记录帮会名字(1-8)
Newland.TASK_SESSION			= 9;					-- 记录参加的届数
Newland.TASK_SIGNUP				= 10;					-- 是否报名
Newland.TASK_WAR_BOX			= 11;					-- 记录本服领取的箱子
Newland.TASK_WAR_EXP			= 12;					-- 记录本服领取经验次数
Newland.TASK_INTERVAL			= 13;

-- 中心服务器用
Newland.TASK_LAND_ENTER			= 21;					-- 从英雄岛上进入标志
Newland.TASK_SERIES_KILL		= 22;					-- 连斩标记
Newland.TASK_GROUP_INDEX		= 23;					-- 军团编号

-- 跨服任务变量
Newland.GA_TASK_GID				= 5;
Newland.GA_TASK_WAR_RANK		= 1;					-- 跨服城战排名
Newland.GA_TASK_WAR_POINT		= 2;					-- 跨服城战积分
Newland.GA_TASK_WAR_BOX			= 3;					-- 可以领箱子个数
Newland.GA_TASK_WAR_EXP			= 4;					-- 可以领经验个数

-- 跨服全局变量
Newland.GA_DBTASK_GID			= 4;
Newland.GA_DBTASK_OPEN			= 11;					-- 系统开关
Newland.GA_DBTASK_SESSION		= 12;					-- 跨服城战届数
Newland.GA_DBTASK_PERIOD		= 13;					-- 跨服城战阶段

-- 常量定义
Newland.MAX_GROUP				= 45;					-- 最大帮会数量
Newland.MIN_GROUP				= 3; 					-- 最小帮会数量

Newland.MAX_MAP_PLAYER			= 400;					-- 每个地图最大人数
Newland.MAX_OVERFLOW			= 2000000000;			-- 防溢出数字
Newland.MAX_MAP_GROUP			= 3;					-- 每个战场最大帮会数量
Newland.MIN_POLE				= 3;					-- 最少占领龙柱数量

Newland.MANTLE_LEVEL			= EventManager.IVER_nNewLandMinLevel;				-- 披风等级
Newland.MIN_MEMBER				= 10; --EventManager.IVER_nNewLandMinTongMember;			-- 30个雏凤披风
Newland.MIN_MANTLE_LEVEL_NAME	= EventManager.IVER_szNewLandMinLevelName;
Newland.CONDITION_JOIN_NEWLAMD	= string.format("<color=green>Điều kiện tham gia:<enter>    1、Đạt cấp 100, đã gia nhập môn phái;<enter>    2、Phi phong thấp nhất là %s;<enter>    3、Thủ lĩnh đại diện khiêu chiến.<color>", Newland.MIN_MANTLE_LEVEL_NAME);

-- period
Newland.PERIOD_SIGNUP			= 1;					-- 报名期
Newland.PERIOD_WAR_OPEN			= 2;					-- 战争期
Newland.PERIOD_WAR_REST			= 0;					-- 休战期

-- war period
Newland.WAR_INIT				= 1;
Newland.WAR_START				= 2;
Newland.WAR_END					= 0;

-- 时间相关
Newland.READY_TIME				= 30 * 60;				-- 开战前准备时间
Newland.PLAY_TIME				= 90 * 60;				-- 战斗进行时间
Newland.UPDATE_POINT_TIME		= 15 * Env.GAME_FPS;	-- 更新军团积分
Newland.SYNC_DATE_TIME			= 5 * Env.GAME_FPS;		-- 更新即时战报
Newland.ANNOUNCE_TIME			= 600 * Env.GAME_FPS;	-- 宣传公告时间
Newland.THRONE_BUFFER			= 1627;					-- 占领王座后buffer
Newland.THRONE_BUFFER_TIME		= 7200 * Env.GAME_FPS;	-- 占领王座buffer时间

-- 积分相关
Newland.OCCUPY_POLE_POINT		= 50;					-- 占领龙柱积分
Newland.KILL_PLAYER_POINT		= 100;					-- 杀人增加积分
Newland.BASE_POLE_POINT			= 20;					-- 15秒军团龙柱积分
Newland.BASE_THRONE_POINT		= 100;					-- 15秒军团王座积分
Newland.PROTECT_POINT			= 10;					-- 15秒个人护卫积分
Newland.PLAYER_THRONE_POINT		= 50;					-- 15秒个人王座积分
Newland.PROTECT_DISTANCE		= 30;					-- 护卫距离

-- 奖励相关
Newland.CASTLE_BOX				= 15;
Newland.NORMAL_PAD				= 3;
Newland.CASTLE_PAD				= 1;
Newland.PLAYER_SORT_RADIO		= 5;
Newland.GROUP_SORT_RADIO		= 2;
Newland.PLAYER_WAR_EXP			= 2000000;
Newland.PLAYER_WAR_REPUTE		= 20;
Newland.PLAYER_POINT_LIMIT		= 500;
Newland.NORMAL_BOX_PRICE		= 50000;
Newland.CASTLE_BOX_PRICE		= 2000000;
Newland.CASTLE_SELL_BOX			= 50;

-- buffer列表
Newland.GBLBUFFER_LIST = 
{
	[GBLINTBUF_NL_SIGNUP]		= "tbSignupBuffer",
	[GBLINTBUF_NL_GROUP]		= "tbGroupBuffer",
	[GBLINTBUF_NL_WAR]			= "tbWarBuffer",
	[GBLINTBUF_NL_PLAYER]		= "tbPlayerBuffer",
	[GBLINTBUF_NL_CASTLE]		= "tbCastleBuffer",
	[GBLINTBUF_NL_HISTORY_EX]	= "tbCastleHistoryBuffer",
};

-- item id
Newland.NORMAL_BOX_ID			= {18, 1, 939, 1};
Newland.CASTLE_BOX_ID			= {18, 1, 940, 1};
Newland.NORMAL_PAD_ID			= {20, 1, 870, 1};
Newland.CASTLE_PAD_ID			= {20, 1, 869, 1};
Newland.YANHUA_ID				= {18, 1, 70, 1};
Newland.JADE_ID					= {18, 1, 1491, 1};
Newland.MOON_ID					= {18, 1, 476, 1};

-- msg type
Newland.SYSTEM_CHANNEL_MSG		= 1;
Newland.BOTTOM_BLACK_MSG		= 2;
Newland.MIDDLE_RED_MSG			= 3;
Newland.TOP_YELLOW_MSG			= 4;

-- pic type
Newland.SELF_POLE_PIC			= 7;
Newland.ENEMY_POLE_PIC			= 8;

-- 地图列表
Newland.MAP_LIST =
{
	[1] = {1812, 1813, 1814, 1815, 1816, 1817, 1818, 1819, 1820, 1821, 1822, 1823, 1824, 1825, 1826},
	[2] = {1827, 1828, 1829, 1830, 1831},
	[3] = {1832},
};

-- 复活点列表
Newland.REVIVAL_LIST =
{
	[1] = {1647, 3345}, 
	[2] = {1884, 3302}, 
	[3] = {1819, 3576},
};

-- 地图积分加权
Newland.MAP_LEVEL_WEIGHT = {1, 1.5, 2};

-- 地图名称
Newland.MAP_LEVEL_NAME =
{
	[1] = "Ngoại thành",
	[2] = "Nội thành",
	[3] = "Ngai vàng",
};

-- 个人排名加权
Newland.PLAYER_SORT_EXTRA = {3, 2, 1};

-- 帮会排名加权
Newland.GROUP_SORT_EXTRA = {10, 5, 3};

-- 王座mapid
Newland.THRONE_MAP_ID = 1832;
Newland.THRONE_POS = {1832, 1786, 3453};

-- 龙柱坐标
Newland.POLE_ID = 9753;
Newland.POLE_LIST =
{
	[1] = {{1615, 3223}, {1924, 3200}, {1873, 3662}, {1768, 3338}, {1834, 3441}},
	[2] = {{1807, 3201}, {1960, 3469}, {1925, 3569}, {1653, 3571}, {1617, 3469}},
	[3] = {{1626, 3467}, {1787, 3625}, {1952, 3460}, {1788, 3298}},
};

-- 头衔积分列表
Newland.RANK_POINT =
{
	[1] = {1000, "Sĩ binh", "white"},
	[2] = {2000, "Hiệu úy", "green"},
	[3] = {3000, "Thống lĩnh", "cyan"},
	[4] = {5000, "Phó tướng", "pink"},
	[5] = {8000, "Đại tướng", "gold"},
	[6] = {13000, "Nguyên soái", "yellow"},
};

-- 雕像坐标
Newland.STATUE_POS = 
{
	 [0] = {tbPos = {1804, 3493}, tbMapId = {24}},
	 [1] = {tbPos = {1854, 3375}, tbMapId = {1609, 1610, 1611, 1612, 1613, 1614, 1615, 1645, 1646, 1647, 1648, 1649, 1650}},
};

-- 雕像id
Newland.STATUE_ID = {[0] = 6867, [1] = 6868};

-- 系统每周阶段
Newland.PERIOD_LIST = {[1] = 0, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 2, [0] = 0};

-- 地图传送点
Newland.NPC_CLASS = 
{
	["newland_revival_in_11"] 	= {MapLevel = 1, FightState = 1, SuperTime = 5, Check = "Check_RevivalOut", StepMap = 0, TransPos = {{1676, 3372}}},
	["newland_revival_out_11"] 	= {MapLevel = 1, FightState = 0, SuperTime = 0, Check = "Check_RevivalIn", StepMap = 0, TransPos = {{1647, 3345}}},
	["newland_revival_in_21"] 	= {MapLevel = 1, FightState = 1, SuperTime = 5, Check = "Check_RevivalOut", StepMap = 0, TransPos = {{1908, 3266}}},
	["newland_revival_out_21"] 	= {MapLevel = 1, FightState = 0, SuperTime = 0, Check = "Check_RevivalIn", StepMap = 0, TransPos = {{1884, 3302}}},
	["newland_revival_in_31"] 	= {MapLevel = 1, FightState = 1, SuperTime = 5, Check = "Check_RevivalOut", StepMap = 0, TransPos = {{1847, 3605}}},
	["newland_revival_out_31"] 	= {MapLevel = 1, FightState = 0, SuperTime = 0, Check = "Check_RevivalIn", StepMap = 0, TransPos = {{1819, 3576}}},
	["newland_revival_in_12"] 	= {MapLevel = 1, FightState = 1, SuperTime = 5, Check = "Check_RevivalOut", StepMap = 0, TransPos = {{1621, 3314}}},
	["newland_revival_out_12"] 	= {MapLevel = 1, FightState = 0, SuperTime = 0, Check = "Check_RevivalIn", StepMap = 0, TransPos = {{1647, 3345}}},
	["newland_revival_in_22"] 	= {MapLevel = 1, FightState = 1, SuperTime = 5, Check = "Check_RevivalOut", StepMap = 0, TransPos = {{1855, 3337}}},
	["newland_revival_out_22"] 	= {MapLevel = 1, FightState = 0, SuperTime = 0, Check = "Check_RevivalIn", StepMap = 0, TransPos = {{1884, 3302}}},
	["newland_revival_in_32"] 	= {MapLevel = 1, FightState = 1, SuperTime = 5, Check = "Check_RevivalOut", StepMap = 0, TransPos = {{1801, 3548}}},
	["newland_revival_out_32"] 	= {MapLevel = 1, FightState = 0, SuperTime = 0, Check = "Check_RevivalIn", StepMap = 0, TransPos = {{1819, 3576}}},
	["newland_floor_1_to_2"] 	= {MapLevel = 1, FightState = 1, SuperTime = 8, Check = "Check_Next", StepMap = 1, TransPos = {{1672, 3384}, {1872, 3358}, {1790, 3543}}},
	["newland_floor_2_to_3"]	= {MapLevel = 2, FightState = 1, SuperTime = 8, Check = "Check_Next", StepMap = 1, TransPos = {{1513, 3251}, {1512, 3695}, {2070, 3227}, {1962, 3824}, {1618, 3138}, {1621, 3812}, {1978, 3116}, {2067, 3710}}},
	["newland_floor_3_to_2"] 	= {MapLevel = 3, FightState = 1, SuperTime = 8, Check = "Check_Back", StepMap = -1, TransPos = {{1672, 3384}, {1872, 3358}, {1790, 3543}}},
	["newland_floor_2_to_1"]	= {MapLevel = 2, FightState = 0, SuperTime = 8, Check = "Check_Back", StepMap = -1, TransPos = {{1647, 3345}, {1884, 3302}, {1819, 3576}}},
};

-- 报名数据
-- tbSignupBuffer = {[szTongName] = {szCaptainName, szGateway, nCaptainSex, nMemberCount, nSuccess}, ...}
Newland.tbSignupBuffer = Newland.tbSignupBuffer or {};

-- 军团数据
-- tbGroupBuffer = {[1] = {szCaptainName, szGateway, szTongName, nCaptainSex}, ...}
Newland.tbGroupBuffer = Newland.tbGroupBuffer or {};

-- 玩家数据
-- tbPlayerBuffer = {[szPlayerName] = {nGroupIndex, nPoint, nKillCount, nCurSeriesKill, nMaxSeriesKill, nRank, nProtect, nPole, nThrone}, ...}
Newland.tbPlayerBuffer = Newland.tbPlayerBuffer or {};

-- 战斗数据
-- tbWarBuffer = {[1] = {nGroupIndex, nPoint}, ...}
Newland.tbWarBuffer = Newland.tbWarBuffer or {};

-- 城堡数据
-- tbCastleBuffer = {szCaptainName, szGateway, szTongName, nCaptainSex, nGroupIndex, tbHistory = {szCaptainName, szGateway}}
Newland.tbCastleBuffer = Newland.tbCastleBuffer or {};

Newland.tbCastleHistoryBuffer = Newland.tbCastleHistoryBuffer or {};

-- 龙柱数据
Newland.tbPole = Newland.tbPole or {};

-- 王座数据
Newland.tbThrone = Newland.tbThrone or {nOwnerGroup = 0};

-- 地图人数
Newland.tbMapPlayerCount = Newland.tbMapPlayerCount or {};

-- 玩家排序
Newland.tbSortPlayer = Newland.tbSortPlayer or {};

-- 军团排序
Newland.tbSortGroup = Newland.tbSortGroup or {};

-- 城主雕像
Newland.tbCastleNpcId = Newland.tbCastleNpcId or {};

-- 计时器
Newland.tbTimerId = Newland.tbTimerId or {};

-- 军团成员数量
Newland.tbMemberCount = Newland.tbMemberCount or {};

-- 玩家排序
Newland.tbSortPlayer2 = Newland.tbSortPlayer2 or {};

-- 图腾列表
Newland.tbAtom = Newland.tbAtom or {};

Newland.tbZoneId2Name = {
		["gate0100"] = "Chiến khu 1",
		["gate0200"] = "白虎区",
		["gate0300"] = "朱雀区",
		["gate0400"] = "玄武区",
		["gate0500"] = "紫薇区",
		["gate0600"] = "北斗区",
		["gate0700"] = "金麟区",
		["gate1000"] = "吉祥区",
		["gate1100"] = "如意区",
	};

-- 系统是否开启
function Newland:CheckIsOpen()
	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_OPEN) or 0;
end

-- 是否全局服务器
function Newland:CheckIsGlobal()
	return self.IS_GLOBAL;
end

-- 第几届争夺
function Newland:GetSession()
	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SESSION) or 0;
end

-- 1-报名，2-战争，0-休战
function Newland:GetPeriod()
	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD) or 0;
end

-- 1-初始化, 2-开战, 0-结束
function Newland:GetWarState()
	return self.nWarState or 0;
end

-- 动态分组
function Newland:_DyncGroupTree(nGroupCount)
	local nCount = 1;
	local tbRet = {}
	for i = 1, nGroupCount do
		if math.mod(nGroupCount, self.MAX_MAP_GROUP) == 1 and i == nGroupCount - 1 then
			nCount = nCount + 1;
		end
		if not tbRet[nCount] then
			tbRet[nCount] = {};
		end
		table.insert(tbRet[nCount], i);
		if #tbRet[nCount] >= self.MAX_MAP_GROUP then
			nCount = nCount + 1;
		end
	end
	return tbRet;
end

-- 生成分组树
function Newland:BuildTree(nGroupCount)
	
	local tbTree = {};
	local tbTree1 = self:_DyncGroupTree(nGroupCount);
	local tbTree2 = self:_DyncGroupTree(#tbTree1);
	
	for nLevel2, tbGroup2 in pairs(tbTree2) do
		if not tbTree[nLevel2] then
			tbTree[nLevel2] = {};
			tbTree[nLevel2][0] = self.MAP_LIST[2][nLevel2];
		end
		local nT = tbTree[nLevel2];
		for nIndex2, nLevel1 in pairs(tbGroup2) do
			nT[nIndex2] = {};
			nT[nIndex2][0] = self.MAP_LIST[1][nLevel1];
			for nIndex1, nGroupIndex in pairs(tbTree1[nLevel1]) do
				nT[nIndex2][nIndex1] = nGroupIndex;
			end
		end
	end
	
	return tbTree;
end

-- 获取当日隶属阶段
function Newland:GetDailyPeriod()
	local nDay = tonumber(os.date("%w", GetTime()));
	return self.PERIOD_LIST[nDay];
end

-- 判断当日是否开启战争
function Newland:CheckWarTaskOpen()
	local nDay = tonumber(os.date("%w", GetTime()));
	local nPeriod = self.PERIOD_LIST[nDay];
	return (nPeriod == self.PERIOD_WAR_OPEN and 1) or 0;
end

-- 获取军团名字
function Newland:GetGroupNameByIndex(nGroupIndex)
	if not self.tbGroupBuffer[nGroupIndex] then
		return "未知";
	end
	return self.tbGroupBuffer[nGroupIndex].szTongName;
end

-- 获取网关
function Newland:GetGatewayByIndex(nGroupIndex)
	if not self.tbGroupBuffer[nGroupIndex] then
		return "未知";
	end
	return self.tbGroupBuffer[nGroupIndex].szGateway;
end

-- 获取军团编号
function Newland:GetGroupIndexByTongName(szTongName)
	for nIndex, tbInfo in pairs(self.tbGroupBuffer) do
		if tbInfo.szTongName == szTongName then
			return nIndex;
		end
	end
	return 0;
end

-- 计算玩家箱子
function Newland:CalcPlayerBoxCount(nSort, nTotal, nGroupSort, nGroupTotal)
	local nExtra = self.PLAYER_SORT_EXTRA[nSort] or 0;
	local nGroupExtra = (nSort <= 10) and (self.GROUP_SORT_EXTRA[nGroupSort] or 0) or 0;
	local nBase = 1 + self.PLAYER_SORT_RADIO * (1 - nSort / nTotal);
	local nWeight = 1 + self.GROUP_SORT_RADIO * (1 - nGroupSort / nGroupTotal);
	return math.floor((nBase * nWeight + nExtra + nGroupExtra) * 100);
end

-- 报名成功帮会数量
function Newland:GetSignupCount()
	local nCount = 0;
	for _, tbInfo in pairs(self.tbSignupBuffer) do
		nCount = nCount + tbInfo.nSuccess;
	end
	return nCount;
end

-- 计算经验
function Newland:CalcPlayerExp(nPoint)
	local nRet = 0;
	local tbList = 
	{
		[1] = 500,
		[2] = 1000,
		[3] = 2000,
		[4] = 4000,
		[5] = 8000,
	};
	for i, nPex in ipairs(tbList) do
		if nPoint >= nPex then
			nRet = i;
		end
	end
	return nRet;
end

-- test
Newland._TestPlayer = Newland._TestPlayer or {};

-- set open state
function Newland:_SetState(nState)
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_OPEN, nState);
end

function Newland:_T(nTotalGroup, nTotalMember)
	
	local szPath = "\\test.txt";
	local szMsg = "";
	for j = 1, nTotalGroup do
		szMsg = szMsg .. "\t" .. "Tong_" .. j;
	end
	szMsg = szMsg .. "\tTotal\n";
	KFile.AppendFile(szPath, szMsg);
	
	local tbTMPoint = {};
	for i = 1, nTotalMember do
		local nTGPoint = 0;
		local szMsg = "Player_" .. i;
		tbTMPoint[i] = {};
		for j = 1, nTotalGroup do
			local nPoint = Newland:CalcPlayerBoxCount(i, nTotalMember, j, nTotalGroup);
			szMsg = szMsg .. "\t" .. nPoint;
			nTGPoint = nTGPoint + nPoint;
			tbTMPoint[i][j] = nPoint;
		end
		szMsg = szMsg .. "\t" .. nTGPoint .."\n";
		KFile.AppendFile(szPath, szMsg);
	end
	
	szMsg = "Total";
	local nG = 0;
	for j = 1, nTotalGroup do
		local nTotal = 0;
		for i = 1, nTotalMember do
			nTotal = nTotal + tbTMPoint[i][j];
		end
		nG = nG + nTotal;
		szMsg = string.format("%s\t%s(%s)", szMsg, nTotal, math.floor(nTotal / 100));
	end
	szMsg = string.format("%s\t%s(%s)", szMsg, nG, math.floor(nG / 100));
	KFile.AppendFile(szPath, szMsg);
end

-- add for server balance 2011-4-20
Newland.IS_BALANCE				= 1;
Newland.AVE_LEVEL				= 130;
Newland.OVE_LEVEL				= 120;
Newland.BAL_SKILL_ID			= 2218;
Newland.TASK_BASE_LEVEL			= 24;

function Newland:CheckIsBalance()
	return self.IS_BALANCE or 1;
end

Newland.nDateCanDirOpen = 20120607;

function Newland:OpenTimeFrame()
	local nOpenTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nOpenDate = tonumber(os.date("%Y%m%d", nOpenTime));
	
	if (nOpenDate < self.nDateCanDirOpen) then
		return 1;
	end
	
	local nTimeFrameOpen = TimeFrame:GetState("GlobalKufuBattle");
	return nTimeFrameOpen;
end
