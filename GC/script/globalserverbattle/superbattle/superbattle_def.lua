-------------------------------------------------------
-- 文件名　：superbattle_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-06-02 09:46:14
-- 文件描述：
-------------------------------------------------------

-- 中心服务器
SuperBattle.IS_GLOBAL 				= GLOBAL_AGENT or 0;

-- 任务变量组
SuperBattle.TASK_GID				= 2169;

-- 本地服务器用
SuperBattle.TASK_FIGHTPOWER			= 1;					-- 本服存储战斗力
SuperBattle.TASK_BOX				= 2;					-- 本服领取箱子
SuperBattle.TASK_EXP				= 3;					-- 本服领取经验
SuperBattle.TASK_WEEK				= 4;					-- 本服领奖周号
SuperBattle.TASK_MANTLE				= 5;					-- 本服披风资格
SuperBattle.TASK_INTERAL			= 6;					-- 本服报名时间
SuperBattle.TASK_SIGNUP				= 7;					-- 成功开场次数

-- 中心服务器用
SuperBattle.TASK_WATTING			= 11;					-- 保留标记
SuperBattle.TASK_SERIES_KILL		= 12;					-- 连斩标记		

-- 跨服任务变量
SuperBattle.GA_TASK_GID				= 8;
SuperBattle.GA_TASK_POINT			= 1;					-- 玩家积分
SuperBattle.GA_TASK_SORT			= 2;					-- 玩家排名
SuperBattle.GA_TASK_BOX				= 3;					-- 奖励箱子
SuperBattle.GA_TASK_EXP				= 4;					-- 奖励经验
SuperBattle.GA_TASK_RST				= {5, 6, 7};			-- 三场战绩
SuperBattle.GA_TASK_GPA				= 8;					-- 战绩总和
SuperBattle.GA_TASK_COUNT			= 9;					-- 参加场次
SuperBattle.GA_TASK_MANTLE			= 10;					-- 披风资格
SuperBattle.GA_TASK_WEEK			= 11;					-- 个人周标
SuperBattle.GA_TASK_DAY				= 12;					-- 参加日期
SuperBattle.GA_TASK_REPUTE			= 13;					-- 本场威望
SuperBattle.GA_TASK_TASK1			= 14;					-- 英雄路任务
SuperBattle.GA_TASK_TASK2			= 15;					-- 百尺竿头任务
SuperBattle.GA_TASK_LAST_GPA		= 16;					-- 上周基点
SuperBattle.GA_TASK_LAST_SORT		= 17;					-- 上周排名

-- 跨服全局变量
SuperBattle.GA_DBTASK_GID			= 5;
SuperBattle.GA_DBTASK_OPEN			= 11;					-- 活动开关
SuperBattle.GA_DBTASK_SESSION		= 12;					-- 流水号
SuperBattle.GA_DBTASK_WEEK			= 13;					-- 周标号
SuperBattle.GA_DBTASK_SIGNUP		= 14;					-- 报名开关
SuperBattle.GA_DBTASK_QUEUE			= 15;					-- 排队人数

-- 常量定义
SuperBattle.MANTLE_LEVEL			= 5;					-- 披风等级
SuperBattle.MAX_OFFSET				= 50;					-- 战斗力偏移量
SuperBattle.MAX_QUEUE				= 40;					-- 最大战场人数
SuperBattle.MIN_QUEUE				= 2;					-- 最小战场人数
SuperBattle.MAX_FRAMETRANS			= 30;					-- 每次传送人数
SuperBattle.NPC_LEVEL				= 120;					-- 怪物等级
SuperBattle.BASE_SERIES_KILL		= 3;					-- 连斩下限
SuperBattle.MAX_ATT_DAY				= 2;					-- 场次上限
if (EventManager.IVER_bOpenTiFu == 1) then
	SuperBattle.MAX_ATT_DAY				= 5;					-- 体服场次上限
end
SuperBattle.MAX_OVERFLOW			= 2000000000;			-- 溢出数字
SuperBattle.MAX_BUFFER_LEN			= 3000;					-- 排行榜长度
SuperBattle.MAX_MANTLE				= 30;					-- 披风资格人数
SuperBattle.BASE_BOX				= 400;					-- 基础箱子
SuperBattle.REPUTE_COST				= 10;					-- 威望惩罚

