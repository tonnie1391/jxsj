
-- 领土争夺战 def脚本
-- zhengyuhua

local preEnv = _G	--保存旧的环境
setfenv(1, Domain)	--设置当前环境为XoyoGame

OPEN_SERVER 		= "gate0103"	-- 永乐开放

CLOSE_SHARE			= 0;			-- 关闭共享队友杀敌积分
CLOSE_ADD_PER_MINI	= 0;			-- 关闭每分钟加功勋
CLOSE_SYNC_INFO 	= 0;			-- 关闭同步信息
CLOSE_SYNC_TO_GC	= 0;			-- 关闭角色离开时给GC同步分数

TOWER_NPC			= 3390;			-- 标志NPC 模板ID
DEFEND_TOWER_NPC_LV1 = 3391;		-- 主城防守方标志 NPC
DEFEND_TOWER_NPC_LV3 = 3424;
DEFEND_TOWER_NPC_LV5 = 3425;
DEFEND_TOWER_NPC_LV7 = 3426;

TOWER_SELF_PIC		= 7
TOWER_ENEMY_PIC		= 8	
BOSS_PIC			= 9

TOWER_REVIVE_TIME	= 5			-- 标志NPC重生时间

DOMAIN_SKILL		= 891;		-- 征战状态ID
CAPTAIN_SKILL		= 893;		-- 主城辅助状态
FIRST_SKILL			= 1414		-- 初战沙场状态

SCORE_JIANGLING		= 75;
SCORE_SHIBING		= 35;
SCORE_PER_KILL		= 75;		-- 每杀一个人获得的功勋
SCORE_PER_TOWER		= 500;		-- 攻占一个箭塔获得的功勋

REPUTE_PERCENT		= 0.2		-- 直接给声望比例
BOX_REPUTE_PARAM	= 14;		-- 箱子的声望系数

DATA_AVAIL_TIME		= 60 * 5;	-- 征战结束后界面数据仍然有效的时间
CHANGE_FLAG_TIME	= 60 * 5;	-- 每5分钟更换一次加经验标记 
EXP_PRE_FLAG		= 20		-- 每次加20分钟的基准经验 
MIN_REACT_DOMAINCOUNT = 2		-- 会出现反扑的最少领土数量
BE_REACT_DOMAINCOUNT = 5		-- 移动会反扑的领土数

MAX_DOMAINAWARD_AWARD = 200000000;	-- 军饷上限

--TONG_MAX_REPUTE	= 60000
--TONG_MAX_EXP		= 44000
TONG_MAX_REPUTE_LEVEL = {2239, 1696, 1285, 974, 738}
TONG_MAX_EXP_LEVEL = {1642, 1244, 942, 714, 541}

REPUTE_PRE_BORDER	= 1600		-- 每个相邻点的声望参数
JUNXUXIANG_VALUE 	= 2000;		-- 每箱军需单价

SYNC_MAX_SORT		= 20;		-- 同步最大排名

DEFAULT_JUNXU		= 0;

TASK_GROUP_ID		= 2059;		-- 任务变量组
SCORE_ID			= 1;		-- 个人功勋积分
KILL_TOWER			= 2;		-- 所在队伍攻下龙柱的次数
KILL_PLAYER			= 3;		-- 所在队伍杀玩家的个数
-- 4，5为预留的任务可同步任务变量组
BATTLE_NO			= 6; 		-- 个人征战流水号
SCORE_TONG			= 7;		-- 获得功勋时所在的帮会 
CHUANSONG_ID		= 8;		-- 设置传送的地点
SYSTEMAWARD_NO		= 9;		-- 个人系统奖励流水号
TONGAWARD_NO		= 10;		-- 个人帮会奖励流水号
ADDEXP_FLAG			= 11;		-- 增加经验标记（每5分钟涨一次那种）
JUNXU_MEDICINE_NO	= 12;		-- 领取药军需流水号
JUNXU_NUM			= 13;		-- 本场已领取军需的数量
USE_DATE			= 14;		-- 使用声望道具的日期
USE_NUM				= 15;		-- 使用声望道具的数量
BOX_REMAIN			= 16;		-- 箱子奖励剩余的声望累计
TONGAWARD_AMOUNT    = 17;		-- 个人帮会奖励数量
JUNXU_HELPFUL_NO	= 18;		-- 领取辅助军需流水号

SAVE_SORT_NUM		= 10		-- 记录排名的个数

NO_BATTLE			= 0;		-- 无征战
PRE_BATTLE_STATE	= 1;		-- 宣战期
BATTLE_STATE		= 2;		-- 征战期
STOP_STATE			= 3;		-- 休战期
DOMAIN_BOX			= {18,1,252,1}

BATTLE_TIME			= 60 * 60	-- 征战时间 60分钟
STOP_TIME			= 10 * 60	-- 休战时间 10分钟

ADDBOSS_TIME		= 15 * 60	-- 每15分钟1刷
ADDBOSS_TIMES		= 3			-- 刷3轮BOSS

MAX_FLAG			= BATTLE_TIME / CHANGE_FLAG_TIME;		-- 加经验的次数

TONG_ATTEND_MIN		= 500
CENTER_REPUTE 		= 3000		-- 主城增加声望

SYSTEMAWARD = 1; -- 系统奖励
TONGAWARD = 2;  -- 帮会奖励
SYSTEMAWARDLIMIT = 800;
CAMP_DOMAINBATTLE = 8;
CLASS_DOMAIN = 1;



