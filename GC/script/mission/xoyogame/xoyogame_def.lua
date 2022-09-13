--
-- 逍遥谷关卡 
-- 

local preEnv = _G	--保存旧的环境
setfenv(1, XoyoGame)	--设置当前环境为Kin

-- 事件ID

ADD_NPC 		= 1		-- 添加NPC
DEL_NPC			= 2		-- 删除NPC
CHANGE_TRAP		= 3		-- 更改Trip点
DO_SCRIPT		= 4		-- 执行脚本
TARGET_INFO		= 5		-- 目标信息
TIME_INFO		= 6		-- 时间信息
CLOSE_INFO		= 7		-- 关闭界面
CHANGE_FIGHT	= 8		-- 更换战斗状态
MOVIE_DIALOG	= 9		-- 电影模式
BLACK_MSG		= 10	-- 黑底字幕
CHANGE_NPC_AI	= 11	-- 更换NPC的AI
ADD_GOUHUO		= 12	-- 增加篝火
SEND_CHAT		= 13	-- 发送NPC近聊
ADD_TITLE		= 14	-- 加称号
TRANSFORM_CHILD = 15    -- 变小孩
SHOW_NAME_AND_LIFE = 16 -- 显示姓名和血条
NPC_CAN_TALK	= 17	-- Dialog Npc 禁止对话
CHANGE_CAMP		= 18	-- 改变阵形
SET_SKILL		= 19	-- 设置左右键技能
DISABLE_SWITCH_SKILL = 20 -- 禁止切换技能
TRANSFORM_CHILD_2	= 21 -- 变牧童
FINISH_ACHIEVE		= 22 --成就
DEL_MAP_NPC		= 23	--删除地图里的npc
NPC_CAST_SKILL = 24		--NPC释放技能
NPC_REMOVE_SKILL = 25  --NPC移除一个技能状态
NPC_BLOOD_PERCENT = 26	--npc血量触发
PLAYER_SET_FORBID_SKILL = 27 --禁止使用某项技能
PLAYER_ADD_EFFECT = 28	--房间内所有玩家加一个状态
PLAYER_REMOVE_EFFECT = 29 -- 移除房间内玩家的一个状态
NPC_CAST_SKILL_TO_PLAYER = 30 --NPC释放技能给玩家
NPC_SET_LIFE		=	31	--设置npc的血量
ADD_NPC_SKILL		= 32	--给NPC添加技能
NEW_WORLD_PLAYER  = 33 --传送玩家
NEW_MSG_PLAYER	= 34	--通告
ADD_PLAYER_TITLE = 35	--给玩家加特殊称号



----------------事件通知类型-------------
TOFRIEND = 1	--好友公告
TOKINORTONG = 2 --家族公告
TOALLGAMESERVER = 3	--全服公告
TOGLOBAL = 4	--大区公告
----------------------------------------


-- AI模式
AI_MOVE			= 1
AI_RECYLE_MOVE	= 2
AI_ATTACK		= 3

XINGSHENSHI_OPEN	= 0;	-- 醒神石开关

MAX_TIMES			= 14 	-- 最多累计次数
MIN_TEAM_PLAYERS	= 1		-- 队伍至少人数
MIN_LEVEL			= 30	-- 最低等级
MAX_TEAM			= 8		-- 闯关最大队伍数
PLAY_ROOM_COUNT		= 5		-- 闯关关数
XIAKE_WIN_COUNT		= 5		-- 侠客任务需要通关关数
GUMUREPUTE_TASK_WIN_COUNT = 5 -- 古墓好友任务需要通关数
ROOM_MAX_LEVEL		= 8		-- 房间最大等级,15,16,17是后加的简单小妖，最大等级还是8不变
ROOM_EASY_BEG_LEVEL	= 15	-- 简单难度从15关开始
GUESS_QUESTIONS 	= 30	-- 猜迷最大题目数	
MIN_CORRECT			= 20	-- 最少要答对多少才能晋级
LOCK_MANAGER_TIME	= 20	-- 锁定报名的时间
PK_REFIGHT_TIME		= 20	-- PK重投战斗时间
MAX_REPUTE_TIMES	= 60	-- 最大兑换次数
START_TIME1			= 0800	-- 开启时间1
END_TIME1			= 2300	-- 关闭时间1
START_TIME2			= 0000	-- 开启时间2
END_TIME2			= 0200	-- 关闭时间2