-- 时间定义
SuperBattle.DEAMON_TIME				= 5 * Env.GAME_FPS;		-- 守护计时器(帧)
SuperBattle.TRANS_TIME				= 1 * Env.GAME_FPS;		-- 分批传送(帧)
SuperBattle.UPDATE_TIME				= 5 * Env.GAME_FPS;		-- 更新数据(帧)
SuperBattle.READY_TIME				= 300;					-- 准备时间(秒)
SuperBattle.CAMPFIGHT_TIME			= 600;					-- 营地阶段(秒)
SuperBattle.ADMIRAL_TIME			= 900;					-- 将军阶段(秒)
SuperBattle.MARSHAL_TIME			= 900;					-- 元帅阶段(秒)
SuperBattle.SUPER_TIME				= 5;					-- 保护时间(秒)
SuperBattle.GAME_WAITING			= 300;					-- 场次间隔(秒)
SuperBattle.OPEN_DAY				= 20110712;				-- 开放日期
SuperBattle.BUFFER_TIME				= 640800 * Env.GAME_FPS;-- buffer时间(帧)
SuperBattle.INTERAL_TIME			= 60;					-- 报名间隔(秒)

-- 积分相关
SuperBattle.KILL_PLAYER_POINT		= 200;					-- 杀人积分
SuperBattle.PROTECT_DISTANCE		= 30;					-- 护卫距离
SuperBattle.POLE_PROTECT_POINT		= 5;					-- 护卫营地积分
SuperBattle.ADMIRAL_PROTECT_POINT 	= 10;					-- 护卫将军积分
SuperBattle.MARSHAL_PROTECT_POINT 	= 15;					-- 护卫元帅积分
SuperBattle.OCCUPY_POLE_POINT		= 150;					-- 占领营地积分
SuperBattle.KILL_ADMIRAL_POINT		= 1500;					-- 击杀将军积分
SuperBattle.KILL_MARSHAL_POINT		= 3000;					-- 击杀元帅积分
SuperBattle.KILL_GUARD_POINT		= 500;					-- 击杀卫士积分
SuperBattle.SHARE_CAMP_RATE			= 0.1;					-- 阵营共享系数
SuperBattle.SHARE_TEAM_RATE			= 0.2;					-- 队伍共享系数
SuperBattle.SERIES_KILL_RATE		= 0.25;					-- 连斩放大率
SuperBattle.POLE_CAMP_POINT			= 15;					-- 每15秒营地积分
SuperBattle.ADMIRAL_CAMP_POINT		= 30;					-- 每15秒将军积分
SuperBattle.KILL_ADMIRAL_CAMP_POINT	= 3000;					-- 击杀将军阵营积分
SuperBattle.KILL_MARSHAL_CAMP_POINT	= 10000;				-- 击杀元帅阵营积分
SuperBattle.MIN_POINT				= 1000;					-- 奖励下限积分
SuperBattle.DECAY_POLE_POINT		= 2000;					-- 营地衰减积分

-- war period
SuperBattle.WAR_INIT				= 1;					-- 初始化
SuperBattle.WAR_CAMPFIGHT			= 2;					-- 营地争夺
SuperBattle.WAR_ADMIRAL				= 3;					-- 护卫将军
SuperBattle.WAR_MARSHAL				= 4;					-- 护卫元帅
SuperBattle.WAR_END					= 0;					-- 游戏结束

-- 消息类型
SuperBattle.MSG_TOP					= 1;					-- 全服公告
SuperBattle.MSG_MIDDLE				= 2;					-- 中央红字
SuperBattle.MSG_BOTTOM				= 3;					-- 底部黑条
SuperBattle.MSG_CHANNEL				= 4;					-- 频道提示

-- npc id
SuperBattle.NPC_POLE_BABY_ID 		= {[1] = 4709, [2] = 4710};
SuperBattle.NPC_MARSHAL_MOVE_ID 	= {[1] = 4711, [2] = 4712};
SuperBattle.NPC_MARSHAL_ARRIVE_ID 	= {[1] = 4713, [2] = 4714};