-- 领土争夺战各奖励档次对应的建设资金花费表
DOMAINBATTLE_AWARD_TABLE = {1000000, 5000000, 10000000, 30000000, 50000000};

TONG_AWARD_DAY = {5, 0};
TONG_AWARD_START_TIME = 2130;
TONG_AWARD_END_TIME = 2200;


-- 领土争夺战各功勋档次的比例和对应奖励价值量比例表
DOMAINBATTLE_SCORE_RATE_TABLE  =
{-- 功勋档次&比例	帮会奖励价值量比例   档次名称					系统奖励价值量比例
 	{0.1,	   		0.18,			"一骑当千（帮内排名前10%）",		0.19},
	{0.15,	   		0.21,			"战功显赫（帮内排名前25%）",		0.21},
	{0.20,	   		0.21,			"汗马功劳（帮内排名前45%）",		0.21},
	{0.25,	   		0.21,			"破军虎卫（帮内排名前70%）",		0.21},
	{0.3,        	0.19,			"沙场勇士（帮内排名70%后）",		0.18},
}

-- 领土争夺战根据星级数对应的声望值表
DOMAINBATTLE_REPUTE_PRESENT = 
{
-- 星级数 到达该级的倍数 超过该级后每级百分比
	{0, 	0,				0},
	{5,     0,				1.2},
	{9, 	6,				0.8},
	{13,  	9.2,			0.6},
	{17, 	11.6,			0.5},
	{21, 	13.6, 			0.4},
	{25, 	15.2,			0.3},
	{29, 	16.4, 			0.2},
	{10000, 17.2, 			0.15},
}

JUNXU_MEDICINE = 1

JUNXU_HELPFUL = 10

-- 军需药PARTICULAR
JUNXU_MEDICINE_PARTICULAR = {1783,1784,1785};
-- 军需行军丹PARTICULAR
JUNXU_HELPFUL_PARTICULAR = {321, 322, 323};

JUNXU_MEDICINE_PRICE = {[1] = 3000, [2] = 80000}

JUNXU_HELPFUL_PRICE = {[1] = 100000, [2] = 400000}

JUNXU_MEDICINE_MAX_NUM = 3

JUNXU_HELPFUL_MAX_NUM = 1

JUNXU_NAME = {
				[JUNXU_MEDICINE] = {[1] = "中级药",[2] = "高级药"},
			  	[JUNXU_HELPFUL] = {[1] = "行军丹（小）",[2] = "行军丹（中）"},
			 };
			 
JUNXU_MEDICINE_NAME = {  
				[JUNXU_MEDICINE] = {[1783] = "回血丹",
									[1784] = "回内丹", 
									[1785] = "乾坤造化丸"}
			 };

-- NPC方帮会名称
NPC_TONG_NAME = 
{
	[0] = "不知名的流寇",
	[1] = "西域将士_流亡",
	[2] = "金国将士_流亡",
	[3] = "大理国将士_流亡",
	[4] = "宋国将士_流亡",
}

OPENSTATE_TO_LEVEL = 
{
	[1] = {nNpcLevel = 85, 	nSkillLevel = 1, szOpenState = "OpenLevel89", 	nOffsetDay = 7},
	[2] = {nNpcLevel = 95, 	nSkillLevel = 2, szOpenState = "OpenLevel99", 	nOffsetDay = 0},
	[3] = {nNpcLevel = 105,	nSkillLevel = 3, szOpenState = "OpenLevel150", 	nOffsetDay = 0},
	[4] = {nNpcLevel = 120,	nSkillLevel = 4, szOpenState = "OpenLevel150", 	nOffsetDay = 150},
}

KILLER_LEVEL = 
{
	{0,		"<color=white>士兵<color>"},
	{2000,	"<color=green>校尉<color>"},
	{6000,	"<color=purple>统领<color>"},
	{8000,	"<color=gold>副将<color>"},
	{10000,	"<color=yellow>大将<color>"},
};

KILLER_SCORE = 
{
	[1] = {1,		2,		3,		4,		5},
	[2] = {0.5,		1,		2,		3,		4},
	[3]	= {0.34,	0.5,	1, 		2, 		3},
	[4] = {0.2,		0.25,	0.34,	1,		2},
	[5] = {0,		0.2,	0.25,	0.34,	1},
};

BATTLENO_TO_OPEN = 
{
	[1] = 1;
	[2] = 40;
	[3] = 70;
}

OPEN_DATE = 
{
	[0] = 1,
	[5] = 1,
}

STOCK_BASE_COUNT = {100000, 50000, 30000, 20000, 10000}; -- 不同级别的股份基数表

LINXIU_HONOR = {6000, 3500, 2100, 1500, 1000};	-- 不同级别的领袖荣誉表
 
DOMAIN_RATE = {18, 10, 5, 3, 1}; 	-- 领土数量分级表

-- 帮会缴纳霸主之印给的奖励（建设资金）
BAZHU_AWARD = {60000000, 40000000, 30000000, 20000000, 10000000, 10000000, 10000000, 10000000, 10000000, 10000000};
MIN_BAZHU_AMOUNT = {-1, -1, -1, -1, 500, 500, 500, 500, 500, 500};		-- 帮会最少需要缴纳的霸主之印的底限(-1表示没有底限)

AWARD_TIMES=1;

preEnv.setfenv(1, preEnv)

Domain.OPEN_DATE = {
	[0] = 1,
	[EventManager.IVER_nDomainBattleDay] = 1,	
};

Domain.TONG_AWARD_DAY = {EventManager.IVER_nDomainBattleDay, 0};