MAX_SIMPLE_XOYO_LEVEL			= 60	-- 简单逍遥谷最大等级提示

TASK_GROUP			= 2050
TIMES_ID			= 1		-- 参加次数任务变量
CUR_DATE			= 2		-- 已经废弃
REPUTE_TIMES		= 3		-- 兑换次数任务变量
CUR_REPUTE_DATE		= 4		-- 最近兑换日期
ADDTIMES_TIME		= 5		-- 增加次数的时间
TASK_DIFFICUTY		= 54	-- 记录难度
ATTEND_TIME			= 66	-- 参加时间
EXCHANGE_TIMES		= 67	-- 已使用次数		
EXCHANGE_ROOM_LEVEL = 68	-- 最近一次使用的房间等级
TOLL_GATE_POINT		= 69	-- 通关积分 

DELAY_ENDTIME		= 15	-- 延迟关闭时间，15秒

REPUTE_CAMP			= 5
REPUTE_CLASS		= 3
REPUTE_VALUE		= 10	-- 兑换声望值

START_GAME_TIME 	= 30*60	-- 每30分钟开一场（给玩家看的虚假定时）

ITEM_BAOXIANG		= {18,1,190,1};
ITEM_HUANSHENDAN	= {18, 1, 728, 1, -1}; -- 逍遥还神丹

HUANSHENDAN_GAME_USETIMES = 3;	-- 每场使用次数
HUANSHENDAN_ROOM_USETIMES = 1;	-- 每个房间使用次数
HUANSHENDAN_MIN_DIFFICULTY= 5;	-- 5级以上难度可用
SUPER_TIME				  = 6;	-- 保护时间

KIN_MAX_RANK		= 10;	-- 家族排名最大名次
KIN_RANK_SYN_CD		= 30;		
KIN_RANK_CHANGGE_TIMES=200;
LOG_ATTEND_OPEN     = 1;      --逍遥谷参与LOG开关

RANK_RECORD = 5;

-- 房间等级对应的时间总数（秒）
ROOM_TIME = 
{
	[1] = 270,	-- 总 4分30
	[2] = 270,	-- 总 4分30
	[3] = 390,	-- 总 6分30
	[4]	= 510,	-- 总 8分30
	[5] = 630,	-- 总 10分30
	[6] = 510,	-- 总 8分钟
	[7] = 510,	-- 总 8分钟
	[8] = 630,	-- 总 10分钟
	[15] = 300,	-- 总 5分钟  （简单逍遥谷）
	[16] = 300,	-- 总 5分钟
	[17] = 510,	-- 总 8分30
}

-- 地图组 每组地图必须在同一个服务器~否则晋级之后跨服无法获得原来活动数据
MAP_GROUP_LV6 =
{
	[23] = {829, 836, 843, 850,2055,2020,2041,934},
	[24] = {830, 837, 844, 851,2014,2021,2042,935},
	[25] = {831, 838, 845, 852,2015,2022,2043,936},
	[26] = {832, 839, 846, 853,2016,2023,2044,937},
	[27] = {833, 840, 847, 854,2017,2024,2045,938},
	[28] = {834, 841, 848, 855,2018,2025,2046,939},
	[29] = {835, 842, 849, 856,2019,2026,2047,940},	
}

MAP_GROUP_LV7 =
{
	[23] = {2027,2034,864,857,878,885,2048,941},
	[24] = {2028,2035,865,858,879,886,2049,942},
	[25] = {2029,2036,866,859,880,887,2050,943},
	[26] = {2030,2037,867,860,881,888,2051,944},
	[27] = {2031,2038,868,861,882,889,2052,945},
	[28] = {2032,2039,869,862,883,890,2053,946},
	[29] = {2033,2040,870,863,884,891,2054,947},	
}