-- item id
SuperBattle.YOULONG_ID				= {18, 1, 553, 1};
SuperBattle.AWARDBOX_ID				= {18, 1, 1320, 1};
SuperBattle.LOSTBOX_ID				= {18, 1, 476, 1};
SuperBattle.HAMMER_ID				= {18, 1, 1312, 1};
SuperBattle.PAD_ID					= {18, 1, 734, 1};
SuperBattle.MEDICINE_ID	=
{
	[1] = {"Hồi Huyết Đơn-Rương", {18, 1, 731, 2}},
	[2] = {"Hồi Nội Đơn-Rương", {18, 1, 732, 2}},
	[3] = {"Càn Khôn Tạo Hóa Hoàn-Rương", {18, 1, 733, 2}},
};
SuperBattle.PAD_CHANGE_ID =
{
	[1] = {"Lệnh bài Đại Tướng Mông Cổ Tây Hạ", {18, 1, 289, 1}}, 
	[2] = {"Lệnh bài Phó Tướng Mông Cổ Tây Hạ", {18, 1, 289, 2}},
	[3] = {"Lệnh bài Thống Lĩnh Mông Cổ Tây Hạ", {18, 1, 289, 3}},
};

-- 图标编号
SuperBattle.PIC_FIGHT				= 5;
SuperBattle.PIC_MARSHAL				= 9;
SuperBattle.PIC_CAMP 				= {[0] = 11, [1] = 7, [2] = 8};

-- title id
SuperBattle.TITLE_ID				= {14, 3, 1, 0};

-- buffer id
SuperBattle.BUFFER_ID				= 1629;
SuperBattle.DIE_BUFFER_ID			= 1962;
SuperBattle.IN_BUFFER_ID			= 2226;
 
-- Buffer索引
SuperBattle.nBufferIndex = GBLINTBUF_SUPERBATTLE;
SuperBattle.tbGlobalBuffer = SuperBattle.tbGlobalBuffer or {};

-- 计时器
SuperBattle.tbTimerId = SuperBattle.tbTimerId or {};

-- 行走路线
SuperBattle.CAMP_ROUTE =
{
	[1] = "\\setting\\globalserverbattle\\superbattle\\path_song.txt",
	[2] = "\\setting\\globalserverbattle\\superbattle\\path_jin.txt",
};

-- 接引人坐标
SuperBattle.TRANS_POS = {1759, 3498};

-- transfer id 对应准备场
SuperBattle.SIGNUP_MAP = 
{
	[1]  = 2056,
	[2]  = 2057,
	[3]  = 2058,
	[4]  = 2059,
	[5]  = 2060,
	[6]  = 2061,
	[7]  = 2062,
	[8]  = 2063,
	[9]  = 2064,
	[10] = 2065,
	[11] = 2066,
	[12] = 2067,
	[13] = 2068,
	[14] = 2069,
	[15] = 2070,
};

-- transfer id 对应战斗场
SuperBattle.BATTLE_MAP = 
{
	[1]  = 2071,
	[2]  = 2072,
	[3]  = 2073,
	[4]  = 2074,
	[5]  = 2075,
	[6]  = 2076,
	[7]  = 2077,
	[8]  = 2078,
	[9]  = 2079,
	[10] = 2080,
	[11] = 2081,
	[12] = 2082,
	[13] = 2083,
	[14] = 2084,
	[15] = 2085,
};

-- 准备场随机坐标
SuperBattle.SIGNUP_POS =
{
	[1] = {1668, 3225},
	[2] = {1668, 3266},
	[3] = {1695, 3265},
	[4] = {1695, 3237},
};

-- 后营坐标
SuperBattle.CAMP_POS =
{
	[1] = {{1527, 4035}, {1548, 4013}, {1579, 4086}, {1599, 4065}},
	[2] = {{2067, 3344}, {2090, 3345}, {2110, 3363}, {2119, 3399}},
};

-- 阵营名字
SuperBattle.CAMP_NAME =
{
	[1] = "Mông Cổ",
	[2] = "Tây Hạ",
};

-- 积分头衔
SuperBattle.RANK_POINT =
{
	[1] = {0, "Sĩ Binh", "white"},
	[2] = {1000, "Hiệu Úy", "green"},
	[3] = {3000, "Thống Lĩnh", "cyan"},
	[4] = {6000, "Phó Tướng", "pink"},
	[5] = {10000, "Đại Tướng", "orange"},
};

-- 营地旗子
SuperBattle.POLE_POS =
{
	[1] = {tbPos = {1603, 3887}, tbTransPos = {1607, 3887}, tbCamp = {[0] = 4695, [1] = 4697, [2] = 4699}, nOrgCamp = 1, szName = "Quân doanh (Huyền Vũ)"},
	[2] = {tbPos = {1901, 3870}, tbTransPos = {1906, 3869}, tbCamp = {[0] = 4694, [1] = 4696, [2] = 4698}, nOrgCamp = 0, szName = "Quân doanh (Chu Tước)"},
	[3] = {tbPos = {1771, 3796}, tbTransPos = {1776, 3796}, tbCamp = {[0] = 4694, [1] = 4696, [2] = 4698}, nOrgCamp = 0, szName = "Quân doanh (Bạch Hổ)"},
	[4] = {tbPos = {1656, 3653}, tbTransPos = {1662, 3652}, tbCamp = {[0] = 4695, [1] = 4697, [2] = 4699}, nOrgCamp = 0, szName = "Quân doanh (Thanh Long)"},
	[5] = {tbPos = {2121, 3477}, tbTransPos = {2125, 3477}, tbCamp = {[0] = 4694, [1] = 4696, [2] = 4698}, nOrgCamp = 2, szName = "Quân doanh (Bắc Đẩu)"},
	[6] = {tbPos = {1982, 3748}, tbTransPos = {1987, 3748}, tbCamp = {[0] = 4695, [1] = 4697, [2] = 4699}, nOrgCamp = 0, szName = "Quân doanh (Cát Tường)"},
	[7] = {tbPos = {1911, 3594}, tbTransPos = {1915, 3595}, tbCamp = {[0] = 4695, [1] = 4697, [2] = 4699}, nOrgCamp = 0, szName = "Quân doanh (Kim Lân)"},
	[8] = {tbPos = {1776, 3500}, tbTransPos = {1780, 3499}, tbCamp = {[0] = 4694, [1] = 4696, [2] = 4698}, nOrgCamp = 0, szName = "Quân doanh (Như Ý)"},
};

-- 将军坐标
SuperBattle.ADMIRAL_POS = 
{
	[1] = 
	{
		[1] = {nStand = 4683, nFight = 4684, tbPos = {1619, 3721}}, 
		[2] = {nStand = 4685, nFight = 4686, tbPos = {1827, 3908}},
	},
	[2] =
	{
		[1] = {nStand = 4690, nFight = 4691, tbPos = {2051, 3648}}, 
		[2] = {nStand = 4692, nFight = 4693, tbPos = {1843, 3448}},
	},
};

-- 元帅坐标
SuperBattle.MARSHAL_POS = 
{
	[1] = {nStand = 4680, nMove = 4681, nFight = 4682, tbPos = {1727, 4003}},
	[2] = {nStand = 4687, nMove = 4688, nFight = 4689, tbPos = {1924, 3341}},
};

-- trap点
SuperBattle.MAP_TRAP_POS =
{
	["song_in"] 	= {1606, 4006, 1, 1},
	["song_out"]	= {1598, 4019, 0, 1},
	["jin_in"]	 	= {2055, 3413, 1, 2},
	["jin_out"] 	= {2063, 3400, 0, 2},
};

-- 开放时间段
SuperBattle.TIME_PERIOD = {[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 0, [0] = 2};

-- npc chat
SuperBattle.NPC_CHAT_MSG =
{
--	[1] = 
--	{
--		"来过，活过，爱过。。。",
--		"716是谁？卖豆腐的吧",
--		"不，我心目中的天下第一高手，永远是张老英雄！",
--		"小涵，小涵。。。你在哪里啊",
--		"我心中是有一个秘密，但绝不会告诉你",
--		"七年前，我错杀了一个人，他。。。好像姓龙",
--	},
--	[2] =
--	{
--		"我曾经爱过一个女人，她叫慕容素",
--		"哼，716他敢接我三招么？",
--		"七年前，只有我能接张英雄十招",
--		"昆少不会占位",
--		"其实，我也很空虚。。。",
--		"朕还有一招绝学，你们想看么？",
--	},
	[1] = 
	{
		"Mỗi tấc đất đều thấm máu của các chiến sĩ đã ngã xuống, chúng ta không được để mất.",
		"Hãy tụ lại quanh ta, ta sẽ cho các con sức mạnh!",
		"Phải tìm tên cầm đầu, để hắn biết sự lợi hại của ta.",
		"Nhanh như gió, vững như núi, tướng sĩ dưới trướng ta là anh dũng nhất.",
		"Nắm lấy cơ hội, dùng một chiêu chí mạng.",
		"Điểm tích lũy càng nhiều phần thưởng càng cao.",
	},
	[2] =
	{
		"Mỗi tấc đất đều thấm máu của các chiến sĩ đã ngã xuống, chúng ta không được để mất.",
		"Hãy tụ lại quanh ta, ta sẽ cho các con sức mạnh!",
		"Phải tìm tên cầm đầu, để hắn biết sự lợi hại của ta.",
		"Nhanh như gió, vững như núi, tướng sĩ dưới trướng ta là anh dũng nhất.",
		"Nắm lấy cơ hội, dùng một chiêu chí mạng.",
		"Điểm tích lũy càng nhiều phần thưởng càng cao.",
	},
};

-- 计算经验
function SuperBattle:CalcPlayerExp(nSort, nTotal)
	return 900 - math.floor(600 * nSort / nTotal);
end

-- 计算绑银
function SuperBattle:CalcPlayerBindMoney(nExp)
	return 40000 + math.floor(nExp * 200 / 3);
end

-- 计算基础箱子
function SuperBattle:CalcPlayerAward(nGpa)
	return math.floor(16 * nGpa / 9);
end

-- 计算排名箱子
function SuperBattle:CalcPlayerAwardEx(nSort, nTotal)
	return 400 - math.floor(200 * nSort / nTotal);
end

-- 计算战绩
function SuperBattle:CalcPlayerResult(nSort, nTotal)
	return math.floor(150 - (nSort - 1) * 100 / nTotal);
end

-- 是否全局服务器
function SuperBattle:CheckIsGlobal()
	return self.IS_GLOBAL or 0;
end

-- 系统是否开启
function SuperBattle:CheckIsOpen()
	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_OPEN) or 0;