MAP_GROUP_LV8 =
{
	[23] = {871,892,899,906,913,920,927,948},
	[24] = {872,893,900,907,914,921,928,949},
	[25] = {873,894,901,908,915,922,929,950},
	[26] = {874,895,902,909,916,923,930,951},
	[27] = {875,896,903,910,917,924,931,952},
	[28] = {876,897,904,911,918,925,932,953},
	[29] = {877,898,905,912,919,926,933,954},	
}

MAP_GROUP_LV15 =
{
	[23] = {2252,2161,2245,2168},
	[24] = {2155,2162,2246,2169},
	[25] = {2156,2163,2247,2170},
	[26] = {2157,2164,2248,2171},
	[27] = {2158,2165,2249,2172},
	[28] = {2159,2166,2250,2173},
	[29] = {2160,2167,2251,2174},	
}

MAP_GROUP_LV16 =
{
	[23] = {2175,2182,2189,2196,2203,2210},
	[24] = {2176,2183,2190,2197,2204,2211},
	[25] = {2177,2184,2191,2198,2205,2212},
	[26] = {2178,2185,2192,2199,2206,2213},
	[27] = {2179,2186,2193,2200,2207,2214},
	[28] = {2180,2187,2194,2201,2208,2215},
	[29] = {2181,2188,2195,2202,2209,2216},	
}

MAP_GROUP_LV17 =
{
	[23] = {2217,2224,2231,2238},
	[24] = {2218,2225,2232,2239},
	[25] = {2219,2226,2233,2240},
	[26] = {2220,2227,2234,2241},
	[27] = {2221,2228,2235,2242},
	[28] = {2222,2229,2236,2243},
	[29] = {2223,2230,2237,2244},	
}

MAP_GROUP = 
{
	[23] = {298, 299, 300, 301, 302, 1542,MAP_GROUP_LV6[23],MAP_GROUP_LV7[23],MAP_GROUP_LV8[23],MAP_GROUP_LV15[23],MAP_GROUP_LV16[23],MAP_GROUP_LV17[23],},
	[24] = {303, 304, 305, 306, 307, 1543,MAP_GROUP_LV6[24],MAP_GROUP_LV7[24],MAP_GROUP_LV8[24],MAP_GROUP_LV15[24],MAP_GROUP_LV16[24],MAP_GROUP_LV17[24],},
	[25] = {308, 309, 310, 311, 312, 1544,MAP_GROUP_LV6[25],MAP_GROUP_LV7[25],MAP_GROUP_LV8[25],MAP_GROUP_LV15[25],MAP_GROUP_LV16[25],MAP_GROUP_LV17[25],},
	[26] = {313, 314, 315, 316, 317, 1545,MAP_GROUP_LV6[26],MAP_GROUP_LV7[26],MAP_GROUP_LV8[26],MAP_GROUP_LV15[26],MAP_GROUP_LV16[26],MAP_GROUP_LV17[26],},
	[27] = {318, 319, 320, 321, 322, 1546,MAP_GROUP_LV6[27],MAP_GROUP_LV7[27],MAP_GROUP_LV8[27],MAP_GROUP_LV15[27],MAP_GROUP_LV16[27],MAP_GROUP_LV17[27],},
	[28] = {323, 324, 325, 326, 327, 1547,MAP_GROUP_LV6[28],MAP_GROUP_LV7[28],MAP_GROUP_LV8[28],MAP_GROUP_LV15[28],MAP_GROUP_LV16[28],MAP_GROUP_LV17[28],},
	[29] = {328, 329, 330, 331, 332, 1548,MAP_GROUP_LV6[29],MAP_GROUP_LV7[29],MAP_GROUP_LV8[29],MAP_GROUP_LV15[29],MAP_GROUP_LV16[29],MAP_GROUP_LV17[29],},
}

-- 管理组
MANAGER_GROUP = 
{
	[341] = {23, 24, 25},
	[342] = {26, 27, 28, 29},
}

-- 开启开关
START_SWITCH = 
{
	[23] = 1,
	[24] = 1,
	[25] = 1,
	[26] = 1,
	[27] = 1,
	[28] = 1,
	[29] = 0,
}