end

-- 报名是否开启
function SuperBattle:CheckIsSignup()
	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SIGNUP) or 0;
end

-- 获取流水号
function SuperBattle:GetSession()
	return GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SESSION) or 0;
end

-- 获取周标号
function SuperBattle:GetWeek()
	return math.max(GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_WEEK), 1);
end

-- 获取每天阶段
function SuperBattle:GetDailyPeriod()
	local nDay = tonumber(os.date("%w", GetTime()));
	if nDay == 6 and tonumber(GetLocalDate("%H%M")) < 1600 then
		return 1;
	end
	return self.TIME_PERIOD[nDay];
end

-- 封一个statlog接口
function SuperBattle:StatLog(szKey, nPlayerId, ...)
	StatLog:WriteStatLog("stat_info", "superbattle", szKey, nPlayerId, unpack(arg));
end

-- 启动计时器
function SuperBattle:StartTimer(nTime, fnTimer, szType, ...)
	self:ClearTimer(szType);
	if arg then
		self.tbTimerId[szType] = Timer:Register(nTime, fnTimer, self, unpack(arg));
	else
		self.tbTimerId[szType] = Timer:Register(nTime, fnTimer, self);
	end
end

-- 关闭计时器
function SuperBattle:ClearTimer(szType)
	local nTimerId = self.tbTimerId[szType];
	if nTimerId and nTimerId > 0 then
		local nRest = Timer:GetRestTime(nTimerId);
		if nRest ~= -1 then
			Timer:Close(nTimerId);
		end
		self.tbTimerId[szType] = nil;
	end
end

-- 获取最差成绩
function SuperBattle:GetMinRst(nPlayerId)
	local nRet = 0;
	local nRst = 150;
	for _, nTask in ipairs(self.GA_TASK_RST) do
		local nTmpRst = GetPlayerSportTask(nPlayerId, self.GA_TASK_GID, nTask) or 0;
		if nTmpRst < nRst then
			nRst = nTmpRst;
			nRet = nTask;
		end
	end
	return nRet, nRst;
end

-- 计算威望
function SuperBattle:CalcPlayerRepute(nSort, nPoint)
	if nSort == 1 then
		return 20;
	elseif nSort <= 10 then
		return 16;
	elseif nSort <= 20 then
		return 12;
	elseif nPoint >= 4500 then
		return 10;
	elseif nPoint >= 3000 then
		return 8;
	elseif nPoint >= 1800 then
		return 6;
	elseif nPoint >= 1200 then
		return 4;
	elseif nPoint >= 800 then
		return 2;
	end
	return 0;
end

-- 计算家族贡献度
function SuperBattle:CalcPlayerOffer(nSort, nPoint)
	if nSort <= 3 then
		return 150;
	elseif nSort <= 10 then
		return 120;
	elseif nSort <= 20 then
		return 100;
	elseif nPoint >= 5000 then
		return 80;
	elseif nPoint >= 4000 then
		return 60;
	elseif nPoint >= 3000 then
		return 40;
	elseif nPoint >= 1500 then
		return 30;
	end
	return 0;
end