BAOMING_IN_POS = {1625,3180};
GAME_IN_POS	   = {1406,2324};

-- 离开点
LEAVE_POS =
{
	[26] = {1514, 3123},
	[25] = {1726, 3245},
	[29] = {1718, 4090},
	[24] = {1954, 3571},
	[28] = {1602, 3359},
	[27] = {1666, 3260},
	[23] = {1648, 3185},
}

-- 4、5、6人队长增加的的领袖荣誉值
HONOR = {
	[1] = {[4] = 6,  [5] = 8,  [6] = 10},-- 第一关
	[2] = {[4] = 3,  [5] = 4, [6] = 5},	-- 第二关
	[3] = {[4] = 3, [5] = 4, [6] = 5},	-- 第三关
	[4]	= {[4] = 3, [5] = 4, [6] = 5},	-- 第四关
	[5] = {[4] = 3, [5] = 4, [6] = 5},	-- 第五关
	[6] = {[4] = 3, [5] = 4, [6] = 5},	-- 第六关
	[7] = {[4] = 3, [5] = 4, [6] = 5},	-- 第七关
	[8] = {[4] = 3, [5] = 4, [6] = 5},-- 第八关
	[15] = {[4] = 1, [5] = 2, [6] = 3},-- 第十五关
	[16] = {[4] = 1, [5] = 2, [6] = 3},-- 第十六关
	[17] = {[4] = 1, [5] = 2, [6] = 3},-- 第十七关
		};

-- { 开关，描述，星级描述，难度系数, 难度权重（影响对话排序）, 是否自动领取逍遥录 }
LevelDesp =
{
	[1] = { 1, 	"Thường",	"★", 				2,	1};
	[2] = { -1, "Vừa","★★", 			3,	1};
	[3] = { 1, 	"Hơi khó",	"★★★",			4, 	1};
	[4] = { -1, "Khó","★★★★",			5, 	1};
	[5] = { 1, 	"Cực khó",	"★★★★★",		6, 	1};
	[6] = {-1, 	"Truyền thuyết","★★★★★★",		7, 	1};
	[7] = {1, 	"Địa ngục", "★★★★★★★",	8, 	1};
	[8] = { -1, "Thường","★",				9, 	1};
	[9] = { 1, 	"Đơn giản",	"☆", 				1, 	0};
};




--StartLevel = {1, 1, 2, 2, 3};
LevelCofig = 
{
	[1] = {1,2,3,4,5},
	[3] = {2,3,4,5,6},
	[5] = {3,4,5,6,7},
	[7] = {4,5,6,7,8},
	[9] = {15,15,16,16,17},
};

DifficutyRequire = {50, 80, 100, 110, 100, 80, 110, 80, 30};

NPC_LEVEL_FILE = "\\setting\\xoyogame\\npc_level.txt";

CARD_RATE_TIMES = 1;				-- 卡片掉率的倍数(1)

tbGiveStoneProb = {[5] = 8,[6] = 16,[7] = 32,[8] = 64};	--产出矿石的概率

preEnv.setfenv(1, preEnv)

XoyoGame.TIMES_PER_DAY		= EventManager.IVER_nXoyoGameCount		-- 每天能参加逍遥谷的次数

--排序获得对话索引
local function tbDespSort(tbA, tbB)
	return tbA[2] < tbB[2]
end

function XoyoGame:GetDialogLevelDesp()
	local tbDesp = {};
	for nDiff, tbInfo in pairs(XoyoGame.LevelDesp) do
		table.insert(tbDesp, {nDiff, tbInfo[4]});
	end
	table.sort(tbDesp, tbDespSort);
	local tbSortIndex2Diff = {};
	for nIndex, tbInfo in ipairs(tbDesp) do
		tbSortIndex2Diff[nIndex] = tbInfo[1];
	end
	return tbSortIndex2Diff;
end
--{顺序index=[难度]}
XoyoGame.LevelDespSortIndex = XoyoGame:GetDialogLevelDesp();	--自动排序(对话);